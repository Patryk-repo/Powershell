# Parametry
$webhookUrl = 'https://discord.com/api/webhooks/112761288406549496/zhGeuGadsh82JGymzUhDetujH27d5mLhUfMsdfEtHh3xYg1DFerygfRIW4GgrMER-cf3TUa' # URL webhooka Discord
$message = 'Sprawdź logi na serwerze plików, ponieważ wykryto plik z rozszerzeniem z kategorii ransomware w FSRM, użyj do tego polecenia get-eventlog -logname Application | where {$_.EventID -eq 8215}' # Treść powiadomienia

# Wysłanie wiadomości na Discord
Invoke-RestMethod -Uri $webhookUrl -Method Post -Body @{ content = $message } -ContentType 'application/x-www-form-urlencoded'
