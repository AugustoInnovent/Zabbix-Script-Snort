#!/bin/sh

LOG_FILE="/var/log/filter.log"  

LIMITE_EPOCH=$(date -j -v-3d "+%s")

awk -v limite="$LIMITE_EPOCH" '
function get_epoch(date_str,   cmd, epoch) {
    gsub("T.*", "", date_str)  # Remove hora
    cmd = "date -j -f \"%Y-%m-%d\" \"" date_str "\" +%s"
    cmd | getline epoch
    close(cmd)
    return epoch
}
{
    data_iso = $2  # Ex: 2025-06-18T09:07:00.123456-03:00
    epoch = get_epoch(data_iso)
    if (epoch >= limite) {
        for (i=1; i<=NF; i++) {
            if ($i ~ /^[A-Z]+$/) {
                proto = $i
                counts[proto]++
                break
            }
        }
    }
}
END {
    print "Ranking de protocolos nos últimos 3 dias:\n"
    for (p in counts) {
        printf "%s: %d\n", p, counts[p]
    }
}' "$LOG_FILE" | sort -k2 -nr
