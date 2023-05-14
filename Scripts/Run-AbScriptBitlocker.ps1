# Skrypt majacy na celu zaszyfrowanie komputera funkcja Bitlocker wg wytycznych firmowych
# By Aleksander Barucha


#
# CHANGELOG
# 

# 1.01 
# Dodano sprawdzenie TPM Activation State w module BIOS

function Run-AbScriptBitlocker
{
	
	
	$crColor1 = $Host.UI.RawUI.BackgroundColor
	$crColor2 = $Host.UI.RawUI.ForegroundColor
	
	
	#Set Cool Color
	function Set-ConsoleColor ($bc, $fc)
	{
		$Host.UI.RawUI.BackgroundColor = $bc
		$Host.UI.RawUI.ForegroundColor = $fc
		Clear-Host
	}
	Set-ConsoleColor 'black' 'green'
	
	
	
	
	#Get Cool Title
	$Napis = @"
  ____ _____ _______ _      ____   _____ _  ________ _____  
 |  _ \_   _|__   __| |    / __ \ / ____| |/ /  ____|  __ \ 
 | |_) || |    | |  | |   | |  | | |    | ' /| |__  | |__) |
 |  _ < | |    | |  | |   | |  | | |    |  < |  __| |  _  / 
 | |_) || |_   | |  | |___| |__| | |____| . \| |____| | \ \ 
 |____/_____|__|_|  |______\____/_\_____|_|\_\______|_|  \_\
 |  _ \ \   / /             /\   | |    |  ____\ \ / /              
 | |_) \ \_/ /             /  \  | |    | |__   \ V /               
 |  _ < \   /             / /\ \ | |    |  __|   > <                
 | |_) | | |             / ____ \| |____| |____ / . \               
 |____/  |_|            /_/    \_\______|______/_/ \_\   
 ==============================================================
                                                            
"@
	
	
	#Get info
	#$creds = Get-Credential -Message "Podaj poswiadczenia Administracyjne"

	
	function Show-Menu
	{
		cls
		$Napis
		 
		Write-Host ""
		Write-Host "     0: Sprawdz Status"
		Write-Host "     1: Sprawdz Mcafee"
		Write-Host "     2: Sprawdz BIOS"
		Write-Host "     3: Sprawdz TPM"
		Write-Host "     4: Rozpoczecie szyfrowania"
		Write-Host "     5: Wyslij klucze"
		Write-Host "     6: Sprawdz klucze"
		Write-Host "     7: ODSZYFROWANIE"
		Write-Host "     8: AWARYJNA NAPRAWA GPO"
		Write-Host ""
		write-host "     H: POMOC"
		Write-Host "     Q: WYJSCIE"
		Write-Host ""
		
		
 
	}
	function main
	{
		$Admin = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")
		if ($Admin -eq $true) { 
			cls
			Show-Menu
			$Selection = Read-Host "     WYBOR: "
			selectionMain
		}
		else
		{
			Write-Error 'WYMAGANE UPRAWNIENIA ADMINISTRATORA'
		}
	
}


