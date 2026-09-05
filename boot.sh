#!/bin/sh -e
# Linux port of boot.sh
TURDUS_BIN=""
for c in ./turdus_merula/bin/turdusra1n ./turdus_merula/turdusra1n turdusra1n; do
  if [ -x "$c" ]; then TURDUS_BIN="$c"; break; fi
done
if [ -z "$TURDUS_BIN" ]; then echo "[!] turdusra1n not found. Download Linux build from https://sep.lol and place under ./turdus_merula/"; exit 1; fi
echo [*] Entering download mode ...
"$TURDUS_BIN" -D
sleep 2
echo [*] Sending LLB.img4 ...
irecovery -f LLB.img4
sleep 2
echo [*] Booting into pongoOS ...
palera1n -fpV -k Pongo.bin
sleep 3
echo [*] Booting into iOS 18 ...
printf 'fuse lock\n/send %s\nmodload\n/send %s\nsep payload\nsep sep_flag 0x12\nsep pwn\n/send %s\nmodload\npalera1n_flags 0x1\n/send %s\nramdisk\n/send %s\noverlay\nxargs %s\nbootx\n' \
	"sep_racer" \
	"sep-firmware.im4p" \
	"checkra1n-kpf-pongo" \
	"ramdisk.dmg" \
	"binpack.dmg" \
	'serial=3' | pongoterm
