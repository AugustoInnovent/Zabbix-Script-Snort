#!/bin/sh

LOG_FILE="/var/log/snort/snort_igc122391/alert"
TODAY=$(date +"%m/%d/%y")

TCP=$(grep "^$TODAY" "$LOG_FILE" | grep ",TCP," | wc -l)
UDP=$(grep "^$TODAY" "$LOG_FILE" | grep ",UDP," | wc -l)
ICMP=$(grep "^$TODAY" "$LOG_FILE" | grep ",ICMP," | wc -l)

echo "$TCP"
echo "$UDP"
echo "$ICMP"
