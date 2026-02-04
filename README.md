<div align="center">
  <img src="Icon.png" alt="Logo" style="height:100px; width:100px">

  <h3 align="center">Broke Remix</h3>

  <p align="center">
    <strong>An advanced fork of Broke: Turn ANY NFC tag into a physical key for your phone.</strong>
    <br />
    <br />
    <a href="https://github.com/openchlaw/broke-remix/issues">Report Bug</a>
  </p>
</div>

**Broke Remix** is a privacy-focused, open-source iOS application that allows you to "brick" your phone (block distracting apps) using physical objects. 

Unlike the original, this version **does not require writing data to NFC tags**. It reads the unique hardware UID of *any* NFC chip—credit cards, transit passes, key fobs, Amiibos, or even your passport—and turns it into a physical key.

## 🚀 Key Features (Remix)

*   **Universal Tag Support:** Works with read-only, encrypted, or unformatted tags. If it has an NFC chip, it's a key.
*   **Dynamic Locking:** 
    *   **To Lock:** Tap the app, then scan *any* tag. That specific tag becomes the only key.
    *   **To Unlock:** You must scan that *exact* same tag again.
*   **Native iOS Design:** A complete UI overhaul featuring Apple-like aesthetics, haptic feedback, and fluid animations.
*   **Profile Management:** Create multiple blocking profiles (e.g., "Deep Work", "Sleep Mode") with different app/category restrictions.
*   **Privacy First:** Uses Apple's Screen Time API. No data leaves your device.

## 🛠 Prerequisites

*   **Mac with Xcode 15+**
*   **iPhone with iOS 16.0+** (Required for FamilyControls/DeviceActivity APIs)
*   **Apple Developer Account** (Free tier works for 7-day provisioning, Paid for permanent)

## 📦 Installation

1.  **Clone the Repo**
    ```bash
    git clone https://github.com/openchlaw/broke-remix.git
    cd broke-remix/broke
    ```

2.  **Open in Xcode**
    Double-click `Broke.xcodeproj`.

3.  **Configure Signing**
    *   Click on the "Broke" project in the navigator.
    *   Select the "Broke" target.
    *   Go to **Signing & Capabilities**.
    *   Select your Team.
    *   Change the **Bundle Identifier** to something unique (e.g., `com.yourname.broke`).

4.  **Build & Run**
    *   Connect your iPhone.
    *   Select your device as the run destination.
    *   Hit `Cmd+R`.

5.  **Authorize Screen Time**
    *   On first launch, the app will ask for permission to access Screen Time. You must click "Continue" and "Allow" to enable blocking functionality.

## ⚠️ Important Notes

*   **Don't lose your key!** If you lock your phone with a tag and lose it, you will have to restart your device or delete the app to regain access to blocked apps.
*   **Background Scanning:** The app must be open (foreground) to lock/unlock. Passive background NFC reading is not supported for this specific security model.

## Credits

Based on the original [Broke](https://github.com/OzTamir/broke) by Oz Tamir.
Inspired by [Brick](https://getbrick.app/).
