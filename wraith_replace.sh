#!/bin/bash

# 
# VIBRANT COLOR PALETTE
# 
C'\033[1;36m'
M'\033[1;35m'
G'\033[1;32m'
Y'\033[1;33m'
W'\033[1;37m'
R'\033[1;31m'
B'\033[1;34m'
NC'\033[0m'

# 
# CREATOR VARIABLES
# 
MY_NAME"𑲭𑲭𑲭𑲭𑲭𑲭𑲭𑲭◄⏤‌‌🦋꯭𝆺𝅥⃝꯭S‌‌‌‌‌‌om‌‌‌‌‌‌‌‌‌‌‌‌‌e‌o‌‌‌‌‌‌‌‌‌‌‌‌‌‌‌‌‌‌n‌‌e⏤‌‌🦋꯭"
TG_LINK"https://t.me/NextGenModsOfficial"
YT_LINK"https://youtube.com/@nextgenmodsofficial"

clear

# 
# RAM + CPU DETECTION
# 
TOTAL_RAM$(free -m | awk '/^Mem:/{print $2}')
if   [ "$TOTAL_RAM" -le 4500 ]; then RAM_LIMIT"700M"
elif [ "$TOTAL_RAM" -le 8500 ]; then RAM_LIMIT"1200M"
else                                  RAM_LIMIT"2500M"
fi

CPU_CORES$(nproc 2>/dev/null || echo 2)
MAX_JOBS$(( CPU_CORES > 1 ? CPU_CORES - 1 : 1 ))

# 
# FIXED PATHS
# 
WORK_DIR"$HOME/Wraith-Engine"
APKTOOL"$WORK_DIR/tools/apktool.jar"
KEYSTORE"$WORK_DIR/tools/debug.keystore"

# 
# HEADER
# 
echo -e "${C}╭──────────────────────────────────────────────╮${NC}"
echo -e "${C}│${NC} ${M}      ℕ 𝔼 𝕏 𝕋 𝔾 𝔼 ℕ  𝕄 𝕆 𝔻 𝕊            ${NC}${C}│${NC}"
echo -e "${C}│${NC} ${Y}    𝕎 𝕣 𝕒 𝕚 𝕥 𝕙  ℂ 𝕠 𝕣 𝕖  𝕍 𝟛           ${NC}${C}│${NC}"
echo -e "${C}│${NC} ${B}      ⚡ B U L K  R E P L A C E R  ⚡        ${NC}${C}│${NC}"
echo -e "${C}╰──────────────────────────────────────────────╯${NC}"
echo -e "${C}│${NC} ${M}◈ CREATOR : ${NC}${Y}$MY_NAME${NC}"
echo -e "${C}│${NC} ${M}◈ ENGINE  : ${NC}${G}Wraith Core V3 — Master Cache${NC}"
echo -e "${C}│${NC} ${M}◈ RAM     : ${NC}${W}Xmx${RAM_LIMIT} | Cores: ${CPU_CORES} → ${MAX_JOBS} jobs${NC}"
echo -e "${C}╰──────────────────────────────────────────────${NC}"
echo ""

# 
# DEPENDENCY CHECK
# 
[ ! -f "$APKTOOL"  ] && echo -e "${R} [ERROR] apktool.jar missing from $WORK_DIR/tools/${NC}" && exit 1
[ ! -f "$KEYSTORE" ] && echo -e "${R} [ERROR] debug.keystore missing from $WORK_DIR/tools/${NC}" && exit 1
command -v java      >/dev/null 2>&1 || { pkg install openjdk-21 -y >/dev/null 2>&1; }
command -v apksigner >/dev/null 2>&1 || { pkg install apksigner  -y >/dev/null 2>&1; }
command -v python    >/dev/null 2>&1 || { pkg install python      -y >/dev/null 2>&1; }

