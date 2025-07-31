#!/bin/sh

LOG_FILE="/var/log/snort/snort_igc122391/alert"

TODAY=$(date +"%m/%d/%y")


TCP=$(grep "^$TODAY" "$LOG_FILE" | grep ",TCP," | wc -l)
UDP=$(grep "^$TODAY" "$LOG_FILE" | grep ",UDP," | wc -l)
ICMP=$(grep "^$TODAY" "$LOG_FILE" | grep ",ICMP," | wc -l)

/usr/local/bin/zabbix_sender -z 74.163.81.252 -s "PFSENSE-FOR" -k snort.proto.tcp.daily -o "$TCP"
/usr/local/bin/zabbix_sender -z 74.163.81.252 -s "PFSENSE-FORT" -k snort.proto.udp.daily -o "$UDP"
/usr/local/bin/zabbix_sender -z 74.163.81.252 -s "PFSENSE-FOR" -k snort.proto.icmp.daily -o "$ICMP"
