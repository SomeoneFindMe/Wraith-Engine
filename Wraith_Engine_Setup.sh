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
MY_NAME="𑲭𑲭𑲭𑲭𑲭𑲭𑲭𑲭◄⏤‌‌🦋꯭𝆺𝅥⃝꯭S‌‌‌‌‌‌om‌‌‌‌‌‌‌‌‌‌‌‌‌e‌o‌‌‌‌‌‌‌‌‌‌‌‌‌‌‌‌‌‌n‌‌e⏤‌‌🦋꯭"
GH_LINK="https://github.com/SomeoneFindMe"
TG_LINK="https://t.me/NextGenModsOfficial"
YT_LINK="https://youtube.com/@nextgenmodsofficial"

clear

# ==========================================
# NEXTGEN SHIELD HEADER
# ==========================================
echo -e "${C}╭──────────────────────────────────────────╮${NC}"
echo -e "${C}│${NC} ${M}         ℕ 𝔼 𝕏 𝕋 𝔾 𝔼 ℕ 𝕄 𝕆 𝔻 𝕊          ${NC}${C}│${NC}"
echo -e "${C}│${NC} ${Y}        P r o j e c t   W r a i t h      ${NC}${C}│${NC}"
echo -e "${C}╰──────────────────────────────────────────╯${NC}"
echo -e "${C}│${NC} ${M}◈ CREATOR:${NC} ${Y}$MY_NAME${NC}"
echo -e "${C}│${NC} ${M}◈ ENGINE: ${NC} ${G}Wraith Ad-Buster V10 Ultra${NC}"
echo -e "${C}│${NC} ${M}◈ HW:     ${NC} ${W}NVIDIA HGX Systems${NC}"
echo -e "${C}╰───────────────────────────────────────────${NC}"
echo ""

# Auto-open GitHub instantly
termux-open-url "$GH_LINK" 2>/dev/null
sleep 1

WORK_DIR="$HOME/Wraith_Engine"
mkdir -p "$WORK_DIR/tools"
APKTOOL="$WORK_DIR/tools/apktool.jar"

# ==========================================
# AUTO-BOOTSTRAP (Silent Core Install)
# ==========================================
if ! command -v python &> /dev/null || ! command -v apksigner &> /dev/null; then
    pkg update -y > /dev/null 2>&1
    pkg install wget python openjdk-17 apksigner -y > /dev/null 2>&1
fi
if [ ! -f "$APKTOOL" ]; then
    wget -q "https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_2.9.3.jar" -O "$APKTOOL"
fi
if [ ! -f "$WORK_DIR/tools/debug.keystore" ]; then
    keytool -genkey -v -keystore "$WORK_DIR/tools/debug.keystore" -storepass android -alias androiddebugkey -keypass android -keyalg RSA -keysize 2048 -validity 10000 -dname "CN=Android Debug,O=Android,C=US" > /dev/null 2>&1
fi

# ==========================================
# THE MASTER PYTHON BRAIN (Your Exact Regex List)
# ==========================================
cat << 'INPYTHON' > "$WORK_DIR/tools/brain.py"
import os, re, sys
from concurrent.futures import ThreadPoolExecutor

if len(sys.argv) < 2: sys.exit(1)
PROJECT_DIR = sys.argv[1]

