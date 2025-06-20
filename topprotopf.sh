#!/bin/sh

ZABBIX_HOST="PFSENSE-FOR"
ZABBIX_SERVER="74.163.81.252"
ZABBIX_KEY="net.topprotos.pf"
LOG_FILE="/var/log/filter.log"
TMP_FILE="/tmp/top_protos.txt"

LIMITE_EPOCH=$(date -j -v-3d "+%s")

awk -v limite="$LIMITE_EPOCH" '
function get_epoch(date_str, date_part, time_part, hh, mm, ss, clean, cmd, epoch) {
    split(date_str, parts, "T")
    if (length(parts) < 2) return 0 

    date_part = parts[1]
    time_part = parts[2]

    gsub("-", "", date_part)

    split(time_part, tparts, ":")
    if (length(tparts) < 3) return 0  # ignora se incompleto

    hh = tparts[1]
    mm = tparts[2]
    ss = substr(tparts[3], 1, 2)

    if (hh !~ /^[0-9]+$/ || mm !~ /^[0-9]+$/ || ss !~ /^[0-9]+$/) return 0

    clean = date_part hh mm "." ss
    cmd = "date -j -f \"%Y%m%d%H%M.%S\" \"" clean "\" +%s"
    cmd | getline epoch
    close(cmd)
    return epoch
}
{
    data_iso = $2 
    epoch = get_epoch(data_iso)
    if (epoch >= limite && epoch > 0) {
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
