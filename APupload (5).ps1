
#Flash Player Uninstaller first
############################################################
# Variables
$fluninstaller = "https://fpdownload.macromedia.com/get/flashplayer/current/support/uninstall_flash_player.exe"
$fluninstallerpath = "C:\temp\uninstall_flash_player.exe"
$MSUninstallerKB = "http://download.windowsupdate.com/c/msdownload/update/software/updt/2020/10/windows10.0-kb4577586-x64_ec16e118cd8b99df185402c7a0c65a31e031a6f0.msu"
$flashloc1 = "C:\Windows\system32\Macromed\Flash"
$flashloc2 = "C:\Windows\SysWOW64\Macromed\Flash"
$flashloc3 = "%appdata%\Adobe\Flash Player"
$flashloc4 = "%appdata%\Macromedia\Flash Player"
$flashloc5 = "C:\Windows\SysWOW64\FlashPlayerApp.exe"
$flashloc6 = "C:\Windows\SysWOW64\FlashPlayerCPLApp.cpl"
$flwinupdate = "kb4577586.msu"
$winversion = "$((Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").ReleaseId)"

$Flashutil = (Get-Childitem C:\Windows\system32\Macromed\Flash\FlashUtil*ActiveX.exe -name -ErrorAction SilentlyContinue)
$FlashTest = (Test-Path C:\Windows\system32\Macromed\Flash\FlashUtil*ActiveX.exe)
$Flashutil1 = (Get-Childitem C:\Windows\system32\Macromed\Flash\FlashUtil*Plugin.exe -name -ErrorAction SilentlyContinue)
$FlashTest1 = (Test-Path C:\Windows\system32\Macromed\Flash\FlashUtil*Plugin.exe)
$Flashutil2 = (Get-Childitem C:\Windows\SysWOW64\Macromed\Flash\FlashUtil*ActiveX.exe -name -ErrorAction SilentlyContinue)
$Flashtest2 = (Test-Path C:\Windows\SysWOW64\Macromed\Flash\FlashUtil*ActiveX.exe)

#Download Uninstaller and run silently
$ProgressPreference = 'SilentlyContinue'
Write-Host "`n`nDetecting and Uninstalling flash player first to avoid any DT block issue ..."
Invoke-WebRequest "$fluninstaller" -OutFile (New-Item -Path "C:\temp\uninstall_flash_player.exe" -Force)
Write-Host "`n`nDownload completed .. Running Installer "
Start-Process "C:\temp\uninstall_flash_player.exe" -Argumentlist "-uninstall" -Wait -PassThru -ErrorAction SilentlyContinue
Write-Host "`nFinished Running Adobe Uninstaller" -ForegroundColor Green -BackgroundColor Black

#Download and run MS KB4577586
Write-Host "`n`nDownloading Microsoft Update KB4577586 for win build 1909 ... "
Invoke-WebRequest "$MSUninstallerKB" -OutFile (New-Item -Path "C:\temp\kb4577586.msu" -Force)
Write-Host "`n`nDownload Complete: Installing KB4577586 ... "
If ($winversion -eq '1909'){
    wusa.exe "$env:SystemDrive\temp\$flwinupdate" /quiet /norestart
    Write-Host "`n`nFinished Runing Windows Update KB4577586" -ForegroundColor Green -BackgroundColor Black
} 
else {
    Write-Host "`n`nWin version is  $winversion"
    Write-Host "`nSkipping KB4577586. Windows build is not 1909" -Foregroundcolor Red -BackgroundColor Black
}

Write-Host "Moving on... Uninstalling any ActiveX Plugins " -ForegroundColor Yellow -BackgroundColor Black
Write-Host "---------------------------------------------"

# Run Flash uninstallers from System32\Macromed\Flash folder
If ($FlashTest -eq $True){
    Start-Process -FilePath "C:\Windows\system32\Macromed\Flash\$Flashutil" -Argumentlist "-uninstall" -ErrorAction SilentlyContinue
    Write-host "Successfully ran ActiveX Uninstaller" -ForegroundColor Green -BackgroundColor Black
}
else{
    Write-Host "No ActiveX Plugin foundd" -ForegroundColor Green
}

If ($FlashTest1 -eq $True){
    Start-Process -FilePath "C:\Windows\system32\Macromed\Flash\$Flashutil1" -Argumentlist "-uninstall" -ErrorAction SilentlyContinue
    Write-host "Successfully ran NPAPI Uninstaller" -ForegroundColor Green -BackgroundColor Black
}
else{
    Write-Host "No NPAPI plugin found" -ForegroundColor Green
}

