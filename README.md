🚀 How to Use
-----------------------------------------------------------------------
1. Copy the script into a file named AutoWiFiConnect.ps1.

2. Replace "YourSSIDHere" with your actual SSID.

3. Fill in the $Passwords array with your monthly passwords.

4. Run the script in PowerShell:
```
powershell -ExecutionPolicy Bypass -File AutoWiFiConnect.ps1
```
5. (Optional) Use Task Scheduler to run this script automatically:

Trigger: On logon or on the 1st of each month.

Action: Run PowerShell with the script.

------------------------------------------------------------------------
⚠️ Security Note

Passwords are stored in plain text inside the script. Restrict file access or consider encrypting them if security is a concern.

If you want to avoid plain text, you can store them in a secure string or encrypted file, but that adds complexity.