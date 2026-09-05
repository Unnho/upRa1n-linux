# SSHRD_Script arm64 Builds

Built from source for arm64 (aarch64) Linux:

## Tools Built
- **gaster** → from https://github.com/0x7ff/gaster (libusb target)
- **iBoot64Patcher** → from https://github.com/haiyuidesu/iBoot64Patcher  
- **hfsplus** → from https://github.com/vasi/libdmg-hfsplus
- **irecovery** → system /usr/bin/irecovery
- **iproxy** → system /usr/bin/iproxy
- **jq** → system /usr/bin/jq

## Build Commands

### gaster
```bash
git clone https://github.com/0x7ff/gaster.git
cd gaster
make libusb  # Edit Makefile to remove -static
# OR manually: gcc -DHAVE_LIBUSB gaster.c lzfse.c -o gaster -lusb-1.0 -lcrypto -lzstd -pthread -Os
```

### iBoot64Patcher
```bash
git clone https://github.com/haiyuidesu/iBoot64Patcher.git
cd iBoot64Patcher
make
```

### hfsplus
```bash
git clone https://github.com/vasi/libdmg-hfsplus.git
cd libdmg-hfsplus
mkdir build && cd build
cmake .. && make
# Produces: hfsplus, dmg, hdutil
```

## Still Missing
- **img4tool** → needs libgeneral dependency (complex build)
- **pzb** → unknown source
- **PlistBuddy** → macOS specific
- **sshpass** → available in apt

For img4tool, you may need to use system img4 from xerub/img4lib instead.
