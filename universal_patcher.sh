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
echo -e "${C}│${NC} ${Y}    𝕌 ℕ 𝕀 𝕍 𝔼 ℝ 𝕊 𝔸 𝕃   𝕃 𝕆 𝕆 ℙ   𝕍 𝟙   ${NC}${C}│${NC}"
echo -e "${C}╰──────────────────────────────────────────╯${NC}"
echo -e "${C}│${NC} ${M}◈ CREATOR:${NC} ${Y}$MY_NAME${NC}"
echo -e "${C}│${NC} ${M}◈ ENGINE: ${NC} ${G}Wraith Infinite Loop${NC}"
echo -e "${C}│${NC} ${M}◈ HW RAM: ${NC} ${W}Xmx${RAM_LIMIT} Allocated${NC}"
echo -e "${C}╰───────────────────────────────────────────${NC}"
echo ""

# File Paths based on your setup
WORK_DIR="$HOME/Wraith-Engine"
APKTOOL="$WORK_DIR/tools/apktool.jar"
KEYSTORE="$WORK_DIR/tools/debug.keystore"

# Arrays to hold dynamic strings
SEARCH_ARR=()
REPLACE_ARR=()

# ==========================================
# DYNAMIC LOOP: COLLECTING STRINGS
# ==========================================
echo -e "${G}╭─── [ PHASE 1: COLLECT STRINGS ] ──────────────────${NC}"
echo -e "${G}│${NC} ${W}Tip: Type 'DONE' or just press Enter when finished.${NC}"
echo -e "${G}│${NC}"

COUNT=1
while true; do
    # Ask for Search String
    read -p "$(echo -e ${Y}"│ [Pair #$COUNT]"${NC} ${W}"Search for : "${NC})" RAW_SEARCH
    
    # Clean accidental quotes from input
    CLEAN_SEARCH=$(echo "$RAW_SEARCH" | tr -d '"' | tr -d "'")
    
    # Check if user wants to exit the loop (Press Enter or type DONE)
    if [ -z "$CLEAN_SEARCH" ] || [ "$CLEAN_SEARCH" = "DONE" ] || [ "$CLEAN_SEARCH" = "done" ]; then
        break
    fi
    
    # Ask for Replacement String
    read -p "$(echo -e ${Y}"│ [Pair #$COUNT]"${NC} ${G}"Replace with: "${NC})" RAW_REPLACE
    CLEAN_REPLACE=$(echo "$RAW_REPLACE" | tr -d '"' | tr -d "'")
    
    # Store in our master arrays
    SEARCH_ARR+=("$CLEAN_SEARCH")
    REPLACE_ARR+=("$CLEAN_REPLACE")
    
    echo -e "${G}│${NC}"
    COUNT=$((COUNT + 1))
done
echo -e "${G}╰───────────────────────────────────────────────────${NC}"
echo ""

# Verify if we actually have strings to replace
if [ ${#SEARCH_ARR[@]} -eq 0 ]; then
    echo -e "${R} [!] No strings entered. Exiting script.${NC}"
    exit 1
fi

# ==========================================
# ANIMATION LOGIC
# ==========================================
run_spinner() {
    local msg=$1; local color=$2; local pid=$3; local progress=0
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
# PHASE 2: APK EXTRACTION
# ==========================================
echo -e "${Y}╭─── [ PHASE 2: EXTRACTION ] ───────────────${NC}"
read -p "$(echo -e ${Y}"│"${NC} ${Y} " > Target .apk Path : "${NC})" RAW_PATH
echo -e "${Y}│${NC}"

APK_PATH=$(echo "$RAW_PATH" | tr -d '"' | tr -d "'")

if [ ! -f "$APK_PATH" ]; then
    echo -e "${Y}│${NC} ${R} [ERROR] Target APK not found!${NC}"
    echo -e "${Y}╰───────────────────────────────────────────${NC}"
    exit 1
fi

EXPORT_DIR=$(dirname "$(realpath "$APK_PATH")")
APK_NAME=$(basename "$APK_PATH" .apk)
DECOMPILED_DIR="$WORK_DIR/$APK_NAME"
UNSIGNED_APK="$WORK_DIR/${APK_NAME}_unsigned.apk"
FINAL_APK="$EXPORT_DIR/${APK_NAME}_Universal_Mod.apk"

rm -rf "$DECOMPILED_DIR" "$UNSIGNED_APK" 2>/dev/null

java -Xmx$RAM_LIMIT -jar "$APKTOOL" d -r -q -f "$APK_PATH" -o "$DECOMPILED_DIR" > /dev/null 2>&1 &
run_spinner "Extracting APK Architecture" "${Y}" $!
echo -e "${Y}╰───────────────────────────────────────────${NC}"
echo ""

# ==========================================
# PHASE 3: RUNNING THE AUTOMATED REPLACEMENTS
# ==========================================
echo -e "${M}╭─── [ PHASE 3: INJECTING DYNAMIC STRINGS ] ──${NC}"

TOTAL_PAIRS=${#SEARCH_ARR[@]}
echo -e "${M}│${NC} ${Y} [INFO] Processing $TOTAL_PAIRS string replacement(s)...${NC}"

# Loop through all collected pairs and run sed
for ((i=0; i<$TOTAL_PAIRS; i++)); do
    OLD_STR="${SEARCH_ARR[$i]}"
    NEW_STR="${REPLACE_ARR[$i]}"
    
    echo -e "${M}│${NC}  [+] Replacing \"$OLD_STR\" ➔ \"$NEW_STR\""
    
    # Precision Injection: Searches strictly inside quotes to protect code registers
    find "$DECOMPILED_DIR" -type f -name "*.smali" -exec sed -i "s/\"$OLD_STR\"/\"$NEW_STR\"/g" {} +
done

sleep 0.5
echo -e "${M}│${NC} ${G} [✔] All Dynamic Injections Completed Successfully!${NC}"

java -Xmx$RAM_LIMIT -jar "$APKTOOL" b -q -f "$DECOMPILED_DIR" -o "$UNSIGNED_APK" > /dev/null 2>&1 &
run_spinner "Rebuilding classes.dex" "${M}" $!

if [ ! -f "$UNSIGNED_APK" ]; then
    echo -e "${M}│${NC} ${R} [ERROR] Rebuild failed. Script aborted.${NC}"
    echo -e "${M}╰───────────────────────────────────────────${NC}"
    exit 1
fi

apksigner sign --ks "$KEYSTORE" --ks-pass pass:android --key-pass pass:android --out "$FINAL_APK" "$UNSIGNED_APK" > /dev/null 2>&1 &
run_spinner "Cryptographically Signing APK" "${M}" $!

rm -rf "$DECOMPILED_DIR" "$UNSIGNED_APK" 2>/dev/null

echo -e "${M}│${NC} ${G} [BUILD] Done! Saved as ${APK_NAME}_Universal_Mod.apk${NC}"
echo -e "${M}╰───────────────────────────────────────────${NC}"
echo ""

echo -e "${G}╭──────────────────────────────────────────╮${NC}"
echo -e "${G}│${NC} ${W}     P R O D U C T I O N  F I N I S H E D ${NC}${G}│${NC}"
echo -e "${G}╰──────────────────────────────────────────╯${NC}"
echo ""

termux-open-url "$TG_LINK" 2>/dev/null
sleep 1
termux-open-url "$YT_LINK" 2>/dev/null
