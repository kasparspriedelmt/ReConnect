# AutoWiFiConnect.ps1
# Cycles through a list of known Wi-Fi passwords until connection succeeds
# Tested on Windows 11

# --- CONFIGURATION ---
$SSID = "YourSSIDHere"
$SSIDHEX = -join ($SSID.ToCharArray() | ForEach-Object { "{0:X2}" -f [int][char]$_ })

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
# Get current month number (1–12)
$month = (Get-Date).Month
Write-Host "Current month detected: $month"
Write-Host "Connecting to $SSID with Hex: $SSIDHEX"

# Index into password list (PowerShell arrays are 0-based)
$currentIndex = $month - 1
$tryIndexes = @($currentIndex)

# Add previous month index if available
if ($currentIndex -gt 0) {
    $tryIndexes += ($currentIndex - 1)
} else {
    # If January fails, fallback to December
    $tryIndexes += 11
}

foreach ($i in $tryIndexes) {
    $pw = $Passwords[$i]
    Write-Host "Trying password for index $i (Month $($i+1)): $pw"

    # Build XML profile dynamically
    $xml = @"
<?xml version="1.0"?>
<WLANProfile xmlns="http://www.microsoft.com/networking/WLAN/profile/v1">
	<name>$SSID</name>
	<SSIDConfig>
		<SSID>
			<hex>$SSIDHEX</hex>
			<name>$SSID</name>
		</SSID>
	</SSIDConfig>
	<connectionType>ESS</connectionType>
	<connectionMode>manual</connectionMode>
	<MSM>
		<security>
			<authEncryption>
				<authentication>WPA3SAE</authentication>
				<encryption>AES</encryption>
				<useOneX>false</useOneX>
				<transitionMode xmlns="http://www.microsoft.com/networking/WLAN/profile/v4">true</transitionMode>
			</authEncryption>
			<sharedKey>
				<keyType>passPhrase</keyType>
				<protected>false</protected>
				<keyMaterial>$pw</keyMaterial>
			</sharedKey>
		</security>
	</MSM>
	<MacRandomization xmlns="http://www.microsoft.com/networking/WLAN/profile/v3">
		<enableRandomization>false</enableRandomization>
		<randomizationSeed>1123036468</randomizationSeed>
	</MacRandomization>
</WLANProfile>
"@

    $profilePath = "$env:TEMP\wifi.xml"
    $xml | Set-Content $profilePath

    # Delete old profile and add new one
    netsh wlan delete profile name=$SSID | Out-Null
    netsh wlan add profile filename=$profilePath | Out-Null

    # Attempt connection
    netsh wlan connect name=$SSID ssid=$SSID | Out-Null
    Start-Sleep -Seconds 10

    # Check connection status
    $status = netsh wlan show interfaces | Select-String "State"
    if ($status -match "connected") {
        Write-Host "Connected successfully with password: $pw"
        break
    } else {
        Write-Host "Failed with password: $pw"
    }
}
