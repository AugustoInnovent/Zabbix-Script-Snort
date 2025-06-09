#!/bin/sh

ZABBIX_HOST="PFSENSE-FOR"
ZABBIX_SERVER="74.163.81.252"
ZABBIX_KEY="net.topports.snort"
LOG="/var/log/snort/snort_igc122391/alert"

if [ ! -f "$LOG" ]; then
  echo "Arquivo de log não encontrado: $LOG"
  exit 1
fi

TMP_LOG=$(mktemp)

for i in 0 1 2; do
  DIA=$(date -v-"$i"d +%y/%m/%d)   
  grep "^$DIA-" "$LOG" >> "$TMP_LOG"
done

if [ ! -s "$TMP_LOG" ]; then
  echo "Sem eventos nos últimos 3 dias no log do Snort."
  rm -f "$TMP_LOG"
  exit 0
fi

PORT_DEST=$(awk -F',' '{print $8}' "$TMP_LOG" | sort | uniq -c | sort -nr | head -n 5 || true)
PORT_SRC=$(awk -F',' '{print $10}' "$TMP_LOG" | sort | uniq -c | sort -nr | head -n 5 || true)

PORT_STATS="Top Dest Ports (last 3 days):\n$PORT_DEST\n\nTop Source Ports (last 3 days):\n$PORT_SRC"

/usr/local/bin/zabbix_sender -z 74.163.81.252 -s "PFSENSE-FOR" -k "$ZABBIX_KEY" -o "$PORT_STATS"

rm -f "$TMP_LOG"
