#!/bin/sh

LOG="/var/log/filterlog.log"


if [ ! -f "$LOG" ]; then
  echo "Arquivo de log não encontrado: $LOG"
  exit 1
fi

DATA1=$(date -d "0 days ago" +"%Y-%m-%d")
DATA2=$(date -d "1 days ago" +"%Y-%m-%d")
DATA3=$(date -d "2 days ago" +"%Y-%m-%d")


grep -E "$DATA1|$DATA2|$DATA3" "$LOG" | \
awk -F, '{print tolower($15)}' | \
sort | uniq -c | sort -nr | \
awk '{printf "%s: %d\n", $2, $1}'
