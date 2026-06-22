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

clear
echo -e "${C}╭──────────────────────────────────────────╮${NC}"
echo -e "${C}│${NC} ${M}         ℕ 𝔼 𝕏 𝕋 𝔾 𝔼 ℕ 𝕄 𝕆 𝔻 𝕊          ${NC}${C}│${NC}"
echo -e "${C}│${NC} ${Y}    W r a i t h   I n f i n i t y   M a x ${NC}${C}│${NC}"
echo -e "${C}╰──────────────────────────────────────────╯${NC}"
echo ""

# ==========================================
# HARDWARE UNLEASHED: DYNAMIC RAM ALLOCATOR
# ==========================================
TOTAL_RAM=$(free -m | awk '/^Mem:/{print $2}')
if [ "$TOTAL_RAM" -le 4500 ]; then
    RAM_LIMIT="1024M" # Standard allocation
elif [ "$TOTAL_RAM" -le 8500 ]; then
    RAM_LIMIT="2048M" # Performance allocation
else
    # 12GB+ RAM Detected: Unleashing maximum compilation power 
    # Handles 10+ massive concurrent tasks with zero OOM errors.
    RAM_LIMIT="4096M" 
fi

echo -e "${C}│${NC} ${M}◈ ENGINE: ${NC} ${G}Universal Master Builder V2${NC}"
echo -e "${C}│${NC} ${M}◈ HW RAM: ${NC} ${W}Xmx${RAM_LIMIT} Allocated (Max Threading)${NC}"
echo -e "${C}╰───────────────────────────────────────────${NC}"
echo ""

# File Paths (Ensure these match your environment)
WORK_DIR="$HOME/Wraith-Engine"
APKTOOL="$WORK_DIR/tools/apktool.jar"
KEYSTORE="$WORK_DIR/tools/debug.keystore"

# Arrays to hold dynamic strings
SEARCH_ARR=()
REPLACE_ARR=()

