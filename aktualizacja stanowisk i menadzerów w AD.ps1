# Importowanie danych z pliku CSV
$data = Import-Csv -Path "\\10.10.55.225\fls\IT\dokumenty\skrypty PS\aktualizacja stanowisk i menadzerow w AD\ad.csv" -Delimiter ';' -Encoding UTF8


# Dla każdego użytkownika na liście
foreach ($user in $data) {
    # Pobranie obiektu użytkownika Active Directory na podstawie nazwy użytkownika
    $adUser = Get-ADUser -Identity $user.username -Properties title, manager

    # Aktualizacja pola "title" i "manager"
    Set-ADUser -Identity $adUser.SamAccountName -Title $user.title -Manager (Get-ADUser -Identity $user.manager).DistinguishedName

    #sprawdzenie poprawności wykonania skryptu

    Get-ADUser -Identity $adUser.SamAccountName -Properties name, title, manager | Select-Object name, title, manager
}