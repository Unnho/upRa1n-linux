#!/bin/sh -e
# upRa1n Linux deps (Debian/Ubuntu, arm64/x86_64)
sudo apt-get update
sudo apt-get install -y build-essential git curl clang libusb-1.0-0-dev \
  libssl-dev liblzfse-dev libimobiledevice-utils irecovery libusbmuxd-tools usbmuxd \
  python3-pip libblocksruntime-dev 2>/dev/null || sudo apt-get install -y build-essential git curl clang libusb-1.0-0-dev \
  libssl-dev libimobiledevice-utils irecovery libusbmuxd-tools usbmuxd python3-pip
pip3 install --break-system-packages colorama art paramiko tqdm scp requests pyhpke 2>/dev/null \
  || pip3 install colorama art paramiko tqdm scp requests pyhpke
echo "[*] Now build from source:"
echo "  img4lib (built OK): make -C img4lib && sudo cp img4 /usr/local/bin/"
echo "  iBootpatch2 ssv-patch (built OK): make && sudo cp iBootpatch2 /usr/local/bin/"
echo "  devicetree-parse/repack: needs clang -fblocks + GNUstep (repack.m) - see README-LINUX"
echo "  aea: NOT portable (Apple PrivateFrameworks) -> use blacktop/ipsw Linux release instead"
echo "  palera1n: https://github.com/palera1n/palera1n/releases (palera1n-linux-arm64/x86_64)"
echo "  pongoterm: clang -Os PongoOS/scripts/pongoterm.c -DUSE_LIBUSB -lusb-1.0 -o pongoterm"
echo "  turdus_merula: Linux build from https://sep.lol -> rename folder to turdus_merula/"
echo "  SSHRD_Script: git clone https://github.com/verygenericname/SSHRD_Script.git (use Linux/ subdir)"
