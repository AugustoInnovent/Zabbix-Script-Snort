#!/bin/sh

ZABBIX_HOST="PFSENSE-FOR"
ZABBIX_SERVER="74.163.81.252"
ZABBIX_KEY="net.topprotos.pf"
LOG_FILE="/var/log/filter.log"
TMP_FILE="/tmp/top_protos.txt"

# Epoch 3 dias atrás
LIMITE_EPOCH=$(date -j -v-3d "+%s")

awk -v limite="$LIMITE_EPOCH" '
function get_epoch(date_str, date_part, time_part, clean, cmd, epoch) {
    # Divide data e hora
    split(date_str, parts, "T")
    date_part = parts[1]        # "2025-06-20"
    time_part = parts[2]        # "09:30:00.123456-03:00"

    # Formata data
    gsub("-", "", date_part)    # "20250620"

    # Separa hora, minuto, segundo
    split(time_part, tparts, ":")
    hh = tparts[1]
    mm = tparts[2]
    ss = substr(tparts[3], 1, 2)  # "00" (do início de "00.123456")

    # Monta formato aceito por date do FreeBSD
    clean = date_part hh mm "." ss

    cmd = "date -j -f \"%Y%m%d%H%M.%S\" \"" clean "\" +%s"
    cmd | getline epoch
    close(cmd)
    return epoch
}
{
    data_iso = $2  # Ex: 2025-06-20T09:30:00.123456-03:00
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
