#!/bin/sh

killall    hiby_player    &>/dev/null
killall -9 hiby_player    &>/dev/null

# --- PERFORMANCE TWEAKS ---
# Increase SD card read-ahead buffer
if [ -e /sys/block/mmcblk0/queue/read_ahead_kb ]; then
    echo 2048 > /sys/block/mmcblk0/queue/read_ahead_kb
fi

# Tune memory caching for responsiveness
sysctl -w vm.vfs_cache_pressure=50


#/usr/bin/hiby_player &>/dev/null
/usr/bin/hiby_player
sleep 1
reboot