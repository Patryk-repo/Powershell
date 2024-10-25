# Zmienne do połączenia i zarządzania uprawnieniami
$adminEmail = ""  # zmień na swój adres admina 
$userEmail = ""   # adres e-mail użytkownika, którego kalendarz ma być zmodyfikowany
$guestEmail = ""         # osoba, której nadajesz uprawnienia
$permissionLevel = "Reviewer"                 # poziom uprawnień: Owner, Editor, Reviewer itd.

# Sprawdzenie, czy moduł Exchange Online Management jest już zainstalowany
if (-not (Get-Module -ListAvailable -Name ExchangeOnlineManagement)) {
    # Instalacja modułu Exchange Online Management, jeśli nie jest zainstalowany
    Install-Module -Name ExchangeOnlineManagement -Force -AllowClobber
}
# Import modułu Exchange Online Management
Import-Module ExchangeOnlineManagement

# Połączenie z Exchange Online
Connect-ExchangeOnline -UserPrincipalName $adminEmail

# Zmiana uprawnień kalendarza
try {
    # Spróbuj zmienić uprawnienia
    Set-MailboxFolderPermission -Identity "${userEmail}:\kalendarz" -User $guestEmail -AccessRights $permissionLevel -ErrorAction Stop
    Write-Host "Uprawnienia zostały zmienione."
}
catch {
    # Jeśli wystąpi błąd (np. brak istniejących uprawnień), dodaj uprawnienia
    Add-MailboxFolderPermission -Identity "${userEmail}:\kalendarz" -User $guestEmail -AccessRights $permissionLevel
    Write-Host "Uprawnienia zostały dodane."
}

# Wyświetlenie aktualnych uprawnień kalendarza
Get-MailboxFolderPermission -Identity "${userEmail}:\kalendarz"
