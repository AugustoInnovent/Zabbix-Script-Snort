#!/bin/sh

# Host configurado no Zabbix (precisa bater com o hostname do item no Zabbix)
ZABBIX_HOST="PFSENSE-FOR"         
ZABBIX_SERVER="74.163.81.252"
ZABBIX_KEY="net.topports.snort"

# Caminho do log Snort
LOG="/var/log/snort/alert"

# Gerar estatística
PORT_STATS=$(awk -F',' '{print $8}' "$LOG" | sort | uniq -c | sort -nr | head -n 5)
PORT_STATS="$PORT_STATS\n"
PORT_STATS="$PORT_STATS\n$(awk -F',' '{print $10}' "$LOG" | sort | uniq -c | sort -nr | head -n 5)"

# Enviar usando zabbix_sender
echo "$PORT_STATS" | /usr/local/bin/zabbix_sender -z 74.163.81.252 -s "PFSENSE-FOR" -k "net.topports.snort" -T -i -
