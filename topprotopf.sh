#!/bin/sh

LOG_FILE="/caminho/para/seu/logfile.log"  # <- ajuste aqui
DIAS=3

HOJE=$(date +%s)
LIMITE=$(date -v -${DIAS}d +%s)  

extrair_data_epoch() {
    linha="$1"
    data=$(echo "$linha" | awk -F'T' '{print $1}' | awk '{print $2}')
    date -j -f "%Y-%m-%d" "$data" "+%s" 2>/dev/null  
}

awk -v hoje="$HOJE" -v limite="$LIMITE" '
{
    split($3, dt, "T");  # Extrai data
    data = dt[1];
    cmd = "date -j -f %Y-%m-%d " data " +%s";  # Para Linux: cmd = "date -d " data " +%s"
    cmd | getline epoch;
    close(cmd);
    if (epoch >= limite) {
        for (i=1; i<=NF; i++) {
            if ($i ~ /^[A-Z]+$/) {
                proto = $i;
                counts[proto]++;
                break;
            }
        }
    }
}
END {
    print "Ranking de protocolos nos últimos 3 dias:\n";
    for (p in counts) {
        printf "%s: %d\n", p, counts[p];
    }
}' "$LOG_FILE" | sort -k2 -nr
