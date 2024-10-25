$IPs443 = @(
'92.52.111.210'
'92.52.111.214'
'client.api.talk2m.com'
'as.pro.talk2m.com'
'92.52.111.210'
'92.52.111.213'
'92.52.111.215'
'as.pro.talk2m.com'
'device.api.talk2m.com'
'device.talk2m.com'
)


$IPs = @(
'87.98.150.3'
'87.98.150.4'
'87.98.150.6'
'92.52.111.209'
'158.177.77.149'
'159.122.188.193'
'159.8.202.193'
'94.236.12.0'
'51.195.79.69'
'35.152.33.84'
'46.105.42.131'
'188.165.49.241'
'46.105.61.42'
'87.98.174.179'
'46.105.60.13'
'92.222.234.115'
'87.98.142.168'
'195.88.246.254'
'device.vpn24.talk2m.com'
'device.vpn25.talk2m.com'
'device.vpn26.talk2m.com'
'device.vpn29.talk2m.com'
'device.vpn33.talk2m.com'
'device.vpn41.talk2m.com'
'device.vpn42.talk2m.com'
'device.vpn44.talk2m.com'
'device.vpn45.talk2m.com'
'device.vpn46.talk2m.com'
'device.vpn47.talk2m.com'
'device.vpn48.talk2m.com'
'device.vpn49.talk2m.com'
'device.vpn51.talk2m.com'
'device.vpn52.talk2m.com'
'92.52.111.211'
'158.177.77.148'
'159.122.188.192'
'159.8.202.192'
'134.213.83.28'
'51.75.89.5'
'15.161.202.145'
'51.91.151.203'
'188.165.49.240'
'151.80.27.57'
'51.91.209.145'
'164.132.171.148'
'51.83.106.48'
'87.98.142.151'
'195.88.246.253'
'client.vpn24.talk2m.com'
'client.vpn25.talk2m.com'
'client.vpn26.talk2m.com'
'client.vpn29.talk2m.com'
'client.vpn33.talk2m.com'
'client.vpn41.talk2m.com'
'client.vpn42.talk2m.com'
'client.vpn44.talk2m.com'
'client.vpn45.talk2m.com'
'client.vpn46.talk2m.com'
'client.vpn47.talk2m.com'
'client.vpn48.talk2m.com'
'client.vpn49.talk2m.com'
'client.vpn51.talk2m.com'
'client.vpn52.talk2m.com'
        )


Write-Host "SPRAWDZANIE PING" -ForegroundColor GREEN
foreach($IP in $IPs443){ Test-Connection $IP -Count 1 }


foreach($IP in $IPs)
    {
    Test-Connection $IP -Count 1
       }


    
Write-Host "SPRAWDZANIE PORTU 443" -ForegroundColor GREEN
foreach($IP in $IPs)
    {
    Test-NetConnection -ComputerName $IP -InformationLevel Quiet -port 443
       }

Write-Host "SPRAWDZANIE PORTU 1194" -ForegroundColor GREEN
foreach($IP in $IPs)
    {
            Test-NetConnection -ComputerName $IP -InformationLevel detailed -port 1194
       }

