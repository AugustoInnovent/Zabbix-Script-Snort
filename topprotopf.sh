#!/bin/sh

LOG="/var/log/filterlog.log"

if [ ! -f "$LOG" ]; then
    echo "Log não encontrado: $LOG"
    exit 1
fi

DATES=$(for i in 0 1 2 3; do date -d "-$i days" "+%Y-%m-%d"; done)

awk -v dates="$DATES" '
BEGIN {
    split(dates, daylist)
    for (i in daylist) daymap[daylist[i]] = 1
    FS = ","
}
{
    match($0, /^[^ ]+ +[^ ]+ +[^T]+T[0-9:.+-]+/, ts)
    split(ts[0], datepart, "T")
    logdate = datepart[1]

    if (logdate in daymap) {
        for (i = 1; i <= NF; i++) {
            if ($i ~ /^(UDP|TCP|ICMP|icmp|udp|tcp)$/) {
                proto[toupper($i)]++
                break
            }
        }
    }
}
END {
    for (p in proto) {
        printf "%s %d\n", p, proto[p]
    }
}
' "$LOG" | sort -k2 -nr
