#################
# configuration #
#################
# Select path for logs
$path = "C:\temp\SimplySign.log"
$date = "[$(get-date -Format "yyyy/MM/dd HH:mm:ss")]"
function Write-log {
    param (

        [Parameter(Mandatory = $true)]
        [string]
        $msg
    )
    "$date $msg" | Add-Content $path
}


#################
#    Script     #
#################

#get product key of current version
$old_simply = Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall, HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall | Get-ItemProperty | Where-Object { $_.DisplayName -match 'SimplySign' }
Write-log -msg "Usuwanie SimplySign w wersji: $($old_simply.DisplayVersion)"

# delete current version
MsiExec.exe /X $old_simply.PSChildName /qn

#little timeout
Start-Sleep -Seconds 5

# install new version with enabled logging
Write-log -msg "Instalowanie najnowszej wersji SimplySign"
msiexec.exe /i "SimplySignDesktop-PL-64.msi" /qn /norestart /L*V "C:\temp\SimplySign_install.log" 

# Check current version
Start-Sleep -Seconds 5
$new_simply = Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall, HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall | Get-ItemProperty | Where-Object { $_.DisplayName -match 'SimplySign' }
Write-log -msg "Obecna wersja SimplySign: $($new_simply.DisplayVersion)"