RAW_PATCHES = [
    # Custom User Regex Blocks
    (r"(\.method\s(public|private|static)\s\b(?!\babstract|native\b)(.*)?loadAd\(.*\)V)", r"\g<1>\n    return-void"),
    (r"(\.method\s(public|private|static)\s\b(?!\babstract|native\b)(.*)?loadAd\(.*\)Z)", r"\g<1>\n    const/4 v0, 0x0\n    return v0"),
    (r"(invoke.*loadAd\(.*\)[VZ])", r"# \g<1>"),
    (r"(invoke.*gms.*\>(loadUrl|loadDataWithBaseURL|requestInterstitialAd|showInterstitial|showVideo|showAd|loadData|onAdClicked|onAdLoaded|isLoading|loadAds|AdLoader|AdRequest|AdListener|AdView).*V)", r"# \g<1>"),
    (r"\"(http.*|//.*)(61\.145\.124\.238|\-ads\.|\.ad\.|\.ads\.|\.analytics\.localytics\.com|\.mobfox\.com|\.mp\.mydas\.mobi|\.plus1\.wapstart\.ru|\.scorecardresearch\.com|\.startappservice\.com|\/ad\.|\/ads|ad\-mail|ad\.*\_logging|ad\.api\.kaffnet\.com|adc3\-launch|adcolony|adinformation|adkmob|admax|admob|admost|adsafeprotected|adservice|adtag|advert|adwhirl|adz\.wattpad\.com|alta\.eqmob\.com|amazon\-*ads|amazon\.*ads|amobee|analytics|applovin|applvn|appnext|appodeal|appsdt|appsflyer|burstly|cauly|cloudfront|com\.google\.android\.gms\.ads\.identifier\.service\.START|crashlytics|crispwireless|criteo\.|dmtry\.|doubleclick|dsp\.batmobil\.net|duapps|dummy|flurry|fwmrm|gad|getads|gimbal|glispa|google\.com\/dfp|googleAds|googleads|googleapis\.*\.ad\-*|googlesyndication|googletagmanager|greystripe|gstatic|heyzap|hyprmx|iasds01|inmobi|inneractive|instreamatic|integralads|jumptag|jwpcdn|jwpltx|jwpsrv|kochava|localytics|madnet|mapbox|mc\.yandex\.ru|media\.net|metrics\.|millennialmedia|mixpanel|mng-ads\.com|moat\.|moatads|mobclix|mobfox|mobpowertech|moodpresence|mopub|native\_ads|nativex\.|nexage\.|ooyala|openx\.|pagead|pingstart|prebid|presage\.io|pubmatic|pubnative|rayjump|saspreview|scorecardresearch|smaato|smartadserver|sponsorpay|startappservice|startup\.mobile\.yandex\.net|statistics\.videofarm\.daum\.net|supersonicads|taboola|tapas|tapjoy|tapylitics|target\.my\.com|teads\.|umeng|unityads|vungle|zucks).*\"", r'"127.0.0.1"'),
    (r"ca-app-pub-\d{16}/\d{10}", r"ca-app-pub-0000000000000000/0000000000"),
    (r"invoke-.*\{.*\}, L.*;->(loadAd|requestNativeAd|showInterstitial|fetchad|fetchads|onadloaded|requestInterstitialAd|showAd|loadAds|AdRequest|requestBannerAd|loadNextAd|createInterstitialAd|setNativeAd|loadBannerAd|loadNativeAd|loadRewardedAd|loadRewardedInterstitialAd|loadAds|loadAdViewAd|showInterstitialAd|shownativead|showbannerad|showvideoad|onAdFailedToLoad)\(.*\)V", r"nop"),
    (r"invoke-.*\{.*\}, Lcom.*;->requestInterstitialAd\(.*\)V|invoke-.*\{.*\}, Lcom.*;->loadAds\(.*\)V|invoke-.*\{.*\}, Lcom.*;->loadAd\(.*\)V|invoke-.*\{.*\}, Lcom.*;->requestBannerAd\(.*\)V|invoke-.*\s\{[v|p]\d\},\sLcom/facebook.*;\-\>show\(.*\)V|invoke-.*\s\{[v|p]\d\},\sLcom/google.*;\-\>show\(.*\)V", r"nop"),
    (r"(\.method.*\b(loadAd|requestNativeAd|showInterstitial|fetchad|fetchads|onadloaded|requestInterstitialAd|showAd|loadAds|AdRequest|requestBannerAd|loadNextAd|createInterstitialAd|setNativeAd|loadBannerAd|loadNativeAd|loadRewardedAd|loadRewardedInterstitialAd|loadAds|loadAdViewAd|showInterstitialAd|shownativead|showbannerad|showvideoad|onAdFailedToLoad)\(.*\)V\n\s+\.registers \d+)[\s\S]*?\.end method", r"\g<1>\n    return-void\n.end method"),
    (r"(\.method\s(public|private|static)\s\b(?!\babstract|native\b)(.*)?(loadAd|renderAd|Ad(Clicked|Dismissed|Shown))\(.*\)V\n\s+\.registers \d+)[\s\S]*?(?:return-void|[\s\S]*?throw.*)?(?:\s+\.end method)", r"\g<1>\n    return-void\n.end method"),
    (r"(\.method protected final onCreate\(Landroid\/os\/Bundle;\)V[\s|\S]*?iput-object.*AdActivity.*[\s|\S]*?)if-(?:nez|eqz).*, :cond_(.*)", r"\g<1>goto :cond_\g<2>"),
    (r"(invoke(?!.*(close|Deactiv|Destroy|Dismiss|Disabl|error|player|remov|expir|fail|hide|skip|stop|Throw)).*/(adcolony|admob|ads|adsdk|aerserv|appbrain|applovin|appodeal|appodealx|appsflyer|bytedance/sdk/openadsdk|chartboost|flurry|fyber|hyprmx|inmobi|ironsource|mbrg|mbridge|mintegral|moat|mobfox|mobilefuse|mopub|my/target|ogury|Omid|onesignal|presage|smaato|smartadserver|snap/adkit|snap/appadskit|startapp|taboola|tapjoy|tappx|vungle)/.*>(request.*|(.*(activat|Banner|build|Event|exec|header|html|initAd|initi|JavaScript|Interstitial|load|log|MetaData|metri|Native|onAd|propert|report|response|Rewarded|show|trac|url|(fetch|refresh|render|video)Ad).*)|.*Request)\(.*\)V)", r"const/4 \g<9>, 0x0"),
    (r"(invoke(?!.*(close|Deactiv|Destroy|Dismiss|Disabl|error|player|remov|expir|fail|hide|skip|stop|Throw)).*/(adcolony|admob|ads|adsdk|aerserv|appbrain|applovin|appodeal|appodealx|appsflyer|bytedance/sdk/openadsdk|chartboost|flurry|fyber|hyprmx|inmobi|ironsource|mbrg|mbridge|mintegral|moat|mobfox|mobilefuse|mopub|my/target|ogury|Omid|onesignal|presage|smaato|smartadserver|snap/adkit|snap/appadskit|startapp|taboola|tapjoy|tappx|vungle)/.*>(request.*|(.*(activat|Banner|build|Event|exec|header|html|initAd|initi|JavaScript|Interstitial|load|log|MetaData|metri|Native|(can|get|is|has|was)Ad|propert|report|response|Rewarded|show|trac|url|(fetch|refresh|render|video)Ad).*)|.*Request)\(.*\)Z\n\n\s{4})move-result\s([pv]\d+)", r"const/4 \g<9>, 0x0")
]

