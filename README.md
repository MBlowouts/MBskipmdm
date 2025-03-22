# Bypass-MDM for macOS 💻

Bypass MDM enrollment on macOS during setup with this simple script.

---

## ⚠️ Prerequisites

- **It is advised to erase the hard drive prior to starting.**  
- **It is advised to reinstall macOS using an external flash drive.**  
- **Device language must be set to English (can be changed later).**  
- **Ensure you are connected to a WiFi network to activate the Mac.**  

---

## 🚀 Steps to Bypass MDM Enrollment

> When you reach the forced MDM enrollment setup screen:

1. **Force shut down** your Mac by long-pressing the **Power** button.  
2. **Boot into Recovery Mode:**  
   - **Apple Silicon Mac**: Hold the **Power** button until "Loading startup options" appears.  
   - **Intel Mac**: Hold **<kbd>CMD</kbd> + <kbd>R</kbd>** during boot until you see the Apple logo.  
3. **Ensure you're connected to WiFi** (required for activation).  
4. **Open Safari** from the macOS Utilities menu.  
5. **Copy the following command:**

   ```zsh
   curl https://raw.githubusercontent.com/MBlowouts/MBskipmdm/main/bypass-mdm.sh -o bypass-mdm.sh && chmod +x ./bypass-mdm.sh && ./bypass-mdm.sh

Launch Terminal (Utilities > Terminal).
Paste the command (<kbd>CMD</kbd> + <kbd>V</kbd>) and run it (<kbd>ENTER</kbd>).
Follow the script prompts:
Press 1 for Auto-Bypass.
Press ENTER to use the default username (Apple).
Press ENTER to use the default password (1234).
Wait for the script to complete, then reboot your Mac.
Sign in with:
Username: Apple
Password: 1234
Skip all setup screens (Apple ID, Siri, Touch ID, Location Services).
Once on the desktop, navigate to:
System Settings > Users & Groups, and create your real admin account.
Log out of the Apple profile and sign in to your real admin account.
Set up macOS properly (Apple ID, Siri, Touch ID, Location Services).
Delete the temporary Apple profile from System Settings > Users & Groups.
🎉 Congratulations, you're MDM-free! 💫

❗ Important Notes

This script removes MDM capabilities before they are configured, making it undetectable locally.
However, your Mac’s serial number will still be visible in the company's MDM inventory system.
Use at your own risk. If questioned, have a valid excuse ready.
