#!/bin/sh

ZABBIX_HOST="PFSENSE-FOR"
ZABBIX_SERVER="74.163.81.252"
ZABBIX_KEY="net.topprotos.pf"
LOG_FILE="/var/log/filter.log"

command -v zabbix_sender >/dev/null 2>&1 || {
  echo "Erro: zabbix_sender não encontrado no PATH"; exit 1; }

[ -r "$LOG_FILE" ] || {
  echo "Erro: não foi possível ler $LOG_FILE"; exit 1; }

today=$(date +"%Y-%m-%d")

awk -v today="$today" '
/<134>1 / && /filterlog/ {
    split($0, a, "T")
    log_date = a[1]

    proto = ""
    if ($0 ~ / tcp /) proto = "tcp"
    else if ($0 ~ / udp /) proto = "udp"
    else if ($0 ~ / icmp /) proto = "icmp"

    if (proto != "" && log_date == today) {
        count[proto]++
    }
}
END {
    for (p in count) {
        printf "%s %d\n", p, count[p]
    }
}
' "$LOG_FILE" | while read -r proto cnt; do
    item_key="${ZABBIX_KEY}[${proto}]"

    zabbix_sender -z "$ZABBIX_SERVER" -s "$ZABBIX_HOST" \
                  -k "$item_key" -o "$cnt" \
                  >/dev/null 2>&1

    printf "[%s] = %d\n" "$item_key" "$cnt"
done
