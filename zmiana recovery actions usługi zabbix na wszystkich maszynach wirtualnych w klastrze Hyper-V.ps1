$Creds = Get-Credential -Message 'WPROWADŹ POŚWIADCZENIA SERWERÓW WIRTUALNYCH'

$scriptblock = {
    param($VMname, $creds)
    # Zmiana recovery actions dla usługi
    $serviceName = '"Zabbix Agent 2"'
    $command = "sc.exe failure $serviceName reset= 86400 actions= restart/5000/restart/5000/`"`"/5000"
    $result = Invoke-Expression -Command $command
    if ($result -match "ChangeServiceConfig2 SUCCESS") {
        Write-Output "Zmieniono recovery actions dla usługi $serviceName na VM $VMname"
    } else {
        Write-Output "Nie udało się zmienić recovery actions dla usługi $serviceName na VM $VMname. Wynik: $result"
    }
}

$nodes = Get-ClusterNode | Where-Object { $_.State -eq 'Up' }
foreach ( $node in $nodes) {
    $VMs = Get-VM -ComputerName $node.Name | Select-Object -ExpandProperty Name
    foreach ($VMname in $VMs) { 
        Invoke-Command -ComputerName $node.Name -Credential $Creds -ScriptBlock $scriptblock -ArgumentList $VMname, $Creds
    }
}
