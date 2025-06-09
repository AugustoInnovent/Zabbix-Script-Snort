#!/bin/sh

ZABBIX_HOST="PFSENSE-FOR"                  # Nome exato do host no Zabbix
ZABBIX_SERVER="74.163.81.252"           # IP ou hostname do servidor Zabbix
ZABBIX_KEY="net.topports.snort"        # A chave configurada no item (Zabbix trapper)
LOG="/var/log/snort/snort_igc122391/alert"  # Corrija com o caminho real

# Verifica se o arquivo existe
if [ ! -f "$LOG" ]; then
  echo "Arquivo de log não encontrado: $LOG"
  exit 1
fi

# Coleta as 5 portas de destino mais usadas (coluna 8) e origem (coluna 10)
PORT_DEST=$(awk -F',' '{print $8}' "$LOG" | sort | uniq -c | sort -nr | head -n 5 || true)
PORT_SRC=$(awk -F',' '{print $10}' "$LOG" | sort | uniq -c | sort -nr | head -n 5 || true)

# Monta a string final
PORT_STATS="Top Dest Ports:\n$PORT_DEST\n\nTop Source Ports:\n$PORT_SRC"

# Envia para o Zabbix
/usr/local/bin/zabbix_sender -z 74.163.81.252 -s "PFSENSE-FOR" -k "$ZABBIX_KEY" -o "$PORT_STATS"
