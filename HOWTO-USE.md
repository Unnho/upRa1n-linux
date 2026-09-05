# How to use upRa1n-linux

Tethered dualboot / restore iOS 18 on **iPad 6 (Wi-Fi J71bAP / Cellular J72bAP)** from Linux.
Port of [Zer0xDev/upRa1n](https://github.com/Zer0xDev/upRa1n) — same flow, Linux tooling.

## 0. What you need

- iPad 6 already on **iPadOS 17.7.10 or 17.7.11** (Settings → General → About). Nothing else is supported as a starting point.
- If Cellular: activate the SIM/eSIM in iOS 17 **before** you start.
- A Linux PC (x86_64 or arm64) with a real USB port + cable. 25 GB free for unpacking, 5 GB free for staging.
- The iPad 6 data **will be touched** — back it up. `restore` wipes iOS 17 at the end; `dualboot` keeps both.

## 1. Install system dependencies

```bash
./install-deps.sh
# Debian/Ubuntu: build tools, clang, libusb, libssl, libimobiledevice-utils,
# irecovery, libusbmuxd-tools, usbmuxd, python3-pip
python3 -m venv venv
./venv/bin/pip install colorama art paramiko tqdm scp requests pyhpke
```

Then put the tools on PATH (prebuilts are `linux-arm64`; rebuild on x86_64 with the
one-liners in `install-deps.sh`):

```bash
sudo cp prebuilt/img4-linux-arm64 /usr/local/bin/img4
sudo cp prebuilt/iBootpatch2-linux-arm64 /usr/local/bin/iBootpatch2
sudo cp prebuilt/devicetree-parse-linux-arm64 /usr/local/bin/devicetree-parse
sudo cp devicetree-repack.py /usr/local/bin/devicetree-repack
# per-arch, download yourself:
#   palera1n       → https://github.com/palera1n/palera1n/releases (palera1n-linux-arm64 or -x86_64)
#   ipsw           → https://github.com/blacktop/ipsw/releases (replaces macOS-only `aea`)
#   turdus_merula  → https://sep.lol (Linux build), rename folder to turdus_merula/
#   pongoterm      → prebuilt/ or: clang -Os PongoOS/scripts/pongoterm.c -DUSE_LIBUSB -lusb-1.0 -o pongoterm
```

## 2. Lay out the folder (same as upstream)

```
upRa1n-linux/
  upRa1n.py  boot.sh  get_key.py  devicetree-repack.py
  <iPad-7-iOS-18-firmware>.ipsw        # any iOS 18 for iPad 7, Wi-Fi or Cellular matching YOUR iPad 6
  17.7.10/  (or 17.7.11/)              # EXTRACTED iPad 6 17.7.10/.11 ipsw, must contain Firmware/
  SSHRD_Script/                        # git clone https://github.com/verygenericname/SSHRD_Script.git
  turdus_merula/                       # Linux build from sep.lol, renamed
```

Download sources:
- iOS 18 IPSW for **iPad 7** (Wi-Fi if your iPad 6 is Wi-Fi, Cellular if Cellular).
- iOS 17.7.10 (or .11) IPSW for **iPad 6** (matching Wi-Fi/Cellular), then `unzip` it into `17.7.10/`.

## 3. Check everything

```bash
./venv/bin/python upRa1n.py boot   # runs the dep check first; stop at the LLB.img4 prompt with Ctrl+C
```

You want: `All dependencies have been installed successfully!`
(`aea` shows the `ipsw` fallback line on Linux — that's expected.)

## 4. Restore / dualboot

```bash
./venv/bin/python upRa1n.py restore    # wipes iOS 17 at the end, ends on iOS 18
./venv/bin/python upRa1n.py dualboot   # keeps both, ends ready to tether-boot either
```

Follow the prompts in order:

1. Pick the iOS 18 `.ipsw`, enter iOS version, pick model (**1 = Wi-Fi J71, 2 = Cellular J72**),
   enter the iPadOS version currently on the device.
2. Script decrypts the `.aea` DMGs via `ipsw` (key from `get_key.py`) → `os.dmg`, `root.dmg`, `app.dmg`.
3. Jailbreak prompt: answer `n` and it runs `palera1n -l` for you, or `y` if already jailbroken.
   Wait 15 s, **reconnect the cable**, wait 15 s (lets usbmuxd re-enumerate).
4. `iproxy 2222 44` starts; NVRAM `p1-fakefs-rootdev` is set over SSH.
5. Put the iPad into **Recovery → DFU** when asked. Script downloads the 17.7 ramdisk
   (`./sshrd.sh 17.7`) and boots it (`./sshrd.sh boot`), then `iproxy 2222 22`.
6. It dumps `disk2.bin`, patches `LLB → LLB.img4` (iBoot64Patcher from `SSHRD_Script/Linux/`,
   then `iBootpatch2 -RF`), builds `kernelcachd` + `devicetred.img4`, uploads SEP/AVE firmware.
7. Root + cryptex DMGs upload (up to ~15 min each — **keep the iPad awake and plugged in**).
8. Device reboots to iOS 17 rootless → jailbreak again with `palera1n -l` when told →
   reconnect cable → `snaputil`/`nvram` fixup → reboot.
9. `dualboot` stops at the boot menu; `restore` continues to delete iOS 17, then both
   end at the tethered-boot step.

## 5. Tethered boot (every reboot)

iOS 18 on iPad 6 is **tethered** — you need the PC each boot:

```bash
./venv/bin/python upRa1n.py boot
# put the iPad into Recovery when asked, press ENTER
sudo sh boot.sh
# when you see 'disconnected', Ctrl+C (restore path), then continue prompts
```

What `boot.sh` does: `turdusra1n -D` (download mode) → `irecovery -f LLB.img4` →
`palera1n -fpV -k Pongo.bin` → pongoterm sends `sep_racer`, `sep-firmware.im4p`,
`checkra1n-kpf-pongo`, `ramdisk.dmg`, `binpack.dmg`, then `bootx`.

## 6. Known issues (same as upstream)

- **Black wallpaper** → set it manually in Settings after joining Wi-Fi.
- **Poor performance** → run https://github.com/flylarb/iOS-Performance-Tweaks/releases/tag/1 on-device.

## Troubleshooting (Linux-specific)

- `No route to host` / SSH refused → iPad changed Wi-Fi (2.4 vs 5 GHz) and got a new IP.
  Find it (`ip neigh`, port-22 scan) and keep the iPad awake; USB must stay plugged for DFU steps.
- `05ac:1281` in `lsusb` = Recovery; `05ac:1227` = DFU (black screen). checkm8 needs **DFU**.
- `Timed out waiting for download mode` after `Checkmate!` → unplug/replug, re-enter DFU, retry.
  (Seen on this box too — usually a cable/USB-hub issue.)
- `aea is not installed` → install `ipsw` (the script uses it automatically once present).
- `devicetree-parse/repack is not installed` → `sudo cp prebuilt/... /usr/local/bin/` (arm64)
  or build: `clang -fblocks … -lBlocksRuntime` (parse) — repack is the included `.py`.
- вдруг `snaputil`/`nvram` errors after reboot → you booted stock iOS, not the palera1n
  jailbreak. Re-run `palera1n -l`, wait, reconnect cable, retry.
