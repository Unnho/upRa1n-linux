#!/usr/bin/env python3
"""Linux replacement for devicetree-repack (repack.m) — pure stdlib.
Usage: devicetree-repack.py <devicetree.json> <output>
Replicates repack.m binary format exactly:
  node: u32 n_props + u32 n_children + props + children
  prop: name[32] + u16 size + u16 flags + data padded to 4
  value: number -> int of prop length; string -> \\xNN escapes decoded
"""
import json, struct, sys

def process_bytes(s: str, length: int) -> bytes:
    out = bytearray()
    i = 0
    raw = s.encode('utf-8')
    while i < len(raw):
        if raw[i:i+1] == b'\\' and raw[i+1:i+2] == b'x':
            out.append(int(raw[i+2:i+4], 16))
            i += 4
        else:
            out.append(raw[i])
            i += 1
    return bytes(out[:length])

def get_prop(prop: dict) -> bytes:
    length = int(prop["length"])
    flags = int(prop.get("flags", 0))
    name = prop["name"].encode('utf-8')[:32].ljust(32, b'\x00')
    head = name + struct.pack('<HH', length, flags)
    val = prop.get("value", "")
    if isinstance(val, (int, float)):
        v = int(val)
        fmt = {1: '<B', 2: '<H', 4: '<I', 8: '<Q'}.get(length)
        if fmt is None:
            raise SystemExit(f"Unhandled int size {length}")
        data = struct.pack(fmt, v & ((1 << (length * 8)) - 1))
    elif isinstance(val, str) and len(val) > 0:
        data = process_bytes(val, length)
    else:
        data = b'\x00' * length
    data = data.ljust((length + 3) & ~0x3, b'\x00')
    return head + data

def get_node(node: list) -> bytes:
    props, kids = [], []
    for sub in node:
        (props if isinstance(sub, dict) else kids).append(sub)
    pbin = [get_prop(p) for p in props]
    kbin = [get_node(k) for k in kids]
    return struct.pack('<II', len(pbin), len(kbin)) + b''.join(pbin) + b''.join(kbin)

def main():
    if len(sys.argv) != 3:
        print(f"Usage: {sys.argv[0]} <devicetree.json> <output>")
        return 1
    with open(sys.argv[1], encoding='utf-8') as f:
        d = json.load(f)
    blob = get_node(d["device-tree"])
    with open(sys.argv[2], 'wb') as f:
        f.write(blob)

if __name__ == "__main__":
    raise SystemExit(main())
