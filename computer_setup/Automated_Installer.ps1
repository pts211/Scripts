# Paul Sites
# 2016

#Before this will work, run: Set-ExecutionPolicy unrestricted

#Functions
function RunProcess($file, $arguments) {
   $pinfo = New-Object System.Diagnostics.ProcessStartInfo
    $pinfo.FileName = $file
    $pinfo.RedirectStandardError = $true
    $pinfo.RedirectStandardOutput = $true
    $pinfo.UseShellExecute = $false
    $pinfo.Arguments = $arguments
    $p = New-Object System.Diagnostics.Process
    $p.StartInfo = $pinfo
    $p.Start() | Out-Null
    $p.WaitForExit()
    return $p.ExitCode
}

Write-Output "Changing registery values..."
Write-Output "...Linked Connections..."
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

Write-Output "...UNC As Intranet..."
#Allow UNC execution.
$registryPath2 = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap"
$name2 = "UNCAsIntranet"
$value2 = "1"
IF(!(Test-Path $registryPath2)) {
    New-Item -Path $registryPath2 -Force | Out-Null
    New-ItemProperty -Path $registryPath2 -Name $name2 -Value $value2 -PropertyType DWORD -Force | Out-Null
} ELSE {
    New-ItemProperty -Path $registryPath2 -Name $name2 -Value $value2 -PropertyType DWORD -Force | Out-Null
}
Write-Output "Changing registery values... DONE"

#Restart-Computer -Wait
#New-Item c:\new_file.txt -type file
Write-Output "Mounting server share..."
net use * /delete /y
net use S: \\STORAGE\setups /user:user1 user1 /persistent:no
Write-Output "Mounting server share... DONE"

Write-Output "Installing Chocolatey packages..."
#Install chocolatey
#iwr https://chocolatey.org/install.ps1 -UseBasicParsing | iex

#choco install googlechrome -y
#choco install 7zip.install -y
#choco install notepadplusplus -y
#choco install adobereader -y
#choco install setpoint -y
#choco install officeproplus2013 -y
#choco install autodesk-fusion360 -y
Write-Output "Installing Chocolatey packages... DONE"

Write-Output "Copying Wallpapers..."
IF( !(Test-Path C:\Wallpapers) )
{
    $from = "S:\Wallpapers\*" 
    $to = "C:\Wallpapers"  
    Copy-Item $from $to -recurse
}
Write-Output "Copying Wallpapers... DONE"

Write-Output "Installing MSI Drivers..."
$msi_files = Get-ChildItem "S:\Drivers\*.msi"
foreach ($msi in $msi_files) 
{
    Write-Output $msi
    Start-Process -FilePath msiexec.exe -ArgumentList "/i $msi /quiet /norestart" -wait
}
Write-Output "Installing MSI Drivers... DONE"

#In order to run the setup off of a network drive, might need to look at this:
# HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\UncAsIntranet

Write-Output "Installing Quadro Driver..."
#Get the connected video cards. Can use as a start to extend this to check for Quadro or GeForce.
#get-wmiobject -class CIM_VideoController -namespace root/cimv2
$vidinstall = "S:\Drivers\Quadro\setup.exe"
$arguments = "-s -i -noreboot -noeula"
RunProcess $vidinstall $arguments
Write-Output "Installing Quadro Driver... DONE"


#Start-Process "S:\Drivers\printer_driver.exe" -NoNewWindow -Wait

Write-Output "Installing Autodesk Inventor..."
$file = "S:\Software\Autodesk_Deploy\Autodesk_Inventor_2016\Img\Setup.exe"
$arguments = "/W /qb /I S:\Software\Autodesk_Deploy\Autodesk_Inventor_2016\Img\Inventor 2016.ini /language en-us"
RunProcess $file $arguments
Write-Output "Installing Autodesk Inventor... DONE"


Write-Output "Installing Autodesk Inventor HSM..."
$file = "S:\Software\Autodesk_Deploy\Autodesk_HSM_2016\Img\Setup.exe"
$arguments = "/W /qb /I S:\Software\Autodesk_Deploy\Autodesk_HSM_2016\Img\Autodesk_HSM_2016.ini /language en-us"
RunProcess $file $arguments
Write-Output "Installing Autodesk Inventor HSM... DONE"
