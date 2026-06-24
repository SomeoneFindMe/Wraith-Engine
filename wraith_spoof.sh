#!/bin/bash

# ==========================================
# VIBRANT COLOR PALETTE
# ==========================================
C='\033[1;36m'
M='\033[1;35m'
G='\033[1;32m'
Y='\033[1;33m'
W='\033[1;37m'
R='\033[1;31m'
B='\033[1;34m'
NC='\033[0m'

# ==========================================
# CREATOR VARIABLES
# ==========================================
MY_NAME="𑲭𑲭𑲭𑲭𑲭𑲭𑲭𑲭◄⏤‌‌🦋꯭𝆺𝅥⃝꯭S‌‌‌‌‌‌om‌‌‌‌‌‌‌‌‌‌‌‌‌e‌o‌‌‌‌‌‌‌‌‌‌‌‌‌‌‌‌‌‌n‌‌e⏤‌‌🦋꯭"
TG_LINK="https://t.me/NextGenModsOfficial"
YT_LINK="https://youtube.com/@nextgenmodsofficial"

clear

# ==========================================
# RAM + CPU DETECTION
# ==========================================
TOTAL_RAM=$(free -m | awk '/^Mem:/{print $2}')
if   [ "$TOTAL_RAM" -le 4500 ]; then RAM_LIMIT="700M"
elif [ "$TOTAL_RAM" -le 8500 ]; then RAM_LIMIT="1200M"
else                                  RAM_LIMIT="2500M"
fi

CPU_CORES=$(nproc 2>/dev/null || echo 2)
MAX_JOBS=$(( CPU_CORES > 1 ? CPU_CORES - 1 : 1 ))

# ==========================================
# FIXED PATHS
# ==========================================
WORK_DIR="$HOME/Wraith-Engine"
APKTOOL="$WORK_DIR/tools/apktool.jar"
KEYSTORE="$WORK_DIR/tools/debug.keystore"
BRAIN="$WORK_DIR/tools/brain_spoof.py"

# ==========================================
# HEADER
# ==========================================
echo -e "${C}╭──────────────────────────────────────────────╮${NC}"
echo -e "${C}│${NC} ${M}      ℕ 𝔼 𝕏 𝕋 𝔾 𝔼 ℕ  𝕄 𝕆 𝔻 𝕊            ${NC}${C}│${NC}"
echo -e "${C}│${NC} ${Y}       P r o j e c t   W r a i t h  V 2    ${NC}${C}│${NC}"
echo -e "${C}│${NC} ${B}         ⚡ A N D R O I D  T V  ⚡           ${NC}${C}│${NC}"
echo -e "${C}╰──────────────────────────────────────────────╯${NC}"
echo -e "${C}│${NC} ${M}◈ CREATOR : ${NC}${Y}$MY_NAME${NC}"
echo -e "${C}│${NC} ${M}◈ ENGINE  : ${NC}${G}Wraith Spoof V2 — TV Edition${NC}"
echo -e "${C}│${NC} ${M}◈ RAM     : ${NC}${W}Xmx${RAM_LIMIT} Allocated${NC}"
echo -e "${C}│${NC} ${M}◈ CORES   : ${NC}${W}${CPU_CORES} detected → ${MAX_JOBS} parallel jobs${NC}"
echo -e "${C}╰──────────────────────────────────────────────${NC}"
echo ""

# ==========================================
# DEPENDENCY CHECK
# ==========================================
MISSING=0
for dep in python java apksigner; do
    if ! command -v "$dep" &>/dev/null; then
        echo -e "${R} [!] Missing: $dep${NC}"
        MISSING=1
    fi
done
if [ "$MISSING" -eq 1 ]; then
    echo -e "${C} [*] Installing missing packages...${NC}"
    pkg update -y >/dev/null 2>&1
    pkg install python openjdk-21 apksigner -y >/dev/null 2>&1
fi

[ ! -f "$APKTOOL"  ] && echo -e "${R} [ERROR] apktool.jar missing from $WORK_DIR/tools/${NC}" && exit 1
[ ! -f "$KEYSTORE" ] && echo -e "${R} [ERROR] debug.keystore missing from $WORK_DIR/tools/${NC}" && exit 1
[ ! -f "$BRAIN"    ] && echo -e "${R} [ERROR] brain_spoof.py missing from $WORK_DIR/tools/${NC}" && exit 1

