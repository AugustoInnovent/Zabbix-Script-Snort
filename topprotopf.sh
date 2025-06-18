#!/bin/sh

LOG_FILE="/var/log/filter.log" 
DIAS=3

LIMITE_EPOCH=$(date -d "-${DIAS} days" +%s) 

awk -v limite="$LIMITE_EPOCH" '
function get_epoch(date_str) {
    gsub("T.*", "", date_str)
    cmd = "date -d \"" date_str "\" +%s"
    cmd | getline epoch
    close(cmd)
    return epoch
}
{
    data_iso = $2
    epoch = get_epoch(data_iso)
    if (epoch >= limite) {
        for (i=1; i<=NF; i++) {
            if ($i ~ /^[A-Z]+$/) {
                proto = $i
                counts[proto]++
                break
            }
        }
    }
}
END {
    print "Ranking de protocolos nos últimos 3 dias:\n"
    for (p in counts) {
        printf "%s: %d\n", p, counts[p]
    }
}' "$LOG_FILE" | sort -k2 -nr

