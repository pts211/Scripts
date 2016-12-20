# Paul Sites
# 2016

#Before this will work, run: Set-ExecutionPolicy unrestricted


#Enable mapping drives to both Admin and user account (Requires restart).
$registryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
$name = "EnableLinkedConnections"
$value = "1"
IF(!(Test-Path $registryPath)) {
    New-Item -Path $registryPath -Force | Out-Null
    New-ItemProperty -Path $registryPath -Name $name -Value $value -PropertyType DWORD -Force | Out-Null
} ELSE {
    New-ItemProperty -Path $registryPath -Name $name -Value $value -PropertyType DWORD -Force | Out-Null
}

#Restart-Computer -Wait
#New-Item c:\new_file.txt -type file

net use * /delete /y
net use X: \\STORAGE\setups /user:user1 user1 /persistent:yes

#Install chocolatey
iwr https://chocolatey.org/install.ps1 -UseBasicParsing | iex

choco install googlechrome -y
choco install 7zip.install -y
choco install adobereader -y
choco install setpoint -y
choco install officeproplus2013 -y
choco install autodesk-fusion360 -y



$pinfo = New-Object System.Diagnostics.ProcessStartInfo
$pinfo.FileName = "C:\Autodesk_Inventor_2016\Img\Setup.exe"
$pinfo.RedirectStandardError = $true
$pinfo.RedirectStandardOutput = $true
$pinfo.UseShellExecute = $false
$pinfo.Arguments = "/W /qb /I C:\Autodesk_Inventor_2016\Img\Inventor 2016.ini /language en-us"
$p = New-Object System.Diagnostics.Process
$p.StartInfo = $pinfo
$p.Start() | Out-Null
#Do Other Stuff Here....
$p.WaitForExit()
$p.ExitCode