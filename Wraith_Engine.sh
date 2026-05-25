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
NC='\033[0m'

# ==========================================
# CREATOR VARIABLES
# ==========================================
MY_NAME="𑲭𑲭𑲭𑲭𑲭𑲭𑲭𑲭◄⏤‌‌🦋꯭𝆺𝅥⃝꯭S‌‌‌‌‌‌om‌‌‌‌‌‌‌‌‌‌‌‌‌e‌o‌‌‌‌‌‌‌‌‌‌‌‌‌‌‌‌‌‌n‌‌e⏤‌‌🦋꯭"
GH_LINK="https://github.com/SomeoneFindMe"
TG_LINK="https://t.me/NextGenModsOfficial"
YT_LINK="https://youtube.com/@nextgenmodsofficial"

clear

# ==========================================
# AUTOMATED RAM OPTIMIZATION
# ==========================================
TOTAL_RAM=$(free -m | awk '/^Mem:/{print $2}')
if [ "$TOTAL_RAM" -le 4500 ]; then
    RAM_LIMIT="700M"
elif [ "$TOTAL_RAM" -le 8500 ]; then
    RAM_LIMIT="1200M"
else
    RAM_LIMIT="2500M"
fi

# ==========================================
# NEXTGEN SHIELD HEADER
# ==========================================
echo -e "${C}╭──────────────────────────────────────────╮${NC}"
echo -e "${C}│${NC} ${M}         ℕ 𝔼 𝕏 𝕋 𝔾 𝔼 ℕ 𝕄 𝕆 𝔻 𝕊          ${NC}${C}│${NC}"
echo -e "${C}│${NC} ${Y}        P r o j e c t   W r a i t h      ${NC}${C}│${NC}"
echo -e "${C}╰──────────────────────────────────────────╯${NC}"
echo -e "${C}│${NC} ${M}◈ CREATOR:${NC} ${Y}$MY_NAME${NC}"
echo -e "${C}│${NC} ${M}◈ ENGINE: ${NC} ${G}Wraith Offline V12${NC}"
echo -e "${C}│${NC} ${M}◈ HW RAM: ${NC} ${W}Xmx${RAM_LIMIT} Allocated${NC}"
echo -e "${C}╰───────────────────────────────────────────${NC}"
echo ""

# The exact path based on your screenshot
WORK_DIR="$HOME/Wraith-Engine"
APKTOOL="$WORK_DIR/tools/apktool.jar"
KEYSTORE="$WORK_DIR/tools/debug.keystore"
BRAIN="$WORK_DIR/tools/brain.py"

# ==========================================
# FAST DEPENDENCY CHECK
# ==========================================
if ! command -v python &> /dev/null || ! command -v apksigner &> /dev/null || ! command -v java &> /dev/null; then
    echo -e "${C} [!] Installing required Termux packages (Java/Python)...${NC}"
    pkg update -y > /dev/null 2>&1
    pkg install python openjdk-21 apksigner -y > /dev/null 2>&1
fi

# Strict check with detailed error reporting
if [ ! -f "$APKTOOL" ]; then echo -e "${R} [ERROR] apktool.jar is missing from $WORK_DIR/tools/ ${NC}"; exit 1; fi
if [ ! -f "$KEYSTORE" ]; then echo -e "${R} [ERROR] debug.keystore is missing from $WORK_DIR/tools/ ${NC}"; exit 1; fi
if [ ! -f "$BRAIN" ]; then echo -e "${R} [ERROR] brain.py is missing from $WORK_DIR/tools/ ${NC}"; exit 1; fi

# ==========================================
# ANIMATION LOGIC
# ==========================================
run_spinner() {
    local msg=$1
    local color=$2
    local pid=$3
    local progress=0
    while kill -0 $pid 2>/dev/null; do
        progress=$((progress + 4))
        if [ $progress -ge 99 ]; then progress=99; fi
        echo -ne "${color}│${NC} ${C} [+] ${msg}... ${progress}% \r${NC}"
        sleep 0.2
    done
    wait $pid
    echo -e "${color}│${NC} ${G} [+] ${msg}... 100%                            ${NC}"
}

