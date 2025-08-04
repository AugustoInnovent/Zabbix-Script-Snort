#!/bin/sh

LOG="/var/log/snort/snort_igc231737/alert"
TMP_FILE="/tmp/snort_top_ips.txt"
TODAY=$(date "+%m/%d/%y")

grep "^$TODAY" "$LOG" | \
    awk -F',' '{print $7}' | \
    sort | uniq -c | sort -nr | head -10 > "$TMP_FILE"

JSON="{"
i=0
while read -r count ip; do
    [ $i -gt 0 ] && JSON="$JSON,"
    JSON="$JSON\"$ip\":$count"
    i=$((i+1))
done < "$TMP_FILE"
JSON="$JSON}"

echo "$JSON"
