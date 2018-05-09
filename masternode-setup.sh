#!/bin/bash

###Check user
if [ "$EUID" -eq 0 ]
  then
        echo -e "Warning: You should not run this as root! Create a new user with sudo permissions!\nThis can be done with (replace username with an actual username such as node):\nadduser username\nusermod -aG sudo username\nsu username\ncd ~\n\nYou will be in a new home directory. Make sure you redownload the script or move it from your /root directory!"
        exit
fi

###Begin
clear
read -n1 -r -p "The official guide can be found at https://snowgem.org/how-to-setup-a-masternode/ which contains screenshots of the following steps... Press any key to continue...";echo
read -n1 -r -p "Before you begin, make sure you have already sent your collateral to an address and waited for 15 confirmations! Press any key to continue...";echo
read -n1 -r -p "Go to Masternode tab (On the wallet which you received 10000 XSG) and click on “Get MN Priv Key” button, then copy the private key to notepad. Press any key to continue...";echo
read -n1 -r -p "The private key looks like this: 5JJaWWprqeNLwEYd5JucbUne68m51yumu5Peen5j5hrg4nrjej4. Press any key to continue...";echo
read -n1 -r -p "Click on “Get Outputs” button, then copy outputs to notepad. Press any key to continue...";echo
read -n1 -r -p "The outputs looks like this: 8b70363be7e585dde357124e67b182da25053d2f45c8454t4t45e4r5edddgdr4 0. Press any key to continue...";echo
read -n1 -r -p "Click on the “Configure Masternode” button and enter the copied information. Your Alias name must not contain white space! Press any key to continue...";echo
read -n1 -r -p "Then Click on Configure. A restart message will appear and you need to restart your wallet to apply the new configuration. Press any key to continue...";echo

read -n1 -r -p "Let's begin setting up the VPS... Press any key to continue...";echo

###Prerequisites
sudo apt-get update
sudo apt-get -y install build-essential pkg-config libc6-dev m4 g++-multilib autoconf libtool ncurses-dev git python python-zmq zlib1g-dev wget bsdmainutils automake curl unzip nano

###Snowgem Config
mkdir ~/.snowgem

if [ ! -e ~/.snowgem/snowgem.conf ];
then
        echo -e "#In your wallet go to Tools -> Copy snowgem.conf data.\n#Paste your snowgem.conf data at the bottom of this file.\n#Then use combo Ctr + X, then type Y then Enter to save.\n\n" >> ~/.snowgem/snowgem.conf
fi
nano ~/.snowgem/snowgem.conf

if [ -e ~/.snowgem/snowgem.conf ];
then
        echo -e "#Do not modify. These will help with getting more connections for the blockchain.\nport=16113\naddnode=45.76.111.3\naddnode=45.76.137.106\naddnode=45.32.79.163\naddnode=207.246.67.167\naddnode=45.77.70.230\naddnode=45.77.160.169\naddnode=104.238.149.197\naddnode=207.148.68.108\naddnode=104.24.117.245\naddnode=142.44.214.53\naddnode=158.69.253.17\naddnode=104.24.123.22\naddnode=104.25.244.104\naddnode=46.252.42.43\naddnode=46.254.16.114\naddnode=24.129.114.44\naddnode=108.249.146.109\naddnode=81.29.192.216\naddnode=46.254.16.114" >> ~/.snowgem/snowgem.conf
fi

###Masternode Config

if [ ! -e ~/.snowgem/masternode.conf ];
then
        echo -e "#In your wallet go to Tools -> Copy alias data.\n#Paste your alias data at the bottom of this file.\n#Then use combo Ctr + X, then type Y then Enter to save.\n\n" >> ~/.snowgem/masternode.conf
fi
nano ~/.snowgem/masternode.conf

###Params
echo
read -n1 -r -p "Install Params... Press any key to continue";echo
wget https://snowgem.org/downloads/snowgemparams.zip
unzip -o snowgemparams.zip -d ~/

###Setup Swap
echo
read -n1 -r -p "Setup virtual memory... Press any key to continue";echo

sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

free -h

echo
read -n1 -r -p "You should see 4.0G under Total Swap... Press any key to continue";echo

sudo sed -i -e "\$a\/swapfile none swap sw 0" /etc/fstab

###Build the binary

read -r -p "Do you need to build snowgem? (Only choose no if you have already done this) [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
then
	read -n1 -r -p "We are ready to start the build. This can take awhile... Press any key to continue";echo

	git clone https://github.com/Snowgem/Snowgem.git snowgem-wallet

	cd snowgem-wallet

	chmod +x zcutil/build.sh depends/config.guess depends/config.sub autogen.sh share/genbuild.sh src/leveldb/build_detect_platform

	~/snowgem-wallet/zcutil/build.sh --disable-rust
fi

###Start
~/snowgem-wallet/src/snowgemd --daemon

read -n1 -r -p "Let's make sure no errors appear and that its running... Press any key to continue";echo
read -n1 -r -p "You can run tail ~/.snowgem/debug.log to check this yourself in the future... Press any key to continue";echo


#Set Vars
highestblock="$(wget -nv -qO - https://explorer.snowgem.org/api/getblockcount)"
currentblock="$(~/snowgem-wallet/src/snowgem-cli getblockcount)"

while  [ "$highestblock" != "$currentblock" ]
do
        clear
        highestblock="$(wget -nv -qO - https://explorer.snowgem.org/api/getblockcount)"
        currentblock="$(~/snowgem-wallet/src/snowgem-cli getblockcount)"
        echo "Comparing block heights to ensure server is fully synced";
        echo "Highest: $highestblock";echo "Currently at: $currentblock";
        echo "Checking again in 60 seconds... The install will continue once it's synced.";echo
        echo "Last 20 lines of the log for error checking...";
        echo "===============";
        tail -20 ~/.snowgem/debug.log
	echo "===============";
	echo "Network unreachable errors can be normal. Just ensure the current block height is rising over time...";
        sleep 60
done

###Masternodedebug
echo
read -n1 -r -p "Your blockchain is now synced... Press any key to continue";echo
~/snowgem-wallet/src/snowgem-cli masternodedebug

###Finishing touches
read -n1 -r -p "In your local wallet, select your Alias and then click on the Start Masternode button... Press any key to continue";echo
read -n1 -r -p "You should now see a success message... Press any key to continue";echo
read -n1 -r -p "Now click on the Start Alias button... Press any key to continue";echo
read -n1 -r -p "You should now see another success message... Press any key to continue";echo
read -n1 -r -p "Wait a few minutes for your masternode to be listed in your local wallet... Press any key to continue";echo

~/snowgem-wallet/src/snowgem-cli masternodedebug

read -n1 -r -p "If the response is: “Masternode successfully started“, you’re finished.... Press any key to continue";echo
