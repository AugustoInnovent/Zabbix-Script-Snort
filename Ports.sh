#!/bin/sh

LOG_FILE="/var/log/snort/snort_igc122391/alert"
ZBX_SERVER="74.163.81.252"
ZBX_HOST="PFSENSE-FOR"
TMP_FILE="/tmp/snort_ports.csv"
ZBX_DATA="/tmp/zabbix_snort_data.txt"

cut -d',' -f11 "$LOG_FILE" | \
  grep -E '^[0-9]+$' | \
  sort | uniq -c | sort -nr | head -n 5 > "$TMP_FILE"

> "$ZBX_DATA"

while read -r COUNT PORT; do
    echo "\"PFSENSE-FOR\" snort.port[$PORT] $COUNT" >> "$ZBX_DATA"
done < "$TMP_FILE"

zabbix_sender -z 74.163.81.252 -i "$ZBX_DATA"

rm -f "$TMP_FILE" "$ZBX_DATA"
