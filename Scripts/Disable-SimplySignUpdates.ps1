#################
# configuration #
#################

function Write-log {
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $msg
    )
    $date = "[$(get-date -Format "yyyy/MM/dd HH:mm:ss")]"
    $path = "C:\temp\SimplySign_updates.log"
    
    "$date $msg" | Add-Content $path
}
    
# get installation path
$installation_path = "C:\Program Files\Certum\SimplySign Desktop\proCertum SmartSign\"
    
    
# check if folder exists
if (Test-Path $installation_path) {
    
        
    try {
        # copy fake url check website
        Copy-Item  "<source_file>" -Destination $installation_path -Force
        Write-log -msg "Skopiowano plik version_check"
    
             
        Write-log -msg "Ustawianie rejestru"
    
        # change url check website to fake one
        Set-Itemproperty -path  "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Certum\SimplySign" -Name "SSDVersionAddress" -Value "https://www.certum.pl/pl/software_version/ssd_win_pl.xml12"
    
        $check = (get-itemproperty  "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Certum\SimplySign").SSDVersionAddress
    
        Write-log -msg "Ustawiono $check"
    
    
    
    
    }
    catch {
            
        Write-log -msg "Błąd $($exception.message)"
        
    }
        
    
}
else {
    
    Write-log -msg "Nie odnaleziono folderu simply sign"
    
}