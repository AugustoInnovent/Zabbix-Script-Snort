#!/bin/sh

LOG_FILE="/var/log/snort/snort_igc122391/alert"
ZBX_SERVER="74.163.81.252"
ZBX_HOST="PFSENSE-FOR"
TMP_FILE="/tmp/snort_top_ports.txt"

grep "->" "$LOG_FILE" | \
  awk '{print $9}' | \
  cut -d':' -f2 | \
  grep -E '^[0-9]+$' | \
  sort | uniq -c | sort -nr | head -n 5 > "$TMP_FILE"

ZBX_DATA="/tmp/zabbix_snort_data.txt"
> "$ZBX_DATA"

while read -r COUNT PORT; do
    echo "\"PFSENSE-FOR\" snort.port[$PORT] $COUNT" >> "$ZBX_DATA"
done < "$TMP_FILE"

zabbix_sender -z "74.163.81.252" -i "$ZBX_DATA"

rm -f "$TMP_FILE" "$ZBX_DATA"
