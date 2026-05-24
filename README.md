# 🛡️ Project Wraith: Ad-Buster Engine

![Bash](https://img.shields.io/badge/Script-Bash-darkgreen.svg)
![Platform](https://img.shields.io/badge/Platform-Android-green.svg)
![Engine](https://img.shields.io/badge/Engine-Wraith_V11-orange.svg)
![Optimization](https://img.shields.io/badge/Optimization-Redmi_5-red.svg)

Project Wraith is a high-speed, automated terminal interface built for Termux. Designed specifically for low-RAM devices like the Redmi 5, it automates the extraction, ad-stripping, rebuilding, and signing of APK files without consuming unnecessary storage.

---

## ⚡ Supercharged Features

* **🧠 Master Ad-Wiper:** Utilizes a custom Python brain to perform brute-force string replacement and NOP (No Operation) opcode injection, ensuring ads are neutralized without Dalvik crashes.
* **🚀 Zero-Storage Footprint:** Built with an aggressive cleanup architecture. It automatically purges temporary build files (`apktool_temp`, `.idsig`, etc.) from both Termux and your local storage after every run.
* **📱 Redmi 5 Optimized:** Optimized for low-memory environments. Features quiet-mode building and thread-limited Python processing to prevent system freezes.
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
* `openjdk-17`
* `python`
* `apksigner`

### 2. Bootstrapping
Clone the repository and launch the setup:
```bash
git clone 
cd Project-Wraith
chmod +x Wraith_Engine_Setup.sh
./Wraith_Engine_Setup.sh
```
Open everything okay just run the command 
cd 
