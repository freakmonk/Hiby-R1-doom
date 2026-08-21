#!/bin/bash
set -euo pipefail

# In-container build script for HiBy R1 Doom Mod
# Runs inside Linux Docker container to guarantee flawless toolchain & squashfs manipulation without macOS permission quirks.

BUILD_DIR="/build"
UPT_FILE="${1:-r1.upt}"
UPT_PATH="$BUILD_DIR/$UPT_FILE"
OUT_UPT="$BUILD_DIR/r1_doom_mod.upt"

echo "=========================================="
echo " HiBy R1 Doom Firmware Mod (Docker Build)"
echo "=========================================="

if [[ ! -f "$UPT_PATH" ]]; then
    echo "❌ Error: Cannot find firmware file $UPT_PATH"
    echo "Please place r1.upt in workspace directory."
    exit 1
fi

# 1. Compile Doom binary for MIPS32r2
echo "🔨 Compiling Doom for MIPS32r2..."
cd "$BUILD_DIR/fbdoom_src"
make CROSS_COMPILE=mipsel-linux-gnu- clean all

# 2. Compile Bidhata Boot Menu for MIPS32r2
echo "🔨 Compiling Bidhata Boot Menu for MIPS32r2..."
cd "$BUILD_DIR/Hiby-R1-Mod/bidhata-menu"
make CROSS=mipsel-linux-gnu- STATIC=1 clean all

cp "$BUILD_DIR/Hiby-R1-Mod/bidhata-menu/bidhata-menu" "$BUILD_DIR/Hiby-R1-Mod/bidhata-menu/patch/payload/bidhata-menu"
cp "$BUILD_DIR/Hiby-R1-Mod/bidhata-menu/scripts/bidhata-launcher.sh" "$BUILD_DIR/Hiby-R1-Mod/bidhata-menu/patch/payload/bidhata-launcher.sh"
cp "$BUILD_DIR/Hiby-R1-Mod/bidhata-menu/config/bidhata-menu.conf.default" "$BUILD_DIR/sd_card/bidhata-menu.conf"

# 3. Setup isolated build directory in container /tmp
WORK="/tmp/fw_work"
rm -rf "$WORK"
mkdir -p "$WORK/__unpack_tmp" "$WORK/repack_tmp/image_contents/ota_v0"

echo "📦 Extracting firmware package..."
7z x -o"$WORK/__unpack_tmp" "$UPT_PATH" >/dev/null

cat "$WORK/__unpack_tmp/ota_v0/xImage."* > "$WORK/xImage"
cat "$WORK/__unpack_tmp/ota_v0/rootfs.squashfs."* > "$WORK/rootfs.squashfs"

echo "📦 Extracting SquashFS filesystem..."
unsquashfs -f -d "$WORK/squashfs-root" "$WORK/rootfs.squashfs" >/dev/null
rm -rf "$WORK/__unpack_tmp" "$WORK/rootfs.squashfs"

# 4. Patch rootfs with Bidhata Boot Menu
echo "💉 Injecting Bidhata Boot Menu patch..."
"$BUILD_DIR/Hiby-R1-Mod/bidhata-menu/patch/bidhata-patch.sh" "$WORK/squashfs-root"

# 5. Inject Doom Executable & Launcher
echo "🚀 Injecting Doom binary and launcher..."
cp "$BUILD_DIR/fbdoom_src/doom" "$WORK/squashfs-root/usr/bin/doom"
chmod 755 "$WORK/squashfs-root/usr/bin/doom"

cp "$BUILD_DIR/scripts/doom-launcher.sh" "$WORK/squashfs-root/usr/bin/doom-launcher.sh"
chmod 755 "$WORK/squashfs-root/usr/bin/doom-launcher.sh"

# Ensure bidhata-menu.conf in rootfs contains DOOM entry
if [[ -f "$WORK/squashfs-root/usr/bin/bidhata-menu.conf" ]]; then
    if ! grep -q "DOOM" "$WORK/squashfs-root/usr/bin/bidhata-menu.conf"; then
        echo "DOOM|STRIP|run|/usr/bin/doom-launcher.sh|" >> "$WORK/squashfs-root/usr/bin/bidhata-menu.conf"
    fi
fi

# 6. Repack SquashFS & Build ISO UPT
echo "⚙️ Repacking SquashFS rootfs..."
mksquashfs "$WORK/squashfs-root" "$WORK/new_rootfs.squashfs" -comp lzo -all-root >/dev/null

echo "⚙️ Hashing and chunking firmware..."
OTA_DIR="$WORK/repack_tmp/image_contents/ota_v0"

# Chunk file helper
chunk_and_hash() {
    local src="$1"
    local name="$2"
    
    cd "$OTA_DIR"
    split -b 512k "$src" --numeric-suffixes=0 -a 4 "${name}."
    local full_md5=$(md5sum "$src" | awk '{print $1}')
    local full_size=$(stat -c%s "$src")
    
    local meta_file="ota_md5_${name}.${full_md5}"
    > "$meta_file"
    
    local md5="$full_md5"
    for part in $(ls ${name}.[0-9]* | sort); do
        local md5next=$(md5sum "$part" | awk '{print $1}')
        echo "$md5next" >> "$meta_file"
        mv "$part" "${part}.${md5}"
        md5="$md5next"
    done
    
    echo "$full_size $full_md5"
}

read r_size r_md5 < <(chunk_and_hash "$WORK/new_rootfs.squashfs" "rootfs.squashfs")
read k_size k_md5 < <(chunk_and_hash "$WORK/xImage" "xImage")

cat <<EOF > "$OTA_DIR/ota_update.in"
ota_version=0

img_type=kernel
img_name=xImage
img_size=$k_size
img_md5=$k_md5

img_type=rootfs
img_name=rootfs.squashfs
img_size=$r_size
img_md5=$r_md5
EOF

touch "$OTA_DIR/ota_v0.ok"
echo "current_version=0" > "$WORK/repack_tmp/image_contents/ota_config.in"

echo "⚙️ Building final .upt firmware ISO..."
cd "$WORK/repack_tmp/image_contents"
genisoimage -f -U -J -joliet-long -r -allow-lowercase -allow-multidot -o "$OUT_UPT" . >/dev/null 2>&1

rm -rf "$WORK"

if [[ -f "$OUT_UPT" ]]; then
    echo "=========================================="
    echo "🎉 SUCCESS! Modified firmware created:"
    echo "   📍 $OUT_UPT"
    echo "=========================================="
else
    echo "❌ Error: Failed to generate $OUT_UPT"
    exit 1
fi
