# 🎮 HiBy R1 Doom Port & Firmware Mod

[![Architecture](https://img.shields.io/badge/Architecture-MIPS32r2%20(mipsel)-blue.svg)](https://gitee.com/baijz/ingenic-toolchain)
[![SoC](https://img.shields.io/badge/SoC-Ingenic%20X1600E-orange.svg)](https://www.ingenic.com/)
[![OS](https://img.shields.io/badge/OS-HiBy%20OS%20%2F%20Linux%204.4-green.svg)](https://store.hiby.com/)
[![License: GPL v2.0](https://img.shields.io/badge/License-GPL%20v2.0-yellow.svg)](LICENSE)

🌐 [English Version](README.md) | **Українська версія**

Робочий порт гри **Doom** для портативного аудіоплеєра **HiBy R1**. Включає оптимізований під екран 480x800 рушій `fbdoom`, наекранне сенсорне керування, підтримку бічних кнопок та інтегроване меню запуску `bidhata-menu`.

---

## ⚡️ Швидке встановлення

Для запуску гри **не потрібно нічого компілювати** — використовуйте вже готовий файл прошивки `r1_doom_mod.upt`.

1. **Скопіюйте файли на MicroSD карту:**
   - Перейменуйте файл `r1_doom_mod.upt` на `r1.upt` і покладіть у корінь SD-карти.
   - Скопіюйте файл [`sd_card/bidhata-menu.conf`](sd_card/bidhata-menu.conf) у корінь SD-карти.
   - Скопіюйте папку [`sd_card/doom`](sd_card/doom) (із файлом `DOOM1.WAD`) у корінь SD-карти.

   *Структура на SD-картці:*
   ```text
   MicroSD Card/
   ├── r1.upt
   ├── bidhata-menu.conf
   └── doom/
       └── DOOM1.WAD
   ```

2. **Прошийте пристрій:**
   - Вставте карту в HiBy R1.
   - Перейдіть у **System Settings -> System Update** та підтвердіть оновлення.
   - Після перезавантаження у бут-меню оберіть **DOOM**!

---

## 🎮 Керування

```text
+------------------------------------+ (0,0)
|                                    |
|          DOOM GAME VIEW            |
|       (320x200 scaled 1.5x)        |
|             480x300                |
|                                    |
+------------------------------------+ (0,350)
|  [ESC]    [TAB]    [ENTER]   [YES] |  (Меню / Карта / Підтвердження)
+------------------------------------+ (0,430)
|   [UP]   |   [WEAPON]  [USE]       |  (D-Pad Вгору | Зміна зброї | Дія/Двері)
| [L]  [R] |   [ FIRE ]  [RUN]       |  (D-Pad Ліво/Право | Вогонь | Біг)
|  [DOWN]  |                         |  (D-Pad Вниз)
+------------------------------------+ (480,800)
```

- **Гучність + (`KEY_VOLUMEUP`):** Вогонь (Attack / `Ctrl`)
- **Гучність - (`KEY_VOLUMEDOWN`):** Дія / Відкрити двері (Use / `Space`)
- **Живлення (`KEY_POWER`):** Вихід / Меню (`ESC`)

---

## 🛠 Як це створювалось

1. **Портування рушія Doom:**
   - За основу взято порт `fbdoom`, який виводить графіку напряму у Linux Framebuffer (`/dev/fb0`) без SDL/X11. Це забезпечує високий FPS при 64 МБ ОЗП.
   - Написано модуль [`i_hiby_video.c`](fbdoom_src/src/device/i_hiby_video.c), який масштабує картинку 320x200 у 480x300 та малює наекранний сенсорний HUD.
   - Написано модуль [`i_hiby_input.c`](fbdoom_src/src/device/i_hiby_input.c) для зчитування координат сенсорного екрана та подій бічних кнопок через Linux Input Event API (`/dev/input/event*`).

2. **Крос-компіляція під MIPS32r2:**
   - Створено Docker-контейнер ([`Dockerfile.mips`](Dockerfile.mips)) із тулчайном `mipsel-linux-gnu` для збірки статичних бінарників під SoC Ingenic X1600E.

3. **Інтеграція в прошивку HiBy OS:**
   - Інтегровано меню завантаження `bidhata-menu`.
   - Написано скрипт [`scripts/container_build.sh`](scripts/container_build.sh), який розпаковує прошивку `r1.upt`, патчить ініціалізаційні скрипти `/etc/init.d/S92_03_start_music_player`, додає бінарники `doom` і `doom-launcher.sh` у SquashFS rootfs та збирає новий файл прошивки.

*(За бажанням власної збірки прошивки: запустіть `./build_doom_firmware.sh r1.upt`).*

---

## 🤝 Подяки

Ця кастомна прошивка та порт Doom базуються на чудовому проєкті [Hiby R1 Mod від bidhata](https://github.com/bidhata/Hiby-R1-Mod). 
Зокрема, за основу взято реліз: [HibyR11.8b2](https://github.com/bidhata/Hiby-R1-Mod/releases/tag/HibyR11.8b2).

Велика подяка автору за створення кастомного меню завантаження та відкриття можливості запускати власні програми на цьому пристрої!

---

## 🧰 Інструменти та ліцензії

- **Doom Engine (`fbdoom`):** [id Software](https://www.idsoftware.com/) / [stoffera/fbdoom](https://github.com/stoffera/fbdoom) — *GPL v2.0*
- **HiBy R1 Modding Suite (`bidhata-menu`):** [bidhata](https://github.com/bidhata/Hiby-R1-Mod) — *MIT License*
- **MIPS Toolchain (`mipsel-linux-gnu-`):** [Ingenic](https://www.ingenic.com/) / GNU GCC — *GPL v3.0 / LGPL*
- **SquashFS & ISO Tools:** `squashfs-tools`, `genisoimage` — *GPL v2.0*
- **Game Data (`DOOM1.WAD`):** id Software (1993, 1995) — *Shareware License*

---

## 📜 Ліцензія проєкту

Розповсюджується за ліцензією **GNU General Public License v2.0 (GPL-2.0)**.
