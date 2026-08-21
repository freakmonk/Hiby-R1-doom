#!/bin/bash
set -euo pipefail

# HiBy R1 Doom Mod Builder (macOS & Linux wrapper)
# Runs the entire build process inside a Linux Docker container to guarantee 100% flawless execution without macOS permission or toolchain issues.

UPT_FILE="${1:-r1.upt}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================="
echo " HiBy R1 Doom Firmware Mod Builder"
echo "=========================================="

if [[ ! -f "$SCRIPT_DIR/$UPT_FILE" ]]; then
    echo "⚠️ Error: Cannot find firmware file '$SCRIPT_DIR/$UPT_FILE'."
    echo "Please place stock HiBy R1 firmware file (e.g. r1.upt) in this folder:"
    echo "  $SCRIPT_DIR"
    echo "and rerun:"
    echo "  ./build_doom_firmware.sh r1.upt"
    exit 1
fi

chmod +x "$SCRIPT_DIR/scripts/container_build.sh" "$SCRIPT_DIR/scripts/doom-launcher.sh" "$SCRIPT_DIR/Hiby-R1-Mod/bidhata-menu/patch/bidhata-patch.sh"

echo "🔨 Building Docker image hiby-mips-builder..."
docker build -t hiby-mips-builder -f "$SCRIPT_DIR/Dockerfile.mips" "$SCRIPT_DIR" >/dev/null

echo "🚀 Running firmware modification inside Docker container..."
docker run --rm -v "$SCRIPT_DIR:/build" hiby-mips-builder /bin/bash /build/scripts/container_build.sh "$UPT_FILE"

if [[ -f "$SCRIPT_DIR/r1_doom_mod.upt" ]]; then
    echo ""
    echo "=========================================="
    echo "🎉 READY! Modified firmware generated:"
    echo "   📍 $SCRIPT_DIR/r1_doom_mod.upt"
    echo "=========================================="
    echo "Instructions:"
    echo "1. Copy r1_doom_mod.upt to root of MicroSD card."
    echo "2. Copy bidhata-menu.conf from sd_card/ to root of MicroSD card."
    echo "3. Copy sd_card/doom/ folder (containing DOOM1.WAD) to MicroSD card."
    echo "4. Flash firmware via HiBy R1 System Settings -> System Update."
    echo "5. Boot player, select DOOM from boot menu and play!"
else
    echo "❌ Error: Build failed."
    exit 1
fi
