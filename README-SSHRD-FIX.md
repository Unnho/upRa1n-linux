# SSHRD_Script Architecture Fix (arm64)

The bundled SSHRD_Script/Linux tools are x86_64 but this system is arm64.
Replaced with system versions:
- `irecovery` → /usr/bin/irecovery
- `iproxy` → /usr/bin/iproxy  
- `jq` → /usr/bin/jq (installed via apt)

Other tools (gaster, hfsplus, iBoot64Patcher, img4, etc.) may still fail.
For full compatibility, use x86_64 PC or rebuild arm64 versions.
