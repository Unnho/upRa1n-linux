# upRa1n-linux

Tethered dualboot/restore iOS 18 on iPad 6 (Wi-Fi / Cellular) — **Linux port** of
[Zer0xDev/upRa1n](https://github.com/Zer0xDev/upRa1n), which is macOS-only upstream.

Device must already be running **iPadOS 17.7.10 or 17.7.11**. Tested host here:
Debian 13 (trixie) aarch64. `prebuilt/` binaries are `linux-arm64`; x86_64 builds
via the same one-line commands in `install-deps.sh`.

## Docs

- **How to use (this port):** [HOWTO-USE.md](HOWTO-USE.md) — install, folder layout, restore/dualboot/boot, troubleshooting.
- Upstream background: [Zer0xDev/upRa1n](https://github.com/Zer0xDev/upRa1n).

## Quick start

```bash
git clone <this-repo> upRa1n-linux && cd upRa1n-linux
./install-deps.sh
python3 -m venv venv && ./venv/bin/pip install colorama art paramiko tqdm scp requests pyhpke
# exact modem-specific firmware layout, same as upstream:
#  - place iPad 7 iOS 18 .ipsw next to upRa1n.py
#  - extract iPad 6 17.7.10/.11 .ipsw into 17.7.10/ (or 17.7.11/)
#  - git clone https://github.com/verygenericname/SSHRD_Script.git
#  - Linux turdus_merula from https://sep.lol -> rename to turdus_merula/
sudo cp prebuilt/*-linux-$(uname -m | sed s/aarch64/arm64/ | sed s/x86_64/amd64/) /usr/local/bin/ 2>/dev/null || true
./venv/bin/python upRa1n.py restore   # or: dualboot | boot
```

Boot helper: `sudo sh boot.sh` (Linux version — finds `turdus_merula/bin/turdusra1n`,
then `irecovery -f LLB.img4`, `palera1n -fpV -k Pongo.bin`, pongoterm sequence).

## What changed vs upstream (macOS → Linux)

| Upstream (macOS) | This port (Linux) |
|---|---|
| `aea` (aeota, Apple PrivateFrameworks, unbuildable on Linux) | `blacktop/ipsw` (`ipsw fw aea --key-val …`), auto-fallback in `upRa1n.py` |
| `SSHRD_Script/Darwin/iBoot64Patcher` hardcoded | auto-selects `SSHRD_Script/Linux/` on Linux |
| `devicetree-parse` (Apple Blocks `^` + `xcrun`) | builds with `clang -fblocks -lBlocksRuntime`, one-line `getprogname` fix (source-identical otherwise) |
| `devicetree-repack` (`repack.m`, Foundation/ObjC) | `devicetree-repack.py` — pure-stdlib reimplementation, byte-identical layout (`u32 n_props/u32 n_children`, `name[32]+u16 size/u16 flags`, 4-byte pad, `\xNN` escapes) |
| `iBootPatch2` probe (capital P, works on case-insensitive APFS) | probes `iBootpatch2`/`iBootPatch2`/`ibootpatch2` |
| `brew`, `killall`, `Finder` wording | `apt` (`install-deps.sh`), `pkill`+`killall`, generic wording |
| `turdusra1n` via `./bin/` | searches `./turdus_merula/bin/`, `./turdus_merula/`, `PATH` (Linux build from sep.lol) |
| dep-check crashes on missing binary (`FileNotFoundError`) | safe probes, clear install hints |

`sep_racer` / `checkra1n-kpf-pongo` are Mach-O Pongo modules that run **on the iPad** —
no port needed. `get_key.py` is pure Python, unchanged.

## Prebuilt binaries (release)

`prebuilt/` + GitHub Release: `img4`, `iBootpatch2` (ssv-patch), `devicetree-parse`,
`pongoterm` (all `linux-arm64`, built on Debian 13/aarch64), plus arch-independent
`devicetree-repack.py`. Get the rest per-arch from their upstreams:
`palera1n` (palera1n-linux-arm64/x86_64), `ipsw` (blacktop), `turdus_merula` (sep.lol),
`libimobiledevice`/`libirecovery` (`apt`).

## Credits

Full credit to the original authors — this repo is a portability shim only:

- **Zer0xDev** — [upRa1n](https://github.com/Zer0xDev/upRa1n) (the entire tool)
- **asdfugil (Nick Chan)** — [original iPad 6 → iPadOS 18 guide](https://github.com/asdfugil/ipad6-ipados18)
- **verygenericname (Nathan)** — [SSHRD_Script](https://github.com/verygenericname/SSHRD_Script)
- **kok3shidoll, Clarity, Mineek** — [turdusra1n](https://sep.lol)
- **Mineek, Nick Chan, Samara, HAHALOSAH** — [palera1n](https://palera.in)
- **crystall1nedev** — [SSV patch](https://github.com/crystall1nedev/ipad6-ipados18/tree/ssv-patch)
- **xerub** — [img4lib](https://github.com/xerub/img4lib)
- **dhinakg** — [aeota](https://github.com/dhinakg/aeota) (macOS original; Linux path uses blacktop/ipsw)
- **khanhduytran0 / Brandon Azad** — [devicetree-parse](https://github.com/khanhduytran0/devicetree-parse.git)
- **blacktop** — [ipsw](https://github.com/blacktop/ipsw) (makes the Linux AEA path possible)
- **kinnay / python-aea contributors** — alternative AEA implementations

## License

Same terms as the respective upstreams (tool scripts follow upRa1n's distribution;
prebuilt binaries are compiled from the sources linked above).
