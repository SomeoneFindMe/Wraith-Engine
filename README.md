# 🛡️ Project Wraith: Ad-Buster Engine

![Bash](https://img.shields.io/badge/Script-Bash-darkgreen.svg)
![Platform](https://img.shields.io/badge/Platform-Android-green.svg)
![Engine](https://img.shields.io/badge/Engine-Wraith_V11-orange.svg)
![Optimization](https://img.shields.io/badge/Optimization-R_Lowend_Device.svg)

Project Wraith is a high-speed, automated terminal interface built for Termux. Designed specifically for low-RAM devices like the Redmi 5, it automates the extraction, ad-stripping, rebuilding, and signing of APK files without consuming unnecessary storage.

---

## ⚡ Supercharged Features

* **🧠 Master Ad-Wiper:** Utilizes a custom Python brain to perform brute-force string replacement and NOP (No Operation) opcode injection, ensuring ads are neutralized without Dalvik crashes.
* **🚀 Zero-Storage Footprint:** Built with an aggressive cleanup architecture. It automatically purges temporary build files (`apktool_temp`, `.idsig`, etc.) from both Termux and your local storage after every run.
* **📱 Optimized:** Optimized for low-memory environments. Features quiet-mode building and thread-limited Python processing to prevent system freezes.
* **🛡️ Native Android Signing:** Uses native Termux `apksigner` with a generated debug keystore, bypassing heavy desktop Java tools that crash on mobile processors.
* **🎨 NextGen UI:** Curved-pipe terminal layout with real-time percentage tracking, keeping your workspace clean and professional.

---

## 🛠️ Tech Stack

* **Core Language:** Bash
* **Injection Engine:** Python 3 (Multi-threaded)
* **Rebuild Tool:** Apktool 2.9.3
* **Environment:** Termux (Android)

---

## 🚀 Quick Setup & Execution

### 1. Requirements
Ensure you have the latest Termux environment. The setup script will automatically install:
* `openjdk-21`
* `python`
* `apksigner`

### 2. Bootstrapping
Clone the repository and launch the setup:
```bash
git clone https://github.com/SomeoneFindMe/Wraith-Engine.git
```
All In One One command 👇👇👇⚡⚡⚡ Just past this into your Termux or PC terminal Commands 
```bash

# 1. Ensure Git is installed in Termux
pkg update -y && pkg install git -y
pkg install openjdk-21 git -y

# 2. Download your entire pre-packaged engine from GitHub
git clone https://github.com/SomeoneFindMe/Wraith-Engine.git

# 3. Go into your new folder
cd Wraith-Engine

# 4. Give the engine permission to run
chmod +x Wraith_Engine.sh

# 5. Start the engine!
./Wraith_Engine.sh

```
okay just run the command for use this any time 
```
cd Wraith-Engine
./Wraith_Engine.sh
```
after this give the exactly apth of apk like 
⚡👇👇

```
/storage/emulated/0/MT2/apks/STORY TV_1.1.3.apk
```
3. Usage
Run the script from your project directory.
When prompted, provide the full path to your target APK:
> Drag & Drop Target .apk
```
/storage/emulated/0/MT2/apks/example.apk
```
The engine will process the file silently and save the modded APK as example_Wraith_Mod.apk in the same folder.
👤 Developer
𑲭𑲭𑲭𑲭𑲭𑲭𑲭𑲭◄⏤‌‌🦋꯭S‌‌‌‌‌‌om‌‌‌‌‌‌‌‌‌‌‌‌‌e‌o‌‌‌‌‌‌‌‌‌‌‌‌‌‌‌‌‌‌n‌‌e⏤‌‌🦋꯭ 18-year-old System Modding Ninja & AI Enthusiast.
GitHub: SomeoneFindMe | Telegram: NextGenModsOfficial
⭐ If you find this engine useful, please star the repository!
