#!/usr/bin/env python3
"""
brain_spoof.py — Wraith Spoof Engine (TV Edition)
Usage:
  python brain_spoof.py --pregenerate <N> --append <path/to/history.json>
  python brain_spoof.py --patch <dir> --index <N> --pregenfile <path/to/history.json>
"""

import sys
import os
import json
import uuid
import random
import string

# ── ANDROID TV BRANDS ────────────────────────────────────────
TV_BRANDS = [
    ("Sony",      "BRAVIA",     ["XR", "X", "W", "A"]),
    ("TCL",       "TCL",        ["4K", "S5", "P8", "R6"]),
    ("Hisense",   "Hisense",    ["U8", "A7", "H9", "E7"]),
    ("Philips",   "Philips",    ["PFL", "PUS", "PFT"]),
    ("Xiaomi",    "MiTV",       ["Pro", "A2", "5X", "4S"]),
    ("Sharp",     "AQUOS",      ["4K", "LC", "HD", "8K"]),
    ("LG",        "LG",         ["OLED", "QNED", "UHD"]),
    ("Toshiba",   "Toshiba",    ["UL", "UF", "UG", "UA"]),
    ("Panasonic", "Panasonic",  ["TX", "HX", "GX", "JX"]),
    ("JVC",       "JVC",        ["LT", "HD", "4K", "FHD"]),
]

TV_ANDROID_VERSIONS = ["9", "10", "11"]

PLACEHOLDERS = [
    "SPOOF_MY_GOOGLE_AD_ID",
    "SPOOF_MY_IMEI_NUMBER",
    "SPOOF_MY_ANDROID_ID",
    "SPOOF_MY_MODEL_NAME",
    "SPOOF_MY_DEVICE_NAME",
    "SPOOF_MY_SERIAL_NUMBER",
    "SPOOF_MY_FINGERPRINT",
    "SPOOF_MY_ANDROID_VERSION",
]

# ── GENERATORS ───────────────────────────────────────────────

def rand_uuid():
    return str(uuid.uuid4())

def rand_imei():
    TACS = ["35674009", "35913108", "86800003", "86498602",
            "35220810", "86800604", "35299406", "86380203"]
    tac = random.choice(TACS)
    serial = "".join([str(random.randint(0, 9)) for _ in range(6)])
    base = tac + serial
    total = 0
    for i, d in enumerate(reversed(base)):
        n = int(d)
        if i % 2 == 1:
            n *= 2
            if n > 9:
                n -= 9
        total += n
    check = (10 - (total % 10)) % 10
    return base + str(check)

def rand_android_id():
    return "".join(random.choices("0123456789abcdef", k=16))

def rand_tv_model():
    brand, codename, series_list = random.choice(TV_BRANDS)
    series = random.choice(series_list)
    number = random.randint(40, 75)
    return f"{brand} {series}{number}"

def rand_tv_device():
    brand, codename, series_list = random.choice(TV_BRANDS)
    number = random.randint(100, 999)
    return f"{codename.lower()}{number}"

def rand_serial():
    brand, codename, series_list = random.choice(TV_BRANDS)
    prefix = brand[:3].upper()
    suffix = "".join(random.choices(string.ascii_uppercase + string.digits, k=8))
    return f"{prefix}{suffix}"

def rand_android_version():
    return random.choice(TV_ANDROID_VERSIONS)

def rand_fingerprint(model, device, ver):
    brand = model.split()[0]
    build_id = f"RTP{random.randint(1,12):02d}{random.randint(1,28):02d}.{random.randint(100,999):03d}"
    date_code = str(random.randint(200101, 231201))
    return f"{brand}/{device}/{device}:{ver}/{build_id}/{date_code}:user/release-keys"

