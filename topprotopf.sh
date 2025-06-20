#!/bin/sh

ZABBIX_HOST="PFSENSE-FOR"
ZABBIX_SERVER="74.163.81.252"
ZABBIX_KEY="net.topprotos.pf"
LOG_FILE="/var/log/filter.log"
TMP_FILE="/tmp/top_protos.txt"


LIMITE_EPOCH=$(date -j -v-3d "+%s")

awk -v limite="$LIMITE_EPOCH" '
function get_epoch(date_str,   clean, cmd, epoch) {
    gsub("T", "", date_str)           # Junta data e hora
    gsub("[-:]", "", date_str)        # Remove separadores
    gsub(/\..*/, "", date_str)        # Remove microsegundos e timezone
    clean = substr(date_str, 1, 12)   # YYYYMMDDHHMM
    clean = clean ".00"               # Adiciona segundos
    cmd = "date -j -f \"%Y%m%d%H%M.%S\" \"" clean "\" +%s"
    cmd | getline epoch
    close(cmd)
    return epoch
}
{
    data_iso = $2  # Ex: 2025-06-18T09:07:00.458077-03:00
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
    for (p in counts) {
        printf "%d %s\n", counts[p], p
    }
}' "$LOG_FILE" | sort -nr | head -10 > "$TMP_FILE"


JSON="{"
i=0
while read -r count proto; do
    [ $i -gt 0 ] && JSON="$JSON,"
    JSON="$JSON\"$proto\":$count"
    i=$((i+1))
done < "$TMP_FILE"
JSON="$JSON}"


zabbix_sender -z 74.163.81.252 -s "PFSENSE-FOR" -k "$ZABBIX_KEY" -o "$JSON"
