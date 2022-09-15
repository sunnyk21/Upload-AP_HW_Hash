############################################
# Start Hash Import 
############################################
#Set level temporarily to trusted
Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
# Install Nuget and  Get-WindowsAutopilotinfo
Install-PackageProvider -Name NuGet -Force -MinimumVersion 2.8.5.201 -Verbose
Install-Script Get-WindowsAutoPilotInfo -Force -Confirm:$false -Verbose
if ($?){
    Write-Host "Get-WindowsAutoPilotInfo Installed. Wait for MS login window..." -ForegroundColor Green
}
#Set level back to default : unstrusted
Set-PSRepository -Name 'PSGallery' -InstallationPolicy Untrusted
# Run Get-WindowsAutopilotinfo online
Get-WindowsAutopilotinfo -Online
Read-Host -Prompt "Press Enter to exit"