# 
# SPINNER
# 
run_spinner() {
    local msg"$1" color"$2" pid"$3"
    local progress0
    local spin'⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i0
    while kill -0 "$pid" 2>/dev/null; do
        progress$(( progress + 3 < 98 ? progress + 3 : 98 ))
        local s"${spin:$((i % ${#spin})):1}"
        echo -ne "${color}│${NC} ${C}${s}${NC} ${msg}... ${W}${progress}%${NC}\r"
        sleep 0.15
        i$(( i + 1 ))
    done
    wait "$pid"
    echo -e "${color}│${NC} ${G}✔${NC} ${msg}... ${G}100%${NC}               "
}

# 
# PHASE 1: COLLECT STRING PAIRS
# 
SEARCH_ARR()
REPLACE_ARR()

echo -e "${G}╭─── [ PHASE 1: COLLECT STRINGS ] ──────────────${NC}"
echo -e "${G}│${NC} ${W}Enter search→replace pairs. Press ENTER alone to finish.${NC}"
echo -e "${G}│${NC}"

PAIR_COUNT1
while true; do
    read -p "$(echo -e ${Y}"│ [Pair #${PAIR_COUNT}]${NC} ${W}Search string  : ${NC}")" RAW_SEARCH
    CLEAN_SEARCH"${RAW_SEARCH#\"}"; CLEAN_SEARCH"${CLEAN_SEARCH%\"}"
    CLEAN_SEARCH"${CLEAN_SEARCH#\'}"; CLEAN_SEARCH"${CLEAN_SEARCH%\'}"

    if [ -z "$CLEAN_SEARCH" ] || [[ "${CLEAN_SEARCH^^}"  "DONE" ]]; then
        break
    fi

    read -p "$(echo -e ${Y}"│ [Pair #${PAIR_COUNT}]${NC} ${G}Replace string : ${NC}")" RAW_REPLACE
    CLEAN_REPLACE"${RAW_REPLACE#\"}"; CLEAN_REPLACE"${CLEAN_REPLACE%\"}"
    CLEAN_REPLACE"${CLEAN_REPLACE#\'}"; CLEAN_REPLACE"${CLEAN_REPLACE%\'}"

    SEARCH_ARR+("$CLEAN_SEARCH")
    REPLACE_ARR+("$CLEAN_REPLACE")
    echo -e "${G}│${NC} ${G}  ✔ Saved: \"${CLEAN_SEARCH}\" ➔ \"${CLEAN_REPLACE}\"${NC}"
    echo -e "${G}│${NC}"
    PAIR_COUNT$(( PAIR_COUNT + 1 ))
done
echo -e "${G}╰───────────────────────────────────────────────${NC}"
echo ""

if [ ${#SEARCH_ARR[@]} -eq 0 ]; then
    echo -e "${R} [!] No pairs entered. Exiting.${NC}"
    exit 1
fi

echo -e "${G} [✔] ${#SEARCH_ARR[@]} pair(s) collected.${NC}"
echo ""

# 
# PHASE 2: TARGET APK + COUNT
# 
echo -e "${Y}╭─── [ PHASE 2: TARGET ] ───────────────────────${NC}"
read -p "$(echo -e ${Y}"│${NC} ${Y}> Target .apk path : ${NC}")" RAW_PATH
APK_PATH"${RAW_PATH#\"}"; APK_PATH"${APK_PATH%\"}"
APK_PATH"${APK_PATH#\'}"; APK_PATH"${APK_PATH%\'}"

if [ ! -f "$APK_PATH" ]; then
    echo -e "${Y}│${NC} ${R}[ERROR] APK not found: $APK_PATH${NC}"
    echo -e "${Y}╰───────────────────────────────────────────────${NC}"
    exit 1
fi

echo -e "${Y}│${NC}"
read -p "$(echo -e ${Y}"│${NC} ${Y}> How many APK variants to build? : ${NC}")" APK_COUNT
if ! [[ "$APK_COUNT" ~ ^[1-9][0-9]*$ ]]; then
    echo -e "${Y}│${NC} ${R}[ERROR] Enter a valid number (1 or more)${NC}"
    exit 1
fi

# OUTPUT  same folder as input APK
APK_NAME$(basename "$APK_PATH" .apk)
OUTPUT_DIR$(dirname "$(realpath "$APK_PATH")")
MASTER_DIR"$WORK_DIR/${APK_NAME}_MASTER"

echo -e "${Y}│${NC}"
echo -e "${Y}│${NC} ${W}APK     : ${G}${APK_NAME}.apk${NC}"
echo -e "${Y}│${NC} ${W}Pairs   : ${G}${#SEARCH_ARR[@]} replacement(s)${NC}"
echo -e "${Y}│${NC} ${W}Count   : ${G}${APK_COUNT} variant(s)${NC}"
echo -e "${Y}│${NC} ${W}Output  : ${G}${OUTPUT_DIR}${NC}"
echo -e "${Y}╰───────────────────────────────────────────────${NC}"
echo ""

# 
# PHASE 3: MASTER TEMPLATE (decompile once)
# 
echo -e "${M}╭─── [ PHASE 3: MASTER TEMPLATE ] ──────────────${NC}"

if [ ! -d "$MASTER_DIR/smali" ]; then
    echo -e "${M}│${NC} ${Y}[INFO] No master found. Decompiling once...${NC}"
    rm -rf "$MASTER_DIR" 2>/dev/null
    java -Xmx${RAM_LIMIT} -jar "$APKTOOL" d -r -q -f "$APK_PATH" -o "$MASTER_DIR" >/dev/null 2>&1 &
    run_spinner "Extracting Master Blueprint" "${M}" $!

    if [ ! -d "$MASTER_DIR/smali" ]; then
        echo -e "${M}│${NC} ${R}[ERROR] Decompile failed — APK may be protected${NC}"
        echo -e "${M}╰───────────────────────────────────────────────${NC}"
        exit 1
    fi
    echo -e "${M}│${NC} ${G}[✔] Master Template built and cached.${NC}"
else
    echo -e "${M}│${NC} ${G}[✔] Master Template already cached — skipping decompile.${NC}"
fi

echo -e "${M}╰───────────────────────────────────────────────${NC}"
echo ""

# 
# PHASE 4: PARALLEL BUILD ENGINE
# 
echo -e "${B}╭─── [ PHASE 4: PARALLEL BUILD ENGINE ] ────────${NC}"
echo -e "${B}│${NC} ${W}Launching ${G}${APK_COUNT}${W} build(s) | ${G}${MAX_JOBS}${W} parallel jobs${NC}"
echo -e "${B}│${NC}"

COMPLETED0
FAILED0
ACTIVE_JOBS0

build_variant() {
    local INDEX"$1"
    local CLONE_DIR"$WORK_DIR/${APK_NAME}_clone_${INDEX}"
    local UNSIGNED"$WORK_DIR/${APK_NAME}_unsigned_${INDEX}.apk"
    local FINAL"$OUTPUT_DIR/${APK_NAME}_Modded_v${INDEX}.apk"
    local LOG"$WORK_DIR/${APK_NAME}_build_${INDEX}.log"

    # Fast clone from master
    cp -r "$MASTER_DIR" "$CLONE_DIR" 2>/dev/null

    # Python-based safe string replacement (no regex breakage)
    python - "$CLONE_DIR" << PYEOF
import os, sys

target_dir  sys.argv[1]
exts  (".smali", ".xml", ".json", ".txt", ".properties")

pairs  [
$(for ((k0; k<${#SEARCH_ARR[@]}; k++)); do
    S"${SEARCH_ARR[$k]//\\/\\\\}"; S"${S//\"/\\\"}"
    R"${REPLACE_ARR[$k]//\\/\\\\}"; R"${R//\"/\\\"}"
    echo "    (\"$S\", \"$R\"),"
done)
]

total  0
for root, dirs, files in os.walk(target_dir):
    dirs[:]  [d for d in dirs if d not in ("lib",)]
    for fname in files:
        if not fname.endswith(exts):
            continue
        fpath  os.path.join(root, fname)
        try:
            with open(fpath, "r", encoding"utf-8", errors"ignore") as f:
                content  f.read()
            modified  content
            for search, replace in pairs:
                modified  modified.replace(search, replace)
            if modified ! content:
                with open(fpath, "w", encoding"utf-8") as f:
                    f.write(modified)
                total + 1
        except Exception:
            continue

print(f"Patched {total} file(s)")
PYEOF

    # Build
    java -Xmx${RAM_LIMIT} -jar "$APKTOOL" b -q -f "$CLONE_DIR" -o "$UNSIGNED" >> "$LOG" 2>&1

    if [ ! -f "$UNSIGNED" ]; then
        echo -e "${B}│${NC} ${R}[✘] Variant #${INDEX} — Build failed${NC}"
        rm -rf "$CLONE_DIR" "$LOG" 2>/dev/null
        return 1
    fi

    # Sign
    apksigner sign \
        --ks "$KEYSTORE" \
        --ks-pass pass:android \
        --key-pass pass:android \
        --out "$FINAL" \
        "$UNSIGNED" >> "$LOG" 2>&1

    if [ ! -f "$FINAL" ]; then
        echo -e "${B}│${NC} ${R}[✘] Variant #${INDEX} — Sign failed${NC}"
        rm -rf "$CLONE_DIR" "$UNSIGNED" "$LOG" 2>/dev/null
        return 1
    fi

    # Cleanup clone + unsigned — keep master + final APK
    rm -rf "$CLONE_DIR" "$UNSIGNED" "$LOG" 2>/dev/null
    echo -e "${B}│${NC} ${G}[✔] Variant #${INDEX} → $(basename $FINAL)${NC}"
    return 0
}

# Parallel runner
declare -A JOB_PIDS
for i in $(seq 1 "$APK_COUNT"); do
    while [ "${ACTIVE_JOBS}" -ge "${MAX_JOBS}" ]; do
        for pid in "${!JOB_PIDS[@]}"; do
            if ! kill -0 "$pid" 2>/dev/null; then
                wait "$pid" && COMPLETED$(( COMPLETED + 1 )) || FAILED$(( FAILED + 1 ))
                unset JOB_PIDS[$pid]
                ACTIVE_JOBS$(( ACTIVE_JOBS - 1 ))
            fi
        done
        sleep 0.1
    done
    build_variant "$i" &
    JOB_PIDS[$!]"$i"
    ACTIVE_JOBS$(( ACTIVE_JOBS + 1 ))
done

for pid in "${!JOB_PIDS[@]}"; do
    wait "$pid" && COMPLETED$(( COMPLETED + 1 )) || FAILED$(( FAILED + 1 ))
done

echo -e "${B}│${NC}"
echo -e "${B}│${NC} ${G}[✔] Completed : ${COMPLETED}${NC}  ${R}[✘] Failed : ${FAILED}${NC}"
echo -e "${B}╰───────────────────────────────────────────────${NC}"
echo ""

# 
# PHASE 5: MASTER CLEANUP CHOICE
# 
echo -e "${G}╭──────────────────────────────────────────────╮${NC}"
echo -e "${G}│${NC} ${W}    ⚡  P R O D U C T I O N  D O N E  ⚡    ${NC}${G}│${NC}"
echo -e "${G}╰──────────────────────────────────────────────╯${NC}"
echo -e "${G} Output → ${OUTPUT_DIR}${NC}"
echo ""

read -p "$(echo -e ${Y}"[?] Delete Master Template to free storage? (OK / ENTER to keep) : "${NC})" CLEANUP

if [[ "${CLEANUP^^}"  "OK" ]]; then
    rm -rf "$MASTER_DIR" 2>/dev/null
    echo -e "${G}[✔] Master Template wiped. Storage reclaimed.${NC}"
else
    echo -e "${G}[✔] Master Template kept → next run will skip decompile.${NC}"
fi

echo ""
termux-open-url "$TG_LINK" 2>/dev/null
sleep 1
termux-open-url "$YT_LINK" 2>/dev/null