If ($FlashTest2 -eq $True){
    Start-Process -FilePath "C:\Windows\SysWOW64\Macromed\Flash\$Flashutil2" -Argumentlist "-uninstall" -ErrorAction SilentlyContinue
    Write-host "Successfully ran ActiveX [SysWOW64] Uninstaller" -ForegroundColor Green -BackgroundColor Black
}
else{
    Write-Host "ActiveX Plugin [SysWOW64] not found" -ForegroundColor Green
}

# Take Ownershp and Force delete Flash Sysytem folders 
# Folder 1 in System32
if (Test-Path $flashloc1){
    takeown /a /r /d Y /f $flashloc1
    cmd.exe /c "cacls C:\Windows\System32\Macromed\Flash /E /T /G %UserDomain%\%UserName%:F"
    if ($LASTEXITCODE -eq "0" ){
        Write-Host "`n`nDeleting: $flashloc1" -Foregroundcolor Yellow
        Remove-Item -path "$flashloc1" -Force -Recurse -ErrorAction SilentlyContinue
    }
}
else 
{
    Write-Host "`n`n $flashloc1 not found" -ForegroundColor Green
}

# Folder 2 in SysWoW64
if (Test-Path $flashloc2){
    takeown /a /r /d Y /f $flashloc2
    cmd.exe /c "cacls C:\Windows\SysWOW64\Macromed\Flash /E /T /G %UserDomain%\%UserName%:F"
    if ($LASTEXITCODE -eq "0" ){
        Write-Host "`n`nDeleting: $flashloc2" -Foregroundcolor Yellow
        Remove-Item -path "$flashloc2" -Force -Recurse -ErrorAction SilentlyContinue
    }
}
else {
    Write-Host "`n`n $flashloc2 not found" -ForegroundColor Green
}

# Delete AppData Flash folders
if (Test-Path $flashloc3){
    Write-Host "`n`nDeleting folder: $flashloc3" -Foregroundcolor Yellow
    Remove-Item -path "$flashloc3" -Force -Recurse
}
else {
    Write-Host "`n`n $flashloc3 not found" -ForegroundColor Green
}

if (Test-Path $flashloc4){
    Write-Host "`n`nDeleting folder: $flashloc4" -Foregroundcolor Yellow
    Remove-Item -path "$flashloc4" -Force -Recurse
}
else {
    Write-Host "`n`n $flashloc4 not found" -ForegroundColor Green
}

# Delete FlashPlayerApp and FlashPlayerCPLApp.cpl file in SysWow64 folder
if (Test-Path $flashloc5){
    cmd.exe /c "icacls C:\Windows\SysWOW64\FlashPlayerApp.exe /grant %UserDomain%\%UserName%:F"
    if ($LASTEXITCODE -eq "0" ){
        Write-Host "`n`nDeleting: $flashloc5" -Foregroundcolor Yellow
        Remove-Item -path "$flashloc5"
    }
}
else {
    Write-Host "`n`n $flashloc5 not found" -ForegroundColor Green
}

if (Test-Path $flashloc6){
    cmd.exe /c "icacls C:\Windows\SysWOW64\FlashPlayerCPLApp.cpl /grant %UserDomain%\%UserName%:F"
    if ($LASTEXITCODE -eq "0" ){
        Write-Host "`n`nDeleting: $flashloc6" -Foregroundcolor Yellow
        Remove-Item -path "$flashloc6"
   }
}
else {
    Write-Host "`n`n $flashloc6 not found" -ForegroundColor Green
}

#Remove downloaded temp files
if (Test-Path $fluninstallerpath){
    Remove-Item -path $fluninstallerpath
}
if (Test-Path "C:\temp\kb4577586.msu"){
    Remove-Item -Path "C:\temp\kb4577586.msu"
}
Write-Host "`n`nFlash Player Removed! Continuing . . .`n`n" -Foregroundcolor Green -BackgroundColor Black

############################################
# Start Hash Import 
############################################
#Set level temporarily to trusted
Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
# Install Nuget and  Get-WindowsAutopilotinfo
Install-PackageProvider -Name NuGet -Force -MinimumVersion 2.8.5.201 -Scope CurrentUser -Verbose -ErrorAction Stop
Install-Script Get-WindowsAutoPilotInfo -Force -Confirm:$false -Verbose -Scope CurrentUser -ErrorAction Stop
if ($?){
    Write-Host "Get-WindowsAutoPilotInfo Installed. Wait for MS login window..." -ForegroundColor Green
}
#Set level back to default : unstrusted
Set-PSRepository -Name 'PSGallery' -InstallationPolicy Untrusted
# Run Get-WindowsAutopilotinfo online
Get-WindowsAutopilotinfo -Online