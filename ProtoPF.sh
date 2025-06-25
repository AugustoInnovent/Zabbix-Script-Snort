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
      if (match($0, /<134>1 ([0-9]{4}-[0-9]{2}-[0-9]{2})T.*filterlog.*(tcp|udp|icmp)/, m)) {
          if (m[1] == today) {
              proto = tolower(m[2])
              count[proto]++
          }
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
