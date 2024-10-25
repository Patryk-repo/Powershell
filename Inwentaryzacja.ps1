$currentUser = $env:USERNAME
$computerName = $env:COMPUTERNAME
$WindowsVersion = Get-ComputerInfo -Property "OsName"

function Get-WindowsProductKey {
    $productKey = (Get-WmiObject -Query "select * from SoftwareLicensingService").OA3xOriginalProductKey
    if ($productKey) {
        return $productKey
    } else {
        return "Klucz produktu nie jest dostępny"
    }
}

$windowsProductKey = Get-WindowsProductKey
$output = cscript "C:\Program Files\Microsoft Office\Office16\OSPP.vbs" /dstatus
$lines = $output -split "`r`n"
$licensed = $false
$licenseDescription = ""

foreach ($line in $lines) {
    if ($line -like "*LICENSE DESCRIPTION:*") {
        $licenseDescription = ($line -split ":")[1].Trim()
    }
    if ($line -like "*---LICENSED---*") {
        $licensed = $true
    }
    if ($licensed -and $line -like "*Last 5 characters of installed product key:*") {
        $productKey = ($line -split ":")[1].Trim()
        $licensed = $false
        $licenseDescription = ""  # Reset opisu licencji na kolejne przetwarzanie
    }
}

try {
    $laptopInfo = Get-WmiObject Win32_ComputerSystem
    $laptopModel = $laptopInfo.Model
    $laptopSerialNumber = Get-WmiObject Win32_BIOS | Select-Object -ExpandProperty SerialNumber
} catch {
    $laptopModel = "Nie można uzyskać"
    $laptopSerialNumber = "Nie można uzyskać"
}


$monitors = Get-WmiObject -Query "Select * FROM WMIMonitorID" -Namespace root\wmi
$monitorInfo = @()

foreach ($monitor in $monitors) {
    $serialNumber = [System.Text.Encoding]::ASCII.GetString($monitor.SerialNumberID).Trim([char]0)
    $modelName = [System.Text.Encoding]::ASCII.GetString($monitor.UserFriendlyName).Trim([char]0)
    $monitorInfo += "Model monitora: $modelName, Numer seryjny: $serialNumber"
}

# Tworzenie katalogu 'wyniki' jeśli nie istnieje
$resultsDir = Join-Path (Get-Location) "wyniki"
if (-not (Test-Path $resultsDir)) {
    New-Item -ItemType Directory -Path $resultsDir
}

# Zapis wyników do pliku
$resultsFile = Join-Path $resultsDir "$currentUser.txt"

Add-Content -Path $resultsFile -Value "użytkownik: $currentUser"
Add-Content -Path $resultsFile -Value ""
Add-Content -Path $resultsFile -Value "Nazwa komputera: $computerName"
Add-Content -Path $resultsFile -Value ""
Add-Content -Path $resultsFile -Value "Wersja systemu: $($WindowsVersion.OsName)"
Add-Content -Path $resultsFile -Value "Klucz produktu Windows: $windowsProductKey"
Add-Content -Path $resultsFile -Value ""
Add-Content -Path $resultsFile -Value "Informacje o licencji Office:"
Add-Content -Path $resultsFile -Value $licenseDescription
Add-Content -Path $resultsFile -Value "klucz: $productKey"
Add-Content -Path $resultsFile -Value ""
Add-Content -Path $resultsFile -Value "Model laptopa: $laptopModel, Numer seryjny: $laptopSerialNumber"
Add-Content -Path $resultsFile -Value ""

foreach ($info in $monitorInfo) {
    Add-Content -Path $resultsFile -Value $info
}
Add-Content -Path $resultsFile -Value ""
# Dodaj puste linie dla nieuzupełnionych informacji
$emptyInfo = @("Model telefonu:", "IMEI telefonu:", "Model stacji dokującej:", "Numer seryjny stacji dokującej:", "Model klawiatury:", "Numer klawiatury:", "Model myszki:", "Numer myszki:", "", "uszkodzenia laptopa:", "uszkodzenia telefonu:")
foreach ($info in $emptyInfo) {
    Add-Content -Path $resultsFile -Value $info
}

Write-Host "Wyniki zostały zapisane w pliku: $resultsFile"