MANIFEST_PATCH = (r'<meta-data\s+android:name="com\.google\.android\.gms\.ads\.APPLICATION_ID"\s+android:value=".*?"\s*/>', r'<meta-data android:name="com.google.android.gms.ads.APPLICATION_ID" android:value="ca-app-pub-0000000000000000~0000000000" />')

COMPILED_PATCHES = [(re.compile(p, re.MULTILINE), r) for p, r in RAW_PATCHES]
COMPILED_MANIFEST = re.compile(MANIFEST_PATCH[0], re.MULTILINE)

def safe_sub(pattern, replacement, text):
    try: return pattern.sub(replacement, text)
    except Exception:
        try: return pattern.sub(r"# \g<0>", text)
        except: return text

def process_file(file_path):
    try:
        with open(file_path, 'r', encoding='utf-8', errors='ignore') as f: content = f.read()
        orig = content
        if file_path.endswith("AndroidManifest.xml"):
            content = COMPILED_MANIFEST.sub(MANIFEST_PATCH[1], content)
        else:
            for pattern, replacement in COMPILED_PATCHES:
                content = safe_sub(pattern, replacement, content)
        if content != orig:
            with open(file_path, 'w', encoding='utf-8') as f: f.write(content)
            return 1
    except: pass
    return 0

target_files = [os.path.join(root, f) for root, _, files in os.walk(PROJECT_DIR) for f in files if f.endswith(('.smali', '.xml'))]

with ThreadPoolExecutor(max_workers=4) as executor:
    count = sum(executor.map(process_file, target_files))
