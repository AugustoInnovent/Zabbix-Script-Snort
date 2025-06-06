#!/bin/sh

LOG_FILE="/var/log/snort/snort_igc122391/alert"
ZBX_SERVER="74.163.81.252"
ZBX_HOST="PFSENSE-FOR"
TMP_DIR="/tmp"
DISCOVERY_FILE="$TMP_DIR/snort_lld.json"
DATA_FILE="$TMP_DIR/snort_data.txt"

PORTS=$(cut -d',' -f11 "$LOG_FILE" | sort -n | uniq)

echo -n '{"data":[' > "$DISCOVERY_FILE"
FIRST=1
for PORT in $PORTS; do
    if [ $FIRST -eq 0 ]; then
        echo -n "," >> "$DISCOVERY_FILE"
    fi
    echo -n "{\"{#PORT}\":\"$PORT\"}" >> "$DISCOVERY_FILE"
    FIRST=0
done
echo "]}" >> "$DISCOVERY_FILE"

zabbix_sender -z "$ZBX_SERVER" -s "$ZBX_HOST" -k snort.port.discovery -o "$(cat $DISCOVERY_FILE)"

> "$DATA_FILE"
for PORT in $PORTS; do
    COUNT=$(cut -d',' -f11 "$LOG_FILE" | grep -c "^$PORT$")
    echo "\"$ZBX_HOST\" snort.port[$PORT] $COUNT" >> "$DATA_FILE"
done

zabbix_sender -z 74.163.81.252 -i "$DATA_FILE"
