$Creds = Get-Credential -Message 'WPROWADŹ POŚWIADCZENIA SERWERÓW WIRTUALNYCH'
$UserName = Read-Host "Wpisz nazwę użytkownika dla usługi"
$Password = Read-Host "Wpisz hasło dla usługi" -AsSecureString
$Password = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))
$scriptblock = { param($VMname, $creds) Invoke-Command -VMName $VMname -Credential $creds -ScriptBlock {
        # zmiana użytkownika dla usługi
        #
        $hostname = hostname
        $service = (get-service -name *zabbix*).Name
        $svc_Obj = Get-WmiObject Win32_Service -filter "name='$Service'"
 
        $StopStatus = $svc_Obj.StopService() 
        If ($StopStatus.ReturnValue -eq "0") {
            Write-host "The service '$Service' Stopped successfully" -f Green
        }
        Else {
            Write-host "Failed to Stop the service '$Service' on VM $hostname. Error code: $($StopStatus.ReturnValue)" -f Red
        }
 
        Start-Sleep -Seconds 10
 
        $ChangeStatus = $svc_Obj.change($null, $null, $null, $null, $null,
            $null, $UserName, $Password, $null, $null, $null)
        If ($ChangeStatus.ReturnValue -eq "0") {
            Write-host "Log on account updated sucessfully for the service '$Service' on VM $hostname" -f Green
        }
        Else {
            Write-host "Failed to update Log on account in the service '$Service' on VM $hostname. Error code: $($ChangeStatus.ReturnValue)" -f Red
        }
 
 
        $StartStatus = $svc_Obj.StartService() 
        If ($StartStatus.ReturnValue -eq "0") {
            Write-host "The service '$Service' Started successfully" -f Green
        }
        Else {
            Write-host "Failed to Start the service '$Service' on VM $hostname. Error code: $($StartStatus.ReturnValue)" -f Red
        } } }

$nodes = Get-ClusterNode | Where-Object { $_.State -eq 'Up' }
foreach ( $node in $nodes) {
    $VMs = Get-VM -ComputerName $node.Name
    foreach ($VM in $VMs) { 
        Invoke-Command -ComputerName $node.Name -ScriptBlock $scriptblock -ArgumentList $VM.Name, $creds
    }
}
