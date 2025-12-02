# AutoWiFiConnect.ps1
# Cycles through a list of known Wi-Fi passwords until connection succeeds
# Tested on Windows 11

# --- CONFIGURATION ---
$SSID = "YourSSIDHere"

# List of passwords in order (Jan → Dec, or however your rotation works)
$Passwords = @(
    "PasswordForJanuary",
    "PasswordForFebruary",
    "PasswordForMarch",
    "PasswordForApril",
    "PasswordForMay",
    "PasswordForJune",
    "PasswordForJuly",
    "PasswordForAugust",
    "PasswordForSeptember",
    "PasswordForOctober",
    "PasswordForNovember",
    "PasswordForDecember"
)

# --- SCRIPT LOGIC ---
Write-Host "Attempting to connect to SSID: $SSID" -ForegroundColor Cyan

foreach ($pw in $Passwords) {
    Write-Host "Trying password: $pw" -ForegroundColor Yellow

    # Update Wi-Fi profile with current password
    netsh wlan delete profile name=$SSID | Out-Null
    netsh wlan add profile filename="$env:TEMP\wifi.xml" | Out-Null

    # Build XML profile dynamically
    $xml = @"
<WLANProfile xmlns="http://www.microsoft.com/networking/WLAN/profile/v1">
  <name>$SSID</name>
  <SSIDConfig>
    <SSID>
      <name>$SSID</name>
    </SSID>
  </SSIDConfig>
  <connectionType>ESS</connectionType>
  <connectionMode>manual</connectionMode>
  <MSM>
    <security>
      <authEncryption>
        <authentication>WPA2PSK</authentication>
        <encryption>AES</encryption>
        <useOneX>false</useOneX>
      </authEncryption>
      <sharedKey>
        <keyType>passPhrase</keyType>
        <protected>false</protected>
        <keyMaterial>$pw</keyMaterial>
      </sharedKey>
    </security>
  </MSM>
</WLANProfile>
"@

    $xml | Set-Content "$env:TEMP\wifi.xml"

    # Add profile and attempt connection
    netsh wlan add profile filename="$env:TEMP\wifi.xml" | Out-Null
    netsh wlan connect name=$SSID ssid=$SSID | Out-Null

    Start-Sleep -Seconds 10

    # Check connection status
    $status = netsh wlan show interfaces | Select-String "State"
    if ($status -match "connected") {
        Write-Host "✅ Connected successfully with password: $pw" -ForegroundColor Green
        break
    } else {
        Write-Host "❌ Failed with password: $pw" -ForegroundColor Red
    }
}