# ==========================================
# SPINNER
# ==========================================
run_spinner() {
    local msg="$1"
    local color="$2"
    local pid="$3"
    local progress=0
    local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0
    while kill -0 "$pid" 2>/dev/null; do
        progress=$(( progress + 3 < 98 ? progress + 3 : 98 ))
        local s="${spin:$((i % ${#spin})):1}"
        echo -ne "${color}│${NC} ${C}${s}${NC} ${msg}... ${W}${progress}%${NC}\r"
        sleep 0.15
        i=$(( i + 1 ))
    done
    wait "$pid"
    echo -e "${color}│${NC} ${G}✔${NC} ${msg}... ${G}100%${NC}               "
}

# ==========================================
# PHASE 1: INPUT
# ==========================================
echo -e "${Y}╭─── [ PHASE 1: TARGET ] ───────────────────────${NC}"
read -p "$(echo -e ${Y}"│"${NC}" ${Y}> Target .apk path : ${NC}")" RAW_PATH
APK_PATH="${RAW_PATH%\"}"
APK_PATH="${APK_PATH#\"}"
APK_PATH="${APK_PATH%\'}"
APK_PATH="${APK_PATH#\'}"

if [ ! -f "$APK_PATH" ]; then
    echo -e "${Y}│${NC} ${R}[ERROR] APK not found: $APK_PATH${NC}"
    echo -e "${Y}╰───────────────────────────────────────────────${NC}"
    exit 1
fi

echo -e "${Y}│${NC}"
read -p "$(echo -e ${Y}"│"${NC}" ${Y}> How many spoofed APKs to generate? : ${NC}")" APK_COUNT
if ! [[ "$APK_COUNT" =~ ^[1-9][0-9]*$ ]]; then
    echo -e "${Y}│${NC} ${R}[ERROR] Enter a valid number (1 or more)${NC}"
    exit 1
fi

# OUTPUT = same folder as input APK
APK_NAME=$(basename "$APK_PATH" .apk)
OUTPUT_DIR=$(dirname "$(realpath "$APK_PATH")")
HISTORY_JSON="$OUTPUT_DIR/${APK_NAME}_spoof_history.json"
DECOMPILED_BASE="$WORK_DIR/${APK_NAME}_base"

echo -e "${Y}│${NC}"
echo -e "${Y}│${NC} ${W}APK     : ${G}${APK_NAME}.apk${NC}"
echo -e "${Y}│${NC} ${W}Count   : ${G}${APK_COUNT} variants${NC}"
echo -e "${Y}│${NC} ${W}Output  : ${G}${OUTPUT_DIR}${NC}"
echo -e "${Y}│${NC} ${W}History : ${G}${HISTORY_JSON}${NC}"
echo -e "${Y}╰───────────────────────────────────────────────${NC}"
echo ""

# ==========================================
# PHASE 2: DECOMPILE ONCE
# ==========================================
echo -e "${M}╭─── [ PHASE 2: DECOMPILE — ONCE ONLY ] ────────${NC}"
rm -rf "$DECOMPILED_BASE" 2>/dev/null

java -Xmx${RAM_LIMIT} -jar "$APKTOOL" d -r -q -f "$APK_PATH" -o "$DECOMPILED_BASE" >/dev/null 2>&1 &
run_spinner "Extracting APK Architecture" "${M}" $!

if [ ! -d "$DECOMPILED_BASE/smali" ]; then
    echo -e "${M}│${NC} ${R}[ERROR] Decompile failed — APK may be protected${NC}"
    echo -e "${M}╰───────────────────────────────────────────────${NC}"
    exit 1
fi

echo -e "${M}│${NC} ${G}[✔] Base decompile complete. Source locked in.${NC}"
echo -e "${M}╰───────────────────────────────────────────────${NC}"
echo ""

# ==========================================
# PRE-GENERATE → APPEND TO HISTORY JSON
# ==========================================
echo -e "${B}╭─── [ PRE-GENERATING SPOOF VALUES ] ────────────${NC}"
python "$BRAIN" --pregenerate "$APK_COUNT" --append "$HISTORY_JSON"
TOTAL_SETS=$(python -c "import json; d=json.load(open('$HISTORY_JSON')); print(len(d))" 2>/dev/null || echo "?")
echo -e "${B}│${NC} ${G}[✔] Generated $APK_COUNT new sets${NC}"
echo -e "${B}│${NC} ${W}Total in history : ${G}${TOTAL_SETS}${NC}"
echo -e "${B}│${NC} ${W}Saved to         : ${G}${HISTORY_JSON}${NC}"
echo -e "${B}╰───────────────────────────────────────────────${NC}"
echo ""

