# 📝Trktivity

## Easiest way to install:
1. Download **installer.ps1**
2. Open your **Downloads folder**
3. Right click and press **"Run with PowerShell"**
4. Complete main setup and it's done 😄

| ![image](https://user-images.githubusercontent.com/20853986/184855270-4bf0f8d9-ec81-4b22-aee6-1b1df97fc459.png) | ![image](https://user-images.githubusercontent.com/20853986/184855277-f484dc64-b0e9-4468-afb0-44c0ed8f0c0a.png) |
|------|------|

## Manual Install:
1. Download zip archive.
2. Extract it in a folder you want.
3. Open tabame.exe

### 📤 How to uninstall:
If you installed it with installer.ps1 Open file explorer, in address bar write `%localappdata%` then delete folder `Tabame`.
If you manually installed it, delete the folder where you placed it.


## Make your own:
This project is open source, which means you can compile your own version.
1. Install Flutter for Windows
2. Open Visual Studio Installer, on Individual Components select ATL Dependencies and install.
3. Open a console in Tabame folder and type `flutter build windows`
4. The exe is in `build\windows\runner\Release`
5. You can open vsCode and debug the app.


# Main Feature: **📝Trktivity**
Trktivity tracks your activity 🧐. It records keystrokes, mouse pings each 3 seconds and active window exe and title (if you set filters for it). 

You can view stats per day or a set of days. It generates a graph from 00:00 to 24:00.

It generates a timeline for executable you were focused and for Titles you've created filters for.

By default is disabled, you can enable it, all recorded information is stored locally on your Computer and it is not sent anywhere.
