#!/bin/sh

LOG_FILE="/var/log/snort/snort_igc231737/alert"

TODAY=$(date +"%m/%d/%y")

TCP=$(grep "^$TODAY" ../../../../var/log/snort/snort_igc122391/alert | grep ",TCP," | wc -l)
/usr/local/bin/zabbix_sender -z 74.163.81.252 -s "PFSENSE-FOR" -k snort.proto.tcp.daily -o "$TCP"
UDP=$(grep "^$TODAY" ../../../../var/log/snort/snort_igc122391/alert | grep ",UDP," | wc -l)
/usr/local/bin/zabbix_sender -z 74.163.81.252 -s "PFSENSE-FOR" -k snort.proto.udp.daily -o "$UDP"
ICMP=$(grep "^$TODAY" ../../../../var/log/snort/snort_igc122391/alert | grep ",ICMP," | wc -l)
/usr/local/bin/zabbix_sender -z 74.163.81.252 -s "PFSENSE-FOR" -k snort.proto.icmp.daily -o "$ICMP"