def generate_one_set():
    ver    = rand_android_version()
    device = rand_tv_device()
    model  = rand_tv_model()
    return {
        "SPOOF_MY_GOOGLE_AD_ID":    rand_uuid(),
        "SPOOF_MY_IMEI_NUMBER":     rand_imei(),
        "SPOOF_MY_ANDROID_ID":      rand_android_id(),
        "SPOOF_MY_MODEL_NAME":      model,
        "SPOOF_MY_DEVICE_NAME":     device,
        "SPOOF_MY_SERIAL_NUMBER":   rand_serial(),
        "SPOOF_MY_FINGERPRINT":     rand_fingerprint(model, device, ver),
        "SPOOF_MY_ANDROID_VERSION": ver,
    }

# ── PATCH DIRECTORY ──────────────────────────────────────────

def patch_directory(target_dir, values):
    exts = (".smali", ".xml", ".json", ".txt", ".properties")
    patched_files = 0
    for root, dirs, files in os.walk(target_dir):
        # Skip irrelevant folders for speed
        dirs[:] = [d for d in dirs if d not in ("lib", "assets", "res/raw")]
        for fname in files:
            if not fname.endswith(exts):
                continue
            fpath = os.path.join(root, fname)
            try:
                with open(fpath, "r", encoding="utf-8", errors="ignore") as f:
                    content = f.read()
                if not any(p in content for p in PLACEHOLDERS):
                    continue
                modified = content
                for placeholder, replacement in values.items():
                    modified = modified.replace(placeholder, replacement)
                if modified != content:
                    with open(fpath, "w", encoding="utf-8") as f:
                        f.write(modified)
                    patched_files += 1
            except Exception:
                continue
    return patched_files

# ── LOAD / SAVE HISTORY ──────────────────────────────────────

def load_history(path):
    if os.path.isfile(path):
        try:
            with open(path, "r") as f:
                return json.load(f)
        except Exception:
            return []
    return []

def save_history(path, data):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w") as f:
        json.dump(data, f, indent=2)

# ── MAIN ─────────────────────────────────────────────────────

def main():
    args = sys.argv[1:]

    # ── MODE: pregenerate
    if "--pregenerate" in args:
        idx = args.index("--pregenerate")
        count = int(args[idx + 1]) if idx + 1 < len(args) else 1
        new_sets = [generate_one_set() for _ in range(count)]

        if "--append" in args:
            ai = args.index("--append")
            save_path = args[ai + 1]
            existing = load_history(save_path)
            combined = existing + new_sets
            save_history(save_path, combined)
            print(f"[brain] Saved {len(new_sets)} new sets. Total history: {len(combined)}")
        else:
            print(json.dumps(new_sets, indent=2))
        return

    # ── MODE: patch
    if "--patch" in args:
        idx = args.index("--patch")
        directory = args[idx + 1]

        # Which variant index (1-based from shell)
        index = 0
        if "--index" in args:
            i = args.index("--index")
            index = int(args[i + 1]) - 1  # convert to 0-based

        # Load values from history
        pregenfile = None
        if "--pregenfile" in args:
            i = args.index("--pregenfile")
            pregenfile = args[i + 1]

        if pregenfile and os.path.isfile(pregenfile):
            history = load_history(pregenfile)
            # Use last N entries (most recent session)
            # index into the tail of history
            tail_start = max(0, len(history) - 999)
            tail = history[tail_start:]
            values = tail[index % len(tail)] if tail else generate_one_set()
        else:
            values = generate_one_set()

        count = patch_directory(directory, values)
        print(count)
        return

    # ── LEGACY: called with just directory path
    if len(sys.argv) == 2 and os.path.isdir(sys.argv[1]):
        values = generate_one_set()
        count = patch_directory(sys.argv[1], values)
        print(count)
        return

    print("Usage:", file=sys.stderr)
    print("  python brain_spoof.py --pregenerate <N> --append <history.json>", file=sys.stderr)
    print("  python brain_spoof.py --patch <dir> --index <N> --pregenfile <history.json>", file=sys.stderr)
    sys.exit(1)

if __name__ == "__main__":
    main()
