#!/bin/sh
# vpn_setup_script.sh
# Paul Sites 2015.12.21
# This is a script to setup softether VPN, harden SSH, and harden the server to put it on the internet.

# -------------------- VARIABLES --------------------
dir=$(cd -P -- "$(dirname -- "$0")" && pwd -P)
wdir="$dir/wrkdir"

# -------------------- FUNCTIONS --------------------
CleanDirectories() {
  echo -n "Cleaning... "
  #Clean up previous run
  rm -rf wrkdir
  rm -rf logs

  echo "DONE"
}

Uninstall() {
  echo -n "Uninstalling SoftEther... "
  service vpnserver stop  > /dev/null 2>&1
  #/sbin/chkconfig --del vpnserver
  rm -rf "/etc/init.d/vpnserver" > "$dir/logs/cmd.log"
  rm -rf "/usr/local/vpnserver" > "$dir/logs/cmd.log"
  rm -rf "/var/lock/subsys" > "$dir/logs/cmd.log"
  update-rc.d -f vpnserver remove  > /dev/null 2>&1
  echo "DONE."
  
  exit 1
}

Install() {
  #SoftEther VPN Install
  echo "-------------------- SoftEther VPN Install --------------------"
  echo -n "Checking Install... "
  if [ -d "/usr/local/vpnserver" ]; then
    echo "ALREADY INSTALLED. Skipping install."
    return
  else
    echo "NONE. Installing."
  fi
  
  echo -n "Installing prereq's... "
  apt-get -qq install build-essential -y
  echo "DONE"

  cd $wdir

  echo -n "Downloading SoftEther... "
  if [ ! -f "$wdir/softether-vpnserver-v4.19-9599-beta-2015.10.19-linux-arm_eabi-32bit.tar.gz" ]; then
    wget --quiet http://www.softether-download.com/files/softether/v4.19-9599-beta-2015.10.19-tree/Linux/SoftEther_VPN_Server/32bit_-_ARM_EABI/softether-vpnserver-v4.19-9599-beta-2015.10.19-linux-arm_eabi-32bit.tar.gz
    echo "DOWNLOADED"
  else
    echo "ALREADY_EXISTS"
  fi

  echo -n "Extracting SoftEther... "
  tar -xzf softether-vpnserver-v4.19-9599-beta-2015.10.19-linux-arm_eabi-32bit.tar.gz
  echo "DONE"

  cd vpnserver

  echo -n "Making SoftEther... "
  while true; do echo "1"; done | make > "$dir/logs/make.log"
  echo "DONE"

  cd $wdir

  echo -n "Moving SoftEhter... "
  cp -r vpnserver /usr/local
  rm -R vpnserver
  cd /usr/local/vpnserver/
  echo "DONE"
  
  echo -n "Setting SoftEther permissions... "
  chmod 600 *
  chmod 700 vpnserver
  chmod 700 vpncmd
  echo "DONE"

  echo -n "Setting SoftEther to autostart... "
  cp $dir/vpnserver /etc/init.d/
  mkdir /var/lock/subsys
  chmod 755 /etc/init.d/vpnserver && /etc/init.d/vpnserver start > /dev/null 2>&1
  update-rc.d vpnserver defaults > /dev/null 2>&1
  echo "DONE"
}

ConfigureSSH() {
  mkdir -p $wdir/ssh

  echo -n "SSH Configuration..."
  cd $wdir
  file_real=/etc/ssh/sshd_config
  file="$wdir/ssh/sshd_config"

  cp -p $file_real $wdir/ssh
  cp -p $file $file.old &&
  awk '
  $1=="PasswordAuthentication" {$2="yes"}
  $1=="PubkeyAuthentication" {$2="yes"}
  {print}
  ' $file.old > $file
  
  echo "DONE."
}

# -------------------- Input Parameters --------------------
for var in "$@"
do
    echo "$var"
    case "$var" in
        "--" ) break 2;;
        "--clean" )
           CleanDirectories;;
        "--install" )
           Install;;
        "--uninstall" )
           Uninstall;;
        *) echo >&2 "Invalid option: $@"; exit 1;;
   esac    
done


mkdir -p wrkdir
mkdir -p logs

cd $wdir
vpncmd="/usr/local/vpnserver/vpncmd"

Install

echo -n "Validating SoftEther install... "
$vpncmd /TOOLS /CMD check > $dir/logs/vpncmd.log
if grep -q "All checks passed" $dir/logs/vpncmd.log; then
	echo "SUCCESS!"
else
	echo "FAILED. See vpncmd.log for details."
	exit 1
fi

echo -n "Configuring SoftEther VPN... "
#$vpncmd localhost:443 /SERVER /PASSWORD:admin /CMD:ConfigGet > "$dir/softether_config.txt"
#sed -i '1,/﻿# Software Configuration File/d' $dir/softether_config.txt
#sed -i 's/bool Disabled false/bool Disabled true/' $dir/softether_config.txt
#while true; do echo "$dir/softether_config.txt"; done | $vpncmd localhost:443 /SERVER /PASSWORD:admin /CMD:ConfigSet > "$dir/logs/vpncmd_setup_config.log"
#$vpncmd localhost:443 /SERVER /PASSWORD:admin /IN:"$dir/vpnconfig.txt" >"$dir/logs/vpncmd_setup.log"
$vpncmd localhost:443 /SERVER /IN:"$dir/vpnconfig.txt" >"$dir/logs/vpncmd_setup.log"
echo "DONE"

#echo -n "Restarting SoftEther VPN... "
#service vpnserver restart >> $dir/logs/cmd.log
#echo "DONE"

echo "-------------------- SoftEther VPN Install Completed  --------------------"

chmod -R 777 "$dir/logs"

echo "Script Completed."