function selectionMain
	{
		#Selection
		switch ($selection)
		{
			'0'{
				cls
				$Napis
				Status-Check
				pause
				main
			}
			'1'{
				cls
				$Napis
				Check-Mcafee
				pause
				main
			}
			'2'{
				cls
				$Napis
				Check-BIOS
				pause
				main
			}
			'3'{
				cls
				$Napis
				Check-TPM
				pause
				main
			}
			'4'{
				cls
				$Napis
				Start-Encryption
				pause
				main
			}
			'5'{
				cls
				$Napis
				Send-Keys
				pause
				main
			}
			'6'{
				cls
				$Napis
				Check-Keys
				pause
				main
			}
			'7'{
				cls
				$Napis
				Start-decryption
				pause
				main
			}
			'8'{
				cls
				$Napis
				repair-GPO
				pause
				main
			}
			'H'{
				cls
				Show-Help
				Pause
				main
				
			}
			'q'{
				cls
				Set-ConsoleColor $crColor1 $crColor2
				"WYJSCIE"
				
			}
			default {
				cls
				$napis
				Write-Error "Bledna wartosc"
				Pause
				main
			}
		}
	}
	
	
	function Check-Mcafee
	{
		Write-Host "Sprawdzanie Szyfrowania Mcafee"
		Write-Host ""
		Write-warning "Bledy wskazuja na brak szyfrowania mcafee"
		
		 get-itemproperty "HKLM:\\Software\Wow6432Node\McAfee EndPoint Encryption\MfeEpePc\status\" -Name CryptState | select CryptState -ExpandProperty CryptState
		
		 
	}
	
	function Check-BIOS
	{
		Write-Host "Sprawdzanie modulu BIOS"
		
		#Check for module
		if ((Test-Path "C:\Program Files\WindowsPowerShell\Modules\DellBIOSProvider") -eq $false)
		{
			Write-Host "BRAK MODULU. Rozpoczynam pobieranie"
			Write-Warning 'Pobieranie modulu niemozliwe przy zdalnym uruchomieniu'
			pause
			# wymaga podania lokalizacji plików
			 #Robocopy "\\server\MODULES\DellBIOSProvider"  "C:\Program Files\WindowsPowerShell\Modules\DellBIOSProvider" /E /r:3 /w:10 /MT:32
			
			cls
			Write-Host "powrot do menu"
			
		}
		else
		{
			
			Import-Module DellBIOSProvider
			
			
			$Secure = (Get-Item -Path DellSmbios:\secureboot\secureboot).CurrentValue
			Write-Host "Sprawdzanie Secure boot - [$Secure]"
			
			$TPM = (Get-Item -Path DellSmbios:\TPMSecurity\TPMsecurity).CurrentValue
			Write-Host "Sprawdzanie TPM - [$TPM]"
			
			$TPM_Activation = (Get-Item -Path DellSmbios:\TPMSecurity\TpmActivation).CurrentValue
			Write-Host "Sprawdzanie TPM Aktywacji  - [$TPM_Activation]"
			
			if (($TPM -eq 'Disabled') -or ($Secure -eq 'Disabled') -or ($TPM_Activation -eq 'Disabled')) 
			{
				Write-Host "Wprowadzanie Zmian BIOS"
				if ((Get-Item -Path DellSmbios:\Security\IsAdminPasswordSet | Select-Object -ExpandProperty CurrentValue) -eq $true)
				{
					Write-host "Wykryto haslo BIOS"
					$model = (Get-CimInstance -ClassName Win32_ComputerSystem).model
					$Psw = read-host "Podaj haslo BIOS dla modelu $model  "
					set-Item -Path DellSmbios:\TPMSecurity\TPMsecurity -value "Enabled" -password $Psw
					set-Item -Path DellSmbios:\secureboot\secureboot -value "Enabled" -password $Psw
					set-Item -Path DellSmbios:\TPMSecurity\TpmActivation -value "Enabled" -password $Psw
				
					Write-warning "URUCHOM PONOWNIE KOMPUTER"
				}
				else
				{
					set-Item -Path DellSmbios:\TPMSecurity\TPMsecurity -value "Enabled"
					set-Item -Path DellSmbios:\secureboot\secureboot -value "Enabled"
					set-Item -Path DellSmbios:\TPMSecurity\TpmActivation -value "Enabled"
					
					Write-warning "URUCHOM PONOWNIE KOMPUTER"
					
				}
				
				
					
			}
			
		} #end of enabling bios 
		
		
		# CHeck TPM again
		

		
	}
	
	
	
	
	function Check-TPM
	{
		
		Write-Host "Sprawdzanie TPM"
		get-tpm | select tpmpresent, tpmReady, TpmEnabled, tpmactivated
		if ((get-tpm).tpmready -eq $false)
		{
			Write-Host "Wymagana inicjacja TPM. Trwa wykonywanie"
			 Initialize-Tpm
			if ((get-tpm).tpmready -eq $true)
			{
				write-host "Uruchomiono TPM"
				(get-tpm).tpmready
			}
			else
			{
				Write-Host ""
				Write-Warning "Problem z uruchomieniem TPM. Zrestartuj stacje"
				Write-Host ""
			}
			
		}
		
		
	}
	
	
	function Start-Encryption
	{
		
		Import-Module dellbiosprovider
		
		if ((Get-Item -Path DellSmbios:\TPMSecurity\TPMsecurity).CurrentValue -eq 'Disabled')
		{
			
			
			Write-warning " Nie wlaczono modulu tpm. Przerywanie"
			 
			
			
		}
		elseif ((Get-Item -Path DellSmbios:\secureboot\secureboot).CurrentValue -eq 'Disabled')
		{
			
			
			Write-warning " Nie wlaczono SecureBoot. Przerywanie"
			 
			
			
		}
		else
		{
			
			
			
			
			if ((get-tpm).tpmready -eq $true)
			{
				
				
				##Szyfrowanie dysku C
				$BLV = Get-BitLockerVolume -MountPoint 'c:'
				if ($BLV.volumeStatus -eq 'FullyDecrypted')
				{
					Add-BitLockerKeyProtector -MountPoint 'c:' -RecoveryPasswordProtector
					Enable-Bitlocker -MountPoint 'c:' -TpmProtector -skipHardwareTest
				}
				else
				{
					Write-Warning "DYSK C NIE JEST ODSZYFROWANY"
				}
				
				
				#### szyfrowanie dysku D
				$BLV = Get-BitLockerVolume -MountPoint 'd:'
				if ($BLV.volumeStatus -eq 'FullyDecrypted')
				{
					# Add-BitLockerKeyProtector -MountPoint 'd:' -RecoveryPasswordProtector
					Enable-Bitlocker -MountPoint 'd:' -skipHardwareTest -RecoveryPasswordProtector
				}
				else
				{
					Write-Warning "DYSK D NIE JEST ODSZYFROWANY"
				}
				
				
				Start-Sleep -Seconds 30
				
				#### uruchomienie automatycznego odblokowania D
				Enable-BitLockerAutoUnlock -MountPoint "D:"
				
				
			}
			else
			{
				Write-Error "TPM nie przygotowany. Przerywanie szyfrowania."
			}
			 
		}
		
		
		
		
	}
	
	
	
	
	function Send-Keys
	{
		
		
		Write-Host ''
		Write-Host "Wysylanie kluczy"
		$BLV = Get-BitLockerVolume -MountPoint "C:"
		
		foreach ($key in $BLV.KeyProtector)
		{
			if ($key.KeyProtectorType -eq "RecoveryPassword")
			{
				
				Backup-BitLockerKeyProtector -MountPoint "C:" -KeyProtectorId $key.KeyProtectorId
				$key.KeyProtectorId
			}
		}
		
		
		
		
		
		
		$BLV1 = Get-BitLockerVolume -MountPoint "D:"
		
		foreach ($key1 in $BLV1.KeyProtector)
		{
			if ($key1.KeyProtectorType -eq "RecoveryPassword")
			{
				
				Backup-BitLockerKeyProtector -MountPoint "D:" -KeyProtectorId $key1.KeyProtectorId
				$key1.KeyProtectorId
			}
		}
		Write-Host ''
		Write-Host ' '
	}
	
	function Check-Keys
	{
		# zmienić ścieżke logów
		Write-Warning "Zapisywanie kluczy do [C:\Logs\BitlockerKeys.txt]"
		Start-Transcript "C:\Logs\BitlockerKeys.txt" -Append |Out-Null
		(Get-BitLockerVolume -MountPoint C).KeyProtector
		(Get-BitLockerVolume -MountPoint D).KeyProtector
		Stop-Transcript | Out-Null
		
		
	}
	
	function Start-decryption
	{
		Write-Host ""
		Write-Warning "DYSKI MUSZA BYC ODBLOKOWANE"
		pause
		try
		{
			Disable-BitLockerAutoUnlock -MountPoint D:
		}
		catch
		{
			$exception.message
		}
		start-sleep 3
		
		
		try
		{
			Disable-BitLocker -MountPoint D:
			Disable-BitLocker -MountPoint C:
		}
		catch
		{
			$exception.message
		}
		Write-Host ""
		Write-Host "Status: "
		(Get-BitLockerVolume).volumestatus
		Write-Host ""
	}
	
	function repair-GPO
	{
		Write-Host ""
		Write-Host "Rozpoczynanie naprawy GPO"
		try
		{
			 
			remove-item "C:\Windows\System32\GroupPolicy\Machine\Registry.pol" -Force
		}
		catch
		{
			$exception.message
		}
		
		Write-Host ""
		Write-Host "Aktualizowanie GPO"
		echo n | gpupdate /force
		echo n | gpupdate /force
		echo n | gpupdate /force
		Write-Host ""
		Write-Host "ODCZEKAJ KILKA MINUT"
		Write-Host ""
		
	}
	
	function Show-Help
	{
		Write-Host "     0: Sprawdz Status"
		Write-Warning "  Weryfikacja statusu Bitlockera, model szyfrowania oraz jego przebieg"
		Write-Host ""
		Write-Host ""
		Write-Host "     1: Sprawdz Mcafee"
		Write-Warning "  Weryfikacja statusu odszyfrowania Mcafee. Blad wskazuje na brak agenta"
		Write-Host ""
		Write-Host ""
		Write-Host "     2: Sprawdz BIOS"
		Write-Warning "  Weryfikacja ustawien BIOS- TPM oraz SecurityBoot. "
		Write-Warning "  W przypadku wykrycia blednych ustawien podejmowana jest proba naprawy. Przy wykryciu hasla BIOS niezbedne jest jego podanie"
		Write-Warning "  Po modyfikacji wymagany jest restart maszyny"
		Write-Host ""
		Write-Host ""
		Write-Host "     3: Sprawdz TPM"
		Write-Warning "  Weryfikacja statusu TPM. W przypadku blednych ustawien podejmowana jest proba zainicjowania TPM"
		Write-Host ""
		Write-Host ""
		Write-Host "     4: Rozpoczecie szyfrowania"
		Write-Warning "  Weryfikacja ustawien i rozpoczecie procesu szyfrowania. W przypadku blednych ustawien operacja jest przerywana"
		Write-Host ""
		Write-Host ""
		Write-Host "     5: Wyslij klucze"
		Write-Warning "  Proba przeslania kluczy do Active Directory"
		Write-Host ""
		Write-Host ""
		Write-Host "     6: Sprawdz klucze"
		Write-Warning "  Weryfikacja kluczy LOKALNIE. Skrypt dodatkowo zapisuje je w katalogu C:/Logs"
		Write-Host ""
		Write-Host ""
		Write-Host "     7: ODSZYFROWANIE"
		Write-Warning "  Rozpoczecie procesu odszyfrowania stacji. Dysku musza byc odblokowane by proces przebiegl pomyslnie"
		Write-Host ""
		Write-Host ""
		Write-Host "     8: AWARYJNA NAPRAWA GPO"
		Write-Warning "  Restart polityk GPO na maszynie. Konieczne przelogowanie uzystkonika."
		Write-Host ""
		Write-Host ""
		Write-Host "Powered by Aleksander Barucha. W przypadku problemow prosze o kontakt." -ForegroundColor Red -BackgroundColor White
		
		
		
	}
	
	
	function status-check
	{
		Write-Host ""
		Write-Host "SPRAWDZANIE STATUSU"
		Write-Host ""
		Get-BitLockerVolume
		Write-Host ""
	}
	
	main
}
 
