#lokalizacja pliku csv z danymi wyjściowymi
$path = "\\fls\FLS\IT\Skrypty\AD_account_lockout\log.csv"

# Wczytanie pliku CSV i uzyskanie najnowszej daty
if (Test-Path $path) {
    $csvContent = Import-Csv $path -Delimiter ';' -Header 'Time', 'User', 'Device'
    if ($csvContent) {
        $latestDate = ($csvContent | Sort-Object { [DateTime]$_.Time } -Descending | Select-Object -First 1).Time
        $latestDate = [DateTime]::Parse($latestDate)
    }
    else {
        $latestDate = [DateTime]::Parse("01/01/2024 00:00:00")
    }
}
else {
    $latestDate = [DateTime]::Parse("01/01/2024 00:00:00")
}

#pobieranie odpowiednich zdarzeń z Event Logu
$events = (Get-EventLog -LogName Security -InstanceId 4740 -after $latestDate | Sort-Object TimeGenerated)

#deklaracja pustej zmiennej do przechowywania wartości
$output = ""


foreach ($event in $events) {

    #uzyskanie czasu zdarzenia
    $time = $event.TimeGenerated

    # Uzyskanie nazwy użytkownika z tekstu
    $user = ($event.Message -split "Locked Out:")[1] | Select-String -Pattern "(?<=Account Name:\s+)\S+" | % { $_.Matches.Value }

    # Uzyskanie nazwy urządzenia z tekstu
    $device = ($event.Message | Select-String -Pattern "(?<=Caller Computer Name:\s+)\S+").Matches.Value 

    #łączenie wartości w jednej linii, rozdzielając je średnikiem
    $output += "$time;$user;$device"

    #dodanie nowej linii tylko wtedy, gdy są jeszcze inne wydarzenia do przetworzenia
    if ($event -ne $events[-1]) {
        $output += "`n"
    }
}



#dodanie wartości do pliku, jeśli znaleziono nowe zdarzenia
if ($events) {
    Add-Content $path $output
}


#sprawdzanie czy jakies konto zostało zablokowane z powodu przekroczenie liczby błednych logować
$webhookUrl = "https://discord.com/api/webhooks/112761288406549496/zhGeuGadsh82JGymzUhDetujH27d5mLhUfMsdfEtHh3xYg1DFerygfRIW4GgrMER-cf3TUa"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12



$lockouts = Import-Csv $path -Delimiter ';' -Header 'Time', 'User', 'Device' | Select-Object -Property Time, User, Device | Where-Object { $_.Time -gt $latestDate }

if ($lockouts) {
    foreach ($lockout in $lockouts) {
        $message = @{
            content = "$time Konto Użytkownika $user zostało zablokowane na komputerze $device"
        }

        $jsonMessage = $message | ConvertTo-Json -Compress
        $jsonBytes = [System.Text.Encoding]::UTF8.GetBytes($jsonMessage)
        Invoke-WebRequest -Uri $webhookUrl -Method Post -Body $jsonBytes -ContentType "application/json"
        
    }
}

