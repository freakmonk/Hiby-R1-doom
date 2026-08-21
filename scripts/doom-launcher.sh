#!/bin/sh
# Doom Launcher for HiBy R1
# Kills the HiBy music player, mounts SD card, and runs Doom

SD_MOUNT=/data/mnt/sd_0
DOOM_DIR=$SD_MOUNT/doom
LOG_FILE=/usr/data/doom.log

log() {
    echo "doom-launcher: $*" > /dev/console 2>/dev/null
    echo "doom-launcher: $*" >> $LOG_FILE
}

log "Starting Doom launcher..."

# Free GPU/Framebuffer and audio by killing hiby_player
killall    hiby_player >/dev/null 2>&1
killall -9 hiby_player >/dev/null 2>&1

# Mount SD card if unmounted
if ! grep -q " $SD_MOUNT " /proc/mounts 2>/dev/null; then
    mkdir -p "$SD_MOUNT" 2>/dev/null
    for dev in /dev/mmcblk0p1 /dev/mmcblk0 /dev/mmcblk1p1 /dev/mmcblk1; do
        [ -b "$dev" ] || continue
        mount -t vfat,exfat -o rw "$dev" "$SD_MOUNT" 2>/dev/null || \
        mount -o rw "$dev" "$SD_MOUNT" 2>/dev/null && break
    done
fi

mkdir -p "$DOOM_DIR" 2>/dev/null

# Look for WAD file (case insensitive search)
WAD_FILE=""
for w in "$DOOM_DIR/DOOM1.WAD" "$DOOM_DIR/doom1.wad" "$DOOM_DIR/DOOM.WAD" "$DOOM_DIR/doom.wad"; do
    if [ -f "$w" ]; then
        WAD_FILE="$w"
        break
    fi
done

if [ -z "$WAD_FILE" ]; then
    log "ERROR: No WAD file found! Please put DOOM1.WAD in SD card folder /doom/"
    # Show error log to console
    echo "Copy DOOM1.WAD to SD card folder /doom/" > /dev/console
    sleep 5
    exit 1
fi

log "Found WAD: $WAD_FILE"

# Determine path to doom executable
DOOM_BIN=/usr/bin/doom
[ -x /usr/data/doom ] && DOOM_BIN=/usr/data/doom

cd "$DOOM_DIR"
log "Executing $DOOM_BIN -iwad $WAD_FILE"
"$DOOM_BIN" -iwad "$WAD_FILE" >> $LOG_FILE 2>&1

log "Doom exited. Restarting player..."
sleep 1
reboot
