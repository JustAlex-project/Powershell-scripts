


 

#get regedit
$users = get-childitem REGISTRY::HKEY_USERS  -ErrorAction SilentlyContinue

#search user
foreach($user in $users){
        #find logged user
     if ((get-childitem REGISTRY::$user    -ErrorAction SilentlyContinue | Select-Object Name | Split-Path -Leaf |Where-Object {$_ -like 'Volatile Environment}'} )  -ne $null  ) {

        $startup = get-itemproperty  REGISTRY::\$user\SOFTWARE\Microsoft\Office\16.0\Lync -Name AutoOpenMainWindowWhenStartup -ErrorAction SilentlyContinue
        #disable autostart for software
        try {
            set-ItemProperty  REGISTRY::\$user\SOFTWARE\Microsoft\Office\16.0\Lync -Name AutoOpenMainWindowWhenStartup -Value 0
            $result = (get-itemproperty  REGISTRY::\$user\SOFTWARE\Microsoft\Office\16.0\Lync -Name AutoOpenMainWindowWhenStartup -ErrorAction SilentlyContinue).AutoOpenMainWindowWhenStartup
            Write-log -msg "$result"
        } catch{
            Write-error "Error $($exception.message)"
        }#eo catch


        # disable another registry
        $startup_1 = get-itemproperty  REGISTRY::\$user\SOFTWARE\Microsoft\Windows\CurrentVersion\Run -Name Lync -ErrorAction SilentlyContinue

        if (($startup_1 -ne $null) -or ($startup_1.Length -ne 0))
            {
                Remove-ItemProperty  REGISTRY::\$user\SOFTWARE\Microsoft\Windows\CurrentVersion\Run -Name Lync
                
            }
    }
}