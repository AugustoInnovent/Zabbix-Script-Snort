#!/bin/sh

ZABBIX_HOST="PFSENSE-FOR"         
ZABBIX_SERVER="74.163.81.252"
ZABBIX_KEY="net.topports.snort"

LOG="/var/log/snort/snort_igc122391/alert"

PORT_STATS=$(awk -F',' '{print $8}' "$LOG" | sort | uniq -c | sort -nr | head -n 5)
PORT_STATS="$PORT_STATS\n"
PORT_STATS="$PORT_STATS\n$(awk -F',' '{print $10}' "$LOG" | sort | uniq -c | sort -nr | head -n 5)"

echo "$PORT_STATS" | /usr/local/bin/zabbix_sender -z 74.163.81.252 -s "PFSENSE-FOR" -k "net.topports.snort" -T -i
