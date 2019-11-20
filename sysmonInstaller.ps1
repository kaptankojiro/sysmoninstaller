#Requires -RunAsAdministrator

# Resources: 
# https://stackoverflow.com/questions/27768303/how-to-unzip-a-file-in-powershell
# https://download.sysinternals.com/files/Sysmon.zip
# https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/master/sysmonconfig-export.xml
# 

clear
Write-Host "This script downloads Sysmon, uninstall if it is installed and install it with SwiftOnSecurity's configuration file." -ForegroundColor red -BackgroundColor white

sleep 2
Write-Host "This script requires administrative rights and internet connection." -ForegroundColor red -BackgroundColor white

sleep 2
Write-Host "Creating a new folder if it is necessary..." -ForegroundColor red -BackgroundColor white

$path = "C:\Sysmon"
If(!(test-path $path))
{
      New-Item -ItemType Directory -Force -Path $path
}


Write-Host "Clearing the folder if it is not empty..." -ForegroundColor red -BackgroundColor white
Get-ChildItem -Path C:\Sysmon\ -Include * -File -Recurse | foreach { $_.Delete()}

$HTTP_Request = [System.Net.WebRequest]::Create('https://download.sysinternals.com/files/Sysmon.zip')
$HTTP_Response = $HTTP_Request.GetResponse()
$HTTP_Status = [int]$HTTP_Response.StatusCode

If ($HTTP_Status -eq 200) {
   Write-Host "Downloading Sysmon file... (https://download.sysinternals.com/files/Sysmon.zip)" -ForegroundColor red -BackgroundColor white
        $WebClient = New-Object System.Net.WebClient
        $WebClient.DownloadFile("https://download.sysinternals.com/files/Sysmon.zip","C:\Sysmon\Sysmon.zip")
		 Write-Host "Sysmon.zip is downloaded." -ForegroundColor red -BackgroundColor white
}
Else {
    Write-Host "The Site may be down, please check your internet connection!"  -ErrorAction Stop  -ForegroundColor red -BackgroundColor white
   
}

$HTTP_Response.Close()

sleep 2

$HTTP_Request = [System.Net.WebRequest]::Create('https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/master/sysmonconfig-export.xml')
$HTTP_Response = $HTTP_Request.GetResponse()
$HTTP_Status = [int]$HTTP_Response.StatusCode

If ($HTTP_Status -eq 200) {
   Write-Host "Downloading txt files for host blocking...  " -ForegroundColor red -BackgroundColor white
        $WebClient = New-Object System.Net.WebClient
        $WebClient.DownloadFile("https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/master/sysmonconfig-export.xml","C:\Sysmon\sysmonconfig-export.xml")
		Write-Host "Config file is downloaded." -ForegroundColor red -BackgroundColor white
}
Else {
    Write-Host "The Site may be down, please check!"  -ErrorAction Stop  -ForegroundColor red -BackgroundColor white
   
}

$HTTP_Response.Close()



Add-Type -AssemblyName System.IO.Compression.FileSystem
function Unzip
{
    param([string]$zipfile, [string]$outpath)

    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
}

Unzip "C:\Sysmon\Sysmon.zip" "C:\Sysmon\"

Get-FileHash C:\Sysmon\Sysmon.zip -Algorithm SHA1 | Format-List

sleep 1
Get-FileHash C:\Sysmon\sysmonconfig-export.xml -Algorithm SHA1 | Format-List
sleep 1

Write-Host "Uninstalling current Sysmon and config if it is necessary..."

cmd /c C:\Sysmon\Sysmon.exe -u

Write-Host "Sysmon is installing with config file..." -ForegroundColor red -BackgroundColor white
cmd /c C:\Sysmon\Sysmon.exe -accepteula -i C:\Sysmon\sysmonconfig-export.xml

if ($arrService.Status -ne 'Running')
{
 
Write-Host "Sysmon is installed and Sysmon service is running." -ForegroundColor red -BackgroundColor white
sleep 1
}
else
{
Write-Host "There is a problem related to installation process, exiting..." -ForegroundColor red -BackgroundColor white
sleep 3
exit
}