# ==========================================
# PHASE 3: PARALLEL BUILD ENGINE
# ==========================================
echo -e "${B}╭─── [ PHASE 3: PARALLEL BUILD ENGINE ] ────────${NC}"
echo -e "${B}│${NC} ${W}Launching ${G}${APK_COUNT}${W} builds | ${G}${MAX_JOBS}${W} at a time${NC}"
echo -e "${B}│${NC}"

COMPLETED=0
FAILED=0
ACTIVE_JOBS=0

build_variant() {
    local INDEX="$1"
    local VARIANT_DIR="$WORK_DIR/${APK_NAME}_v${INDEX}"
    local UNSIGNED="$WORK_DIR/${APK_NAME}_v${INDEX}_unsigned.apk"
    local FINAL="$OUTPUT_DIR/${APK_NAME}_Spoofed_v${INDEX}.apk"
    local LOG="$WORK_DIR/tools/build_${INDEX}.log"

    cp -r "$DECOMPILED_BASE" "$VARIANT_DIR" 2>/dev/null

    python "$BRAIN" --patch "$VARIANT_DIR" --index "$INDEX" \
        --pregenfile "$HISTORY_JSON" >> "$LOG" 2>&1

    java -Xmx${RAM_LIMIT} -jar "$APKTOOL" b -q -f "$VARIANT_DIR" -o "$UNSIGNED" \
        >> "$LOG" 2>&1

    if [ ! -f "$UNSIGNED" ]; then
        echo -e "${B}│${NC} ${R}[✘] Variant #${INDEX} — Build failed${NC}"
        rm -rf "$VARIANT_DIR" "$LOG" 2>/dev/null
        return 1
    fi

    apksigner sign \
        --ks "$KEYSTORE" \
        --ks-pass pass:android \
        --key-pass pass:android \
        --v1-signing-enabled true \
        --v2-signing-enabled true \
        --out "$FINAL" \
        "$UNSIGNED" >> "$LOG" 2>&1

    rm -f "$UNSIGNED" 2>/dev/null
    rm -rf "$VARIANT_DIR" "$LOG" 2>/dev/null

    if [ -f "$FINAL" ]; then
        echo -e "${B}│${NC} ${G}[✔] Variant #${INDEX} → $(basename $FINAL)${NC}"
        return 0
    else
        echo -e "${B}│${NC} ${R}[✘] Variant #${INDEX} — Sign failed${NC}"
        return 1
    fi
}

declare -A JOB_PIDS
for i in $(seq 1 "$APK_COUNT"); do
    while [ "${ACTIVE_JOBS}" -ge "${MAX_JOBS}" ]; do
        for pid in "${!JOB_PIDS[@]}"; do
            if ! kill -0 "$pid" 2>/dev/null; then
                wait "$pid" && COMPLETED=$(( COMPLETED + 1 )) || FAILED=$(( FAILED + 1 ))
                unset JOB_PIDS[$pid]
                ACTIVE_JOBS=$(( ACTIVE_JOBS - 1 ))
            fi
        done
        sleep 0.1
    done
    build_variant "$i" &
    JOB_PIDS[$!]="$i"
    ACTIVE_JOBS=$(( ACTIVE_JOBS + 1 ))
done

for pid in "${!JOB_PIDS[@]}"; do
    wait "$pid" && COMPLETED=$(( COMPLETED + 1 )) || FAILED=$(( FAILED + 1 ))
done

echo -e "${B}│${NC}"
echo -e "${B}│${NC} ${G}[✔] Completed : ${COMPLETED}${NC}  ${R}[✘] Failed : ${FAILED}${NC}"
echo -e "${B}╰───────────────────────────────────────────────${NC}"
echo ""

rm -rf "$DECOMPILED_BASE" 2>/dev/null

# ==========================================
# DONE
# ==========================================
echo -e "${G}╭──────────────────────────────────────────────╮${NC}"
echo -e "${G}│${NC} ${W}    ⚡  P R O D U C T I O N  D O N E  ⚡    ${NC}${G}│${NC}"
echo -e "${G}╰──────────────────────────────────────────────╯${NC}"
echo -e " ${G}APKs    →${NC} ${W}${OUTPUT_DIR}${NC}"
echo -e " ${G}History →${NC} ${W}${HISTORY_JSON}${NC}"
echo ""

termux-open-url "$TG_LINK" 2>/dev/null
sleep 1
termux-open-url "$YT_LINK" 2>/dev/null
