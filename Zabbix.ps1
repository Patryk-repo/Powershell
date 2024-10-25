
#funkcja odistalowująca zabbixa
function Uninstall-ZabbixAgent
{
Stop-Service "Zabbix Agent 2" -ErrorAction SilentlyContinue -Force
$service = Get-WmiObject -Class Win32_Service -Filter "Name='Zabbix Agent 2'"
$service.delete()
Remove-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Services\EventLog\Application\Zabbix Agent 2" -ErrorAction SilentlyContinue -Force
Remove-Item -Path C:\Zabbix -Recurse -Force
}

Uninstall-ZabbixAgent
