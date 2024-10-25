$folder = "C:\ClusterStorage\CSV\Virtual Hard Disks"
$discordWebhookUrl = "https://discord.com/api/webhooks/112761288406549496/zhGeuGadsh82JGymzUhDetujH27d5mLhUfMsdfEtHh3xYg1DFerygfRIW4GgrMER-cf3TUa"

# Znajdź wszystkie pliki .avhdx i zgrupuj je po nazwie maszyny wirtualnej
$vmFileCounts = Get-ChildItem -File -Path $folder -Filter *.avhdx | ForEach-Object {
    $vmName = ($_.Name -split "_")[0]
    $vmName
} | Group-Object | Select-Object Name, Count

# Sprawdź, czy którekolwiek z wyników ma więcej niż 3 pliki
$overLimit = $vmFileCounts | Where-Object { $_.Count -gt 3 }

# Jeśli tak, wyślij powiadomienie na Discord
if ($overLimit) {
    foreach ($item in $overLimit) {
        $content = "Wirtualna maszyna $($item.Name) ma $($item.Count) plików .avhdx"
        $body = @{
            'content' = $content
        }

        $response = Invoke-WebRequest -Uri $discordWebhookUrl -Method POST -Body $body -ContentType "application/x-www-form-urlencoded" -UseBasicParsing
        Write-Host $($item.Name) '-' $($item.Count)
    }
}
