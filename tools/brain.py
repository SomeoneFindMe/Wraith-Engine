import os, re, sys
from concurrent.futures import ThreadPoolExecutor

if len(sys.argv) < 2: sys.exit(1)
PROJECT_DIR = sys.argv[1]

# Exclusively using the user-provided RegEx strings to prevent blind-replacement crashes
RAW_PATCHES = [
    (r"(\.method\s(public|private|static)\s\b(?!\babstract|native\b)(.*)?(loadAd|renderAd|Ad(Clicked|Dismissed|Shown))\(.*\)V\n\s+\.registers \d+)[\s\S]*?(?:return-void|[\s\S]*?throw.*)?(?:\s+\.end method)", r"\g<1>\n    return-void\n.end method"),
    (r"(\.method\s(public|private|static)\s\b(?!\babstract|native\b)(.*)?loadAd\(.*\)Z)", r"\g<1>\n    const/4 v0, 0x0\n    return v0"),
    (r"(invoke.*gms.*\>(loadUrl|loadDataWithBaseURL|requestInterstitialAd|showInterstitial|showVideo|showAd|loadData|onAdClicked|onAdLoaded|isLoading|loadAds|AdLoader|AdRequest|AdListener|AdView).*V)|(((invoke.*/ads/.*>((load|show)(Ad(s)?)?)\(.*\)V)|(invoke.*loadAd\(.*\)[VZ])))", r"# \g<0>"),
    (r"\"(http.*|//.*)(61\.145\.124\.238|\-ads\.|\.5rocks\.io|\.ad\.|\.adadapted|\.admitad\.|\.admost\.|\.ads\.|\.aerserv\.|\.airpush\.|\.batmobil\.|\.chartboost\.|\.cloudmobi\.|\.conviva\.|\.dov-e\.com|\.fyber\.|\.mng-ads\|\.mydas\.|\.predic\.|\.talkingdata\.|\.tapdaq\.|\.tele\.fm|\.unity3d\.|\.unity\.|\.wapstart\.|\.xdrig\.|\.zapr\.|\/ad\.|\/ads|a4\.tl|accengage|ad4push|ad4screen|ad-mail|ad\..*_logging|ad\.api\.kaffnet\.|ad\.cauly\.co\.|adbuddiz|adc3-launch|adcolony|adfurikun|adincube|adinformation|adkmob|admax\.|admixer|admob|admost|ads\.mdotm\.|adsafeprotected|adservice|adsmogo|adsrvr|adswizz|adtag|adtech\.de|advert|adwhirl|adz\.wattpad\.|alimama\.|alta\.eqmob\.|amazon-.*ads|amazon\..*ads|amobee|analytics|anvato|appboy|appbrain|applovin|applvn|appmetrica|appnext|appodeal|appsdt|appsflyer|apsalar|avocarrot|axonix|banners-slb\.mobile\.yandex\.net|banners\.mobile\.yandex\.net|brightcove\.|burstly|cauly|cloudfront|cmcm\.|com\.google\.android\.gms\.ads\.identifier\.service\.START|comscore|contextual\.media\.net|crashlytics|crispwireless|criteo\.|dmtry\.|doubleclick|duapps|dummy|flurry|fwmrm|gad|getads|gimbal|glispa|google\.com\/dfp|googleAds|googleads|googleapis\..*\.ad-.*|googlesyndication|googletagmanager|greystripe|gstatic|heyzap|hyprmx|iasds01|inmobi|inneractive|instreamatic|integralads|jumptag|jwpcdn|jwpltx|jwpsrv|kochava|localytics|madnet|mapbox|mc\.yandex\.ru|media\.net|metrics\.|millennialmedia|mixpanel|mng-ads\.com|moat\.|moatads|mobclix|mobfox|mobpowertech|moodpresence|mopub|native_ads|nativex\.|nexage\.|ooyala|openx\.|pagead|pingstart|prebid|presage\.io|pubmatic|pubnative|rayjump|saspreview|scorecardresearch|smaato|smartadserver|sponsorpay|startappservice|startup\.mobile\.yandex\.net|statistics\.videofarm\.daum\.net|supersonicads|taboola|tapas|tapjoy|tapylitics|target\.my\.com|teads\.|umeng|unityads|vungle|zucks).*\"", r'"127.0.0.1"'),
    (r"ca-app-pub-\d{16}/\d{10}", r"ca-app-pub-0000000000000000/0000000000"),
    (r"(invoke-.*\{.*\}, L.*;->(loadAd|requestNativeAd|showInterstitial|\b(?:fetchad)\b|fetchads|onadloaded|requestInterstitialAd|showAd|loadAds|AdRequest|requestBannerAd|loadNextAd|createInterstitialAd|setNativeAd|loadBannerAd|loadNativeAd|loadRewardedAd|loadRewardedInterstitialAd|loadAds|loadAdViewAd|showInterstitialAd|shownativead|showbannerad|showvideoad|onAdFailedToLoad|AdListener|displayAdEventLoaded|failedToReceiveAd|failedToReceiveAdV2|fetchAdWithLocation|loadAdFromNetwork|loadAdFromUb|loadAdInternal|loadAdvertisement|loadAppOpenAd|loadInterscrollerAd|loadInterstitialAd|loadNativeAdForBidding|loadNextAdForAdToken|loadNextAdForZoneId|loadRewardedVideo|loadRewardedVideoForDemandOnly|loadSmartBanner|onAdClicked|onAdClosed|onAdCollapsed|onAdDisplayed|onAdDisplayFailed|onAdDismissedFullScreenContent|onAdFailed|onAdFailedToShow|onAdFailedToShowFullScreenContent|onAdHidden|onAdImpression|onAdLeftApplication|onAdOpen|onAdOpened|onAdRewarded|onAdRevenuePaid|onAdRequestStarted|onAdShowedFullScreenContent|onAppOpenAdLoadFailed|onInterstitialAdLoaded|onInterstitialAdLoadFailed|onInterstitialAdRewarded|onNativeAdClicked|onNativeAdLoaded|onNativeAdLoadFailed|onNativeAdShown|onRewardedAdClosed|onRewardedAdDisplayFailed|onRewardedAdFailedToLoad|onRewardedAdFailedToShow|onRewardedAdLoaded|onRewardedAdOpened|onRewardedVideoAdClicked|onRewardedVideoAdClosed|onRewardedVideoAdEnded|onRewardedVideoAdFailedToLoad|onRewardedVideoAdLoaded|onRewardedVideoAdOpened|onRewardedVideoAdRewarded|onRewardedVideoAdShowFailed|onRewardedVideoAdStarted|onUnifiedNativeAdLoaded|onUserEarnedReward|reportAdClicked|reportAdImpression|resumeBanner|setAdListener|setRewardedVideoAdListener|showBannerAndNative|showHideAds|showNativeInterstitial|showOfferwall|showRewardedVideo|showRewardedVideoAd|startAdSession|unsetNativeAd|vpaidAdImpression|vpaidAdInteraction|vpaidAdLoaded).*$(\s*move-result-object.*)?|invoke-.* \{.*\}, Lcom.*;->(requestInterstitialAd(.*)V|loadAds(.*)V|loadAd.*(\s*move-result-object.*)?|requestBannerAd(.*)V)|invoke-.* \{.*\}, (Lcom/facebook.*;->show(.*)(\s+move-result.*)?))", r"nop"),
    (r"(\.method.*\b(loadAd|requestNativeAd|showInterstitial|fetchad|fetchads|onadloaded|requestInterstitialAd|showAd|loadAds|AdRequest|requestBannerAd|loadNextAd|createInterstitialAd|setNativeAd|loadBannerAd|loadNativeAd|loadRewardedAd|loadRewardedInterstitialAd|loadAds|loadAdViewAd|showInterstitialAd|shownativead|showbannerad|showvideoad|onAdFailedToLoad|AdListener|displayAdEventLoaded|failedToReceiveAd|failedToReceiveAdV2|fetchAdWithLocation|loadAdFromNetwork|loadAdFromUb|loadAdInternal|loadAdvertisement|loadAppOpenAd|loadInterscrollerAd|loadInterstitialAd|loadNativeAdForBidding|loadNextAdForAdToken|loadNextAdForZoneId|loadRewardedVideo|loadRewardedVideoForDemandOnly|loadSmartBanner|onAdClicked|onAdClosed|onAdCollapsed|onAdDisplayed|onAdDisplayFailed|onAdDismissedFullScreenContent|onAdFailed|onAdFailedToShow|onAdFailedToShowFullScreenContent|onAdHidden|onAdImpression|onAdLeftApplication|onAdOpen|onAdOpened|onAdRewarded|onAdRevenuePaid|onAdRequestStarted|onAdShowedFullScreenContent|onAppOpenAdLoadFailed|onInterstitialAdLoaded|onInterstitialAdLoadFailed|onInterstitialAdRewarded|onNativeAdClicked|onNativeAdLoaded|onNativeAdLoadFailed|onNativeAdShown|onRewardedAdClosed|onRewardedAdDisplayFailed|onRewardedAdFailedToLoad|onRewardedAdFailedToShow|onRewardedAdLoaded|onRewardedAdOpened|onRewardedVideoAdClicked|onRewardedVideoAdClosed|onRewardedVideoAdEnded|onRewardedVideoAdFailedToLoad|onRewardedVideoAdLoaded|onRewardedVideoAdOpened|onRewardedVideoAdRewarded|onRewardedVideoAdShowFailed|onRewardedVideoAdStarted|onUnifiedNativeAdLoaded|onUserEarnedReward|reportAdClicked|reportAdImpression|resumeBanner|setAdListener|setRewardedVideoAdListener|showBannerAndNative|showHideAds|showNativeInterstitial|showOfferwall|showRewardedVideo|showRewardedVideoAd|startAdSession|unsetNativeAd|vpaidAdImpression|vpaidAdInteraction|vpaidAdLoaded)\b\(.*\)V\n    .registers \d+)[\s\S]*?\.end method", r"# \g<0>"),
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
