#!/bin/sh

LOG_FILE="/var/log/snort/snort_igc122391/alert"
TODAY=$(date +"%m/%d/%y")

TCP=$(grep "^$TODAY" /var/log/snort/snort_igc122391/alert | grep ",TCP," | wc -l)
UDP=$(grep "^$TODAY" /var/log/snort/snort_igc122391/alert | grep ",UDP," | wc -l)
ICMP=$(grep "^$TODAY" /var/log/snort/snort_igc122391/alert | grep ",ICMP," | wc -l)

echo "$TCP"
echo "$UDP"
echo "$ICMP"