# ==========================================
# PHASE 1: THE EXECUTION
# ==========================================
echo -e "${Y}╭─── [ PHASE 1: EXTRACTION ] ───────────────${NC}"
read -p "$(echo -e ${Y}"│"${NC} ${Y} " > Target .apk : "${NC})" RAW_PATH
echo -e "${Y}│${NC}"

APK_PATH="${RAW_PATH%\"}"; APK_PATH="${APK_PATH#\"}"; APK_PATH="${APK_PATH%\'}"; APK_PATH="${APK_PATH#\'}"

if [ ! -f "$APK_PATH" ]; then
    echo -e "${Y}│${NC} ${R} [ERROR] Target APK not found!${NC}"
    echo -e "${Y}╰───────────────────────────────────────────${NC}"
    exit 1
fi

EXPORT_DIR=$(dirname "$(realpath "$APK_PATH")")
APK_NAME=$(basename "$APK_PATH" .apk)
DECOMPILED_DIR="$WORK_DIR/$APK_NAME"
UNSIGNED_APK="$WORK_DIR/${APK_NAME}_unsigned.apk"
FINAL_APK="$EXPORT_DIR/${APK_NAME}_Wraith_Mod.apk"

rm -rf "$DECOMPILED_DIR" "$UNSIGNED_APK" 2>/dev/null

java -Xmx$RAM_LIMIT -jar "$APKTOOL" d -r -q -f "$APK_PATH" -o "$DECOMPILED_DIR" > /dev/null 2>&1 &
run_spinner "Extracting APK Architecture" "${Y}" $!

if [ ! -d "$DECOMPILED_DIR/smali" ]; then
    echo -e "${Y}│${NC} ${R} [ERROR] Extraction failed. File corrupted.  ${NC}"
    echo -e "${Y}╰───────────────────────────────────────────${NC}"
    exit 1
else
    echo -e "${Y}│${NC} ${G} [✔] Extraction successful.             ${NC}"
fi
echo -e "${Y}╰───────────────────────────────────────────${NC}"
echo ""

# ==========================================
# PHASE 2: INJECTION & REBUILD
# ==========================================
echo -e "${M}╭─── [ PHASE 2: TRANSLATION & INJECTION ] ──${NC}"

python "$BRAIN" "$DECOMPILED_DIR" > "$WORK_DIR/tools/patch.log" 2>&1 &
run_spinner "Injecting Master Regex Payload" "${M}" $!
PATCH_COUNT=$(cat "$WORK_DIR/tools/patch.log" | tail -n 1)

sleep 0.3
echo -e "${M}│${NC} ${Y} [INFO] Executing Structural Bypass${NC}"
sleep 0.3
echo -e "${M}│${NC} ${Y} [INFO] Trackers neutralized in ${PATCH_COUNT} files${NC}"

java -Xmx$RAM_LIMIT -jar "$APKTOOL" b -q -f "$DECOMPILED_DIR" -o "$UNSIGNED_APK" > /dev/null 2>&1 &
run_spinner "Rebuilding classes.dex" "${M}" $!

if [ ! -f "$UNSIGNED_APK" ]; then
    echo -e "${M}│${NC} ${R} [ERROR] Rebuild failed. APK is protected.${NC}"
    echo -e "${M}╰───────────────────────────────────────────${NC}"
    exit 1
fi

apksigner sign --ks "$KEYSTORE" --ks-pass pass:android --key-pass pass:android --out "$FINAL_APK" "$UNSIGNED_APK" > /dev/null 2>&1 &
run_spinner "Cryptographically Signing APK" "${M}" $!

rm -rf "$DECOMPILED_DIR" "$UNSIGNED_APK" "$WORK_DIR/tools/patch.log" 2>/dev/null

echo -e "${M}│${NC} ${G} [BUILD] APK Built and Cleaned successfully.${NC}"
echo -e "${M}╰───────────────────────────────────────────${NC}"
echo ""

echo -e "${G}╭──────────────────────────────────────────╮${NC}"
echo -e "${G}│${NC} ${W}     P R O D U C T I O N  F I N I S H E D ${NC}${G}│${NC}"
echo -e "${G}╰──────────────────────────────────────────╯${NC}"
echo ""

termux-open-url "$TG_LINK" 2>/dev/null
sleep 1
termux-open-url "$YT_LINK" 2>/dev/null
