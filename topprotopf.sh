#!/bin/sh

LOG="/var/log/filterlog.log"

if [ ! -f "$LOG" ]; then
    echo "Arquivo de log não encontrado: $LOG"
    exit 1
fi

awk -F',' '
{
    for (i = 1; i <= NF; i++) {
        if ($i ~ /^(UDP|TCP|ICMP|icmp|udp|tcp)$/) {
            proto[toupper($i)]++
            break
        }
    }
}
END {
    for (p in proto) {
        printf "%s %d\n", p, proto[p]
    }
}
' "$LOG" | sort -k2 -nr
