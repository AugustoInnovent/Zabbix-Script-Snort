#!/bin/sh

# Caminho do log do Snort (ajuste se for diferente)
LOG="/var/log/snort/snort_igc122391/alert"

# Número de portas mais utilizadas a mostrar
TOP=10

# Extraindo portas origem e destino e mostrando as mais frequentes
echo "Top $TOP portas de ORIGEM:"
awk -F',' '{print $8}' "$LOG" | sort | uniq -c | sort -nr | head -n $TOP

echo ""
echo "Top $TOP portas de DESTINO:"
awk -F',' '{print $10}' "$LOG" | sort | uniq -c | sort -nr | head -n $TOP
