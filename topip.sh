#!/bin/sh

ZABBIX_HOST="PFSENSE-FOR"
ZABBIX_SERVER="74.163.81.252"
ZABBIX_KEY="net.topip.snort"
LOG="/var/log/snort/snort_igc122391/alert"
TMP_FILE="/tmp/snort_top_ips.txt"

# Extrai os IPs de origem externos dos alertas (campo 7, IP de origem)
grep -Eo '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' "$LOG" | \
    awk 'NR % 2 == 1' | \
    sort | uniq -c | sort -nr | head -10 > "$TMP_FILE"

# Envia os 10 IPs mais frequentes como um único valor (formato JSON simples)
JSON="{"
i=0
while read -r count ip; do
    [ $i -gt 0 ] && JSON="$JSON,"
    JSON="$JSON\"$ip\":$count"
    i=$((i+1))
done < "$TMP_FILE"
JSON="$JSON}"

# Envia para o Zabbix
zabbix_sender -z 74.163.81.252 -s "PFSENSE-FOR" -k "$ZABBIX_KEY" -o "$JSON"
