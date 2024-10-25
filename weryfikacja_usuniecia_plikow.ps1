#lokalizacja pliku csv z danymi wyjściowymi
$path = "X:\FLS\IT\skrypty\delete_audit\delete.csv"

# Wczytanie pliku CSV i uzyskanie najnowszej daty
if (Test-Path $path) {
    $csvContent = Import-Csv $path -Delimiter ';' -Header 'Time', 'User', 'File', 'Action'
    if ($csvContent) {
        $latestDate = ($csvContent | Sort-Object { [DateTime]$_.Time } -Descending | Select-Object -First 1).Time
        $latestDate = [DateTime]::Parse($latestDate)
    }
    else {
        $latestDate = [DateTime]::Parse("01/01/2023 00:00:00")
    }
}
else {
    $latestDate = [DateTime]::Parse("01/01/2023 00:00:00")
}

#mapowanie identyfikatorów na czytelne nazwy 
$actionMap = @{
    '%%1537' = 'DELETE'
    #tutaj można dodać więcej mapowań, jeśli potrzebne
}

#pobieranie odpowiednich zdarzeń z Event Logu
$events = (Get-EventLog -LogName Security -InstanceId 4663 -after $latestDate | where { $_.Message -like "*0x10000*" } | where { $_.Message -notlike "*.tmp*" } | Sort-Object TimeGenerated)

#deklaracja pustej zmiennej do przechowywania wartości
$output = ""


foreach ($event in $events) {

    #uzyskanie czasu zdarzenia
    $time = $event.TimeGenerated

    # Uzyskanie nazwy użytkownika z tekstu
    $user = ($event.Message | Select-String -Pattern "(?<=Account Name:\s+)\S+").Matches.Value

    #Uzyskanie nazwy pliku
    $file = ($event.Message | Select-String -Pattern "(?<=Object Name:\s+).*?(?=\r?\n)").Matches.Value
    $file = $file.Trim()

    #Uzyskanie typu akcji wykonywanej na pliku
    $actionId = ($event.Message | Select-String -Pattern "(?<=Accesses:\s+)\S+").Matches.Value

    #mapowanie identyfikatora akcji na czytelny opis
    $action = $actionMap[$actionId]

    #łączenie wartości w jednej linii, rozdzielając je średnikiem
    $output += "$time;$user;$file;$action"

    #dodanie nowej linii tylko wtedy, gdy są jeszcze inne wydarzenia do przetworzenia
    if ($event -ne $events[-1]) {
        $output += "`n"
    }
}


#dodanie wartości do pliku, jeśli znaleziono nowe zdarzenia
if ($events) {
    Add-Content $path $output
}


#sprawdzenie czy jakiś użytkownik w ciągu jednej minuty usunął wiecej plików niż wskazuje $treshhold, jesli tak to wysyla powiadomienie na discord
$webhookUrl = "https://discord.com/api/webhooks/112761288406549496/zhGeuGadsh82JGymzUhDetujH27d5mLhUfMsdfEtHh3xYg1DFerygfRIW4GgrMER-cf3TUa"

$threshold = 10
$oneMinute = New-TimeSpan -Minutes 1

$deletes = Import-Csv "X:\FLS\IT\skrypty\delete_audit\delete.csv" -Delimiter ";" -Header 'Time', 'User', 'File', 'Action' | ForEach-Object {
    $dateTime = [DateTime]::ParseExact($_.Time, "MM/dd/yyyy HH:mm:ss", $null)
    [PSCustomObject]@{
        Time = $dateTime
        User = $_.User
    }
} | Select-Object -Property Time, User | Where-Object { $_.Time -gt $latestDate }

$usersCount = @{}

foreach ($delete in $deletes) {
    $user = $delete.User
    if (-not $usersCount.ContainsKey($user)) {
        $usersCount[$user] = @()
    }

    $usersCount[$user] += $delete.Time
}

foreach ($user in $usersCount.Keys) {
    $userEvents = $usersCount[$user]
    $count = 0
    for ($i = 0; $i -lt $userEvents.Count; $i++) {
        $startTime = $userEvents[$i]
        $endTime = $startTime + $oneMinute
        $eventsWithinOneMinute = $userEvents | Where-Object { $_ -ge $startTime -and $_ -lt $endTime }
        $currentCount = $eventsWithinOneMinute.Count

        if ($currentCount -gt $count) {
            $count = $currentCount
        }
    }

    if ($count -gt $threshold) {
        Write-Host "User $user exceeded the threshold with $count events in a single minute."

        $message = @{
            content = "Użytkownik $user w ciągu minuty usunął $count elementów z serwera plików"
        }
        $jsonMessage = $message | ConvertTo-Json -Compress
        $jsonBytes = [System.Text.Encoding]::UTF8.GetBytes($jsonMessage)
        Invoke-WebRequest -Uri $webhookUrl -Method Post -Body $jsonBytes -ContentType "application/json"
    }

}


