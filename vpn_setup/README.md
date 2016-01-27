# VPN Setup
This is a set of scripts that I wrote to auto-configure a SoftEther based VPN server on an ARM base. The script will install all necessary packages, SoftEther, and then configure softether using the "vonconfig.txt" file. Additional configurations are saved in the "configs" directory - the script doesn't care about this directory. Just overwrite the "vpnconfig.txt" with the desired config.

## Running

- chmod +x vpn_setup_script.sh
- Run with the following options
-  --install: performs the full install. Downloads, extracts, installs, and configures a basic SoftEtherVPN.
-  --uninstall: uninstalls the SoftEtherVPN.
-  --clean: Deletes the "wrkdir" and "logs" direcotries.

## Notes
Passwords and shared secret's have been removed. Be sure to configure them before running.

Should run fine on other processors, just swtich the URL in the script to download a different build of SoftEtherVPN.