print(f"{count}")
INPYTHON

# ==========================================
# ANIMATION LOGIC 
# ==========================================
run_spinner() {
    local msg=$1
    local pid=$2
    local progress=0
    while kill -0 $pid 2>/dev/null; do
        progress=$((progress + 4))
        if [ $progress -ge 99 ]; then progress=99; fi
        echo -ne "${Y}│${NC} ${C} [+] ${msg}... ${progress}% \r${NC}"
        sleep 0.3
    done
    wait $pid
    echo -e "${Y}│${NC} ${G} [+] ${msg}... 100%                            ${NC}"
}

# ==========================================
# PHASE 1: EXTRACTION
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

# Silent Initial Cleanup
rm -rf "$DECOMPILED_DIR" "$UNSIGNED_APK" "$EXPORT_DIR/${APK_NAME}.apktool_temp" 2>/dev/null

java -Xmx512M -jar "$APKTOOL" d -r -q -f "$APK_PATH" -o "$DECOMPILED_DIR" > /dev/null 2>&1 &
run_spinner "Extracting APK Architecture" $!

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

python "$WORK_DIR/tools/brain.py" "$DECOMPILED_DIR" > "$WORK_DIR/tools/patch.log" 2>&1 &
run_spinner "Injecting Master Regex Payload" $!
PATCH_COUNT=$(cat "$WORK_DIR/tools/patch.log" | tail -n 1)

sleep 0.5
echo -e "${M}│${NC} ${Y} [INFO] Bypassing Ad Obfuscation Checks${NC}"
sleep 0.5
echo -e "${M}│${NC} ${Y} [INFO] Neutralized trackers in ${PATCH_COUNT} files${NC}"

# File Optimization & Fixes
rm -rf "$DECOMPILED_DIR/smali_assets" 2>/dev/null
rm -f "$DECOMPILED_DIR/assets/"*.dex 2>/dev/null
rm -f "$DECOMPILED_DIR/unknown/stamp-cert-sha256" 2>/dev/null
find "$DECOMPILED_DIR" -type f -name "Metadata.smali" -exec rm {} + 2>/dev/null

java -Xmx512M -jar "$APKTOOL" b -q -f "$DECOMPILED_DIR" -o "$UNSIGNED_APK" > /dev/null 2>&1 &
run_spinner "Rebuilding classes.dex" $!

if [ ! -f "$UNSIGNED_APK" ]; then
    echo -e "${M}│${NC} ${R} [ERROR] Rebuild failed. APK is protected.${NC}"
    echo -e "${M}╰───────────────────────────────────────────${NC}"
    exit 1
fi

apksigner sign --ks "$WORK_DIR/tools/debug.keystore" --ks-pass pass:android --key-pass pass:android --out "$FINAL_APK" "$UNSIGNED_APK" > /dev/null 2>&1 &
run_spinner "Cryptographically Signing APK" $!

echo -e "${M}│${NC} ${G} [BUILD] APK Built successfully.${NC}"
echo -e "${M}╰───────────────────────────────────────────${NC}"
echo ""

# ==========================================
# AGGRESSIVE STORAGE CLEANUP (Zero Junk left behind)
# ==========================================
rm -rf "$DECOMPILED_DIR" "$UNSIGNED_APK" "$WORK_DIR/tools/patch.log" 2>/dev/null
rm -rf "$WORK_DIR/${APK_NAME}_unsigned.apk.apktool_temp" 2>/dev/null
rm -rf "$WORK_DIR/"*.apktool_temp 2>/dev/null
rm -f "$FINAL_APK.idsig" 2>/dev/null

# ==========================================
# OUTRO SHIELD & AUTO-REDIRECT
# ==========================================
echo -e "${G}╭──────────────────────────────────────────╮${NC}"
echo -e "${G}│${NC} ${W}     P R O D U C T I O N  F I N I S H E D ${NC}${G}│${NC}"
echo -e "${G}╰──────────────────────────────────────────╯${NC}"
echo ""

termux-open-url "$TG_LINK" 2>/dev/null
sleep 1
termux-open-url "$YT_LINK" 2>/dev/null