# ==========================================
# PHASE 1: COLLECT TARGET STRINGS (INFINITE LOOP)
# ==========================================
echo -e "${G}╭─── [ INJECTION DATA COLLECTION ] ─────────────────${NC}"
COUNT=1
while true; do
    read -p "$(echo -e ${Y}"│ [Pair #$COUNT]"${NC} ${W}"Search for (or type DONE to build): "${NC})" RAW_SEARCH
    CLEAN_SEARCH=$(echo "$RAW_SEARCH" | tr -d '"' | tr -d "'")
    
    if [ -z "$CLEAN_SEARCH" ] || [[ "${CLEAN_SEARCH^^}" == "DONE" ]]; then
        break
    fi
    
    read -p "$(echo -e ${Y}"│ [Pair #$COUNT]"${NC} ${G}"Replace with: "${NC})" RAW_REPLACE
    CLEAN_REPLACE=$(echo "$RAW_REPLACE" | tr -d '"' | tr -d "'")
    
    SEARCH_ARR+=("$CLEAN_SEARCH")
    REPLACE_ARR+=("$CLEAN_REPLACE")
    echo -e "${G}│${NC}"
    COUNT=$((COUNT + 1))
done
echo -e "${G}╰───────────────────────────────────────────────────${NC}"
echo ""

if [ ${#SEARCH_ARR[@]} -eq 0 ]; then
    echo -e "${R} [!] No strings entered. Script aborted.${NC}"
    exit 1
fi

# Animation Function
run_spinner() {
    local msg=$1; local color=$2; local pid=$3; local progress=0
    while kill -0 $pid 2>/dev/null; do
        progress=$((progress + 3))
        if [ $progress -ge 99 ]; then progress=99; fi
        echo -ne "${color}│${NC} ${C} [+] ${msg}... ${progress}% \r${NC}"
        sleep 0.2
    done
    wait $pid
    echo -e "${color}│${NC} ${G} [+] ${msg}... 100%                            ${NC}"
}

# ==========================================
# PHASE 2: MASTER BLUEPRINT & INSTANT CLONE
# ==========================================
echo -e "${Y}╭─── [ CORE EXTRACTION & CLONING ] ─────────${NC}"
read -p "$(echo -e ${Y}"│"${NC} ${Y} " > Target .apk Path : "${NC})" RAW_PATH
APK_PATH=$(echo "$RAW_PATH" | tr -d '"' | tr -d "'")

if [ ! -f "$APK_PATH" ]; then
    echo -e "${Y}│${NC} ${R} [ERROR] Target APK not found!${NC}"
    echo -e "${Y}╰───────────────────────────────────────────${NC}"
    exit 1
fi

EXPORT_DIR=$(dirname "$(realpath "$APK_PATH")")
APK_NAME=$(basename "$APK_PATH" .apk)

MASTER_DIR="$WORK_DIR/${APK_NAME}_MASTER_TEMPLATE"
SESSION_ID=$RANDOM
CLONE_DIR="$WORK_DIR/${APK_NAME}_CLONE_${SESSION_ID}"
UNSIGNED_APK="$WORK_DIR/${APK_NAME}_unsigned_${SESSION_ID}.apk"
FINAL_APK="$EXPORT_DIR/${APK_NAME}_Variation_${SESSION_ID}.apk"

echo -e "${Y}│${NC}"

# UNIVERSAL DECOMPILATION (Skips if Master exists)
if [ ! -d "$MASTER_DIR" ]; then
    echo -e "${Y}│${NC} ${Y} [INFO] Generating Universal Master Blueprint...${NC}"
    # -r flag ensures XMLs/Resources are untouched, making this compatible with ANY APK
    java -Xmx$RAM_LIMIT -jar "$APKTOOL" d -r -q -f "$APK_PATH" -o "$MASTER_DIR" > /dev/null 2>&1 &
    run_spinner "Decompiling Source (Heavy Task)" "${Y}" $!
else
    echo -e "${Y}│${NC} ${G} [✔] Master Template found! Bypassing decompilation.${NC}"
fi

# INSTANT MEMORY CLONING
echo -e "${Y}│${NC} ${C} [INFO] Forging isolated variation [Session: $SESSION_ID]...${NC}"
cp -a "$MASTER_DIR" "$CLONE_DIR"
echo -e "${Y}╰───────────────────────────────────────────${NC}"
echo ""

# ==========================================
# PHASE 3: ENTERPRISE-GRADE INJECTION
# ==========================================
echo -e "${M}╭─── [ HIGH-SPEED INJECTION & COMPILE ] ────${NC}"

TOTAL_PAIRS=${#SEARCH_ARR[@]}
for ((i=0; i<$TOTAL_PAIRS; i++)); do
    OLD_STR="${SEARCH_ARR[$i]}"
    NEW_STR="${REPLACE_ARR[$i]}"
    echo -e "${M}│${NC}  [+] Injecting ➔ \"$NEW_STR\""
    
    # OVERPOWERED REGEX: xargs handles infinite files without buffer limits
    find "$CLONE_DIR/smali" -type f -name "*.smali" -print0 | xargs -0 sed -i "s/\"$OLD_STR\"/\"$NEW_STR\"/g"
done

# REBUILD THE CLONE
java -Xmx$RAM_LIMIT -jar "$APKTOOL" b -q -f "$CLONE_DIR" -o "$UNSIGNED_APK" > /dev/null 2>&1 &
run_spinner "Compiling APK Variation_${SESSION_ID}" "${M}" $!

if [ ! -f "$UNSIGNED_APK" ]; then
    echo -e "${M}│${NC} ${R} [ERROR] Rebuild failed. Structural corruption detected.${NC}"
    rm -rf "$CLONE_DIR" "$UNSIGNED_APK" 2>/dev/null
    exit 1
fi

# SIGN THE CLONE
apksigner sign --ks "$KEYSTORE" --ks-pass pass:android --key-pass pass:android --out "$FINAL_APK" "$UNSIGNED_APK" > /dev/null 2>&1 &
run_spinner "Cryptographically Signing" "${M}" $!

# CLEAN UP ONLY THE CLONE
rm -rf "$CLONE_DIR" "$UNSIGNED_APK" 2>/dev/null

echo -e "${M}│${NC} ${G} [BUILD] Done! Saved as ${APK_NAME}_Variation_${SESSION_ID}.apk${NC}"
echo -e "${M}╰───────────────────────────────────────────${NC}"
echo ""

# ==========================================
# PHASE 4: STORAGE OPTIMIZATION (USER PROMPT)
# ==========================================
echo -e "${G}╭──────────────────────────────────────────╮${NC}"
echo -e "${G}│${NC} ${W}     P R O D U C T I O N  F I N I S H E D ${NC}${G}│${NC}"
echo -e "${G}╰──────────────────────────────────────────╯${NC}"
echo ""

read -p "$(echo -e ${Y}"[?] Is this your final task for this APK? Type 'OK' to delete the Master Template and free up storage, or press ENTER to keep it: "${NC})" CLEANUP_CHOICE

if [[ "${CLEANUP_CHOICE^^}" == "OK" ]]; then
    echo -e "${C}[!] Wiping Master Template to reclaim phone storage...${NC}"
    rm -rf "$MASTER_DIR"
    echo -e "${G}[✔] Storage wiped cleanly. Wraith Engine exiting.${NC}"
else
    echo -e "${G}[✔] Master Template saved for future speed-builds. Wraith Engine exiting.${NC}"
fi

echo ""
