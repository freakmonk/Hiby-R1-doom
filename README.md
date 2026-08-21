# 🎮 HiBy R1 Doom Port & Firmware Mod

[![Architecture](https://img.shields.io/badge/Architecture-MIPS32r2%20(mipsel)-blue.svg)](https://gitee.com/baijz/ingenic-toolchain)
[![SoC](https://img.shields.io/badge/SoC-Ingenic%20X1600E-orange.svg)](https://www.ingenic.com/)
[![OS](https://img.shields.io/badge/OS-HiBy%20OS%20%2F%20Linux%204.4-green.svg)](https://store.hiby.com/)
[![License: GPL v2.0](https://img.shields.io/badge/License-GPL%20v2.0-yellow.svg)](LICENSE)

**English Version** | 🌐 [Українська версія](README_ua.md)

A functional port of **Doom** for the **HiBy R1** digital audio player. Features an optimized `fbdoom` engine adapted for the 480x800 display, touchscreen controls, hardware side button mapping, and integrated `bidhata-menu` boot launcher.

---

## ⚡️ Quick Installation

**No compilation required** to play — simply use the pre-compiled `r1_doom_mod.upt` firmware file.

1. **Copy files to MicroSD card:**
   - Rename `r1_doom_mod.upt` to `r1.upt` and place it in the root of the SD card.
   - Copy [`sd_card/bidhata-menu.conf`](sd_card/bidhata-menu.conf) to the root of the SD card.
   - Copy the [`sd_card/doom`](sd_card/doom) folder (containing `DOOM1.WAD`,`doom`) to the root of the SD card.

   *MicroSD card file structure:*
   ```text
   MicroSD Card/
   ├── r1.upt
   ├── bidhata-menu.conf
   └── doom/
       └── DOOM1.WAD
       └── doom
   ```

2. **Flash the device:**
   - Insert the card into your HiBy R1.
   - Go to **System Settings -> System Update** and confirm the update.
   - After reboot, select **DOOM** from the boot menu!

---

## 🎮 Controls

```text
+------------------------------------+ (0,0)
|                                    |
|          DOOM GAME VIEW            |
|       (320x200 scaled 1.5x)        |
|             480x300                |
|                                    |
+------------------------------------+ (0,350)
|  [ESC]    [TAB]    [ENTER]   [YES] |  (Menu / Map / Confirm)
+------------------------------------+ (0,430)
|   [UP]   |   [WEAPON]  [USE]       |  (D-Pad Up | Switch Weapon | Use/Open)
| [L]  [R] |   [ FIRE ]  [RUN]       |  (D-Pad Left/Right | Fire | Run)
|  [DOWN]  |                         |  (D-Pad Down)
+------------------------------------+ (480,800)
```

- **Volume + (`KEY_VOLUMEUP`):** Fire (Attack / `Ctrl`)
- **Volume - (`KEY_VOLUMEDOWN`):** Use / Open Door (`Space`)
- **Power (`KEY_POWER`):** Exit / Menu (`ESC`)

---

## 🛠 How It Was Created

1. **Doom Engine Porting:**
   - Based on `fbdoom`, which renders directly to the Linux Framebuffer (`/dev/fb0`) without SDL/X11, delivering high FPS on 64MB RAM.
   - Implemented [`i_hiby_video.c`](fbdoom_src/src/device/i_hiby_video.c) to scale 320x200 graphics up 1.5x to 480x300 and draw an on-screen touch HUD.
   - Implemented [`i_hiby_input.c`](fbdoom_src/src/device/i_hiby_input.c) to process touchscreen coordinates and hardware button events via Linux Input API (`/dev/input/event*`).

2. **MIPS32r2 Cross-Compilation:**
   - Created a Docker build environment ([`Dockerfile.mips`](Dockerfile.mips)) using `mipsel-linux-gnu-` toolchain to build static binaries for the Ingenic X1600E SoC.

3. **HiBy OS Firmware Integration:**
   - Integrated the `bidhata-menu` boot launcher system.
   - Developed [`scripts/container_build.sh`](scripts/container_build.sh) to extract `r1.upt`, patch init scripts `/etc/init.d/S92_03_start_music_player`, inject `doom` and `doom-launcher.sh` into the SquashFS rootfs, and package the final firmware image.

*(To build custom firmware yourself: run `./build_doom_firmware.sh r1.upt`).*

---

## 🧰 Tools & Licenses

- **Doom Engine (`fbdoom`):** [id Software](https://www.idsoftware.com/) / [stoffera/fbdoom](https://github.com/stoffera/fbdoom) — *GPL v2.0*
- **HiBy R1 Modding Suite (`bidhata-menu`):** [bidhata](https://github.com/bidhata/Hiby-R1-Mod) — *MIT License*
- **MIPS Toolchain (`mipsel-linux-gnu-`):** [Ingenic](https://www.ingenic.com/) / GNU GCC — *GPL v3.0 / LGPL*
- **SquashFS & ISO Tools:** `squashfs-tools`, `genisoimage` — *GPL v2.0*
- **Game Data (`DOOM1.WAD`):** id Software (1993, 1995) — *Shareware License*

---

## 📜 License

Distributed under the **GNU General Public License v2.0 (GPL-2.0)**.