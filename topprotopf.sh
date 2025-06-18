#!/bin/sh

LOG="/var/log/filter.log" 
TMP_FILE="/tmp/protocols_count.txt"

DAY1=$(date -v-0d "+%Y-%m-%d")
DAY2=$(date -v-1d "+%Y-%m-%d")
DAY3=$(date -v-2d "+%Y-%m-%d")

[ "$(uname)" != "Darwin" ] && {
    DAY1=$(date "+%Y-%m-%d")
    DAY2=$(date -d "-1 day" "+%Y-%m-%d")
    DAY3=$(date -d "-2 day" "+%Y-%m-%d")
}

grep -E "$DAY1|$DAY2|$DAY3" "$LOG" | \
    awk -F',' '{print $20}' | \
    sort | uniq -c | sort -nr > "$TMP_FILE"

echo "Top protocolos dos últimos 3 dias:"
cat "$TMP_FILE"
