# SnowGem-Masternode-Setup
Bash script for easily installing a masternode on a linux vps

Note: This script is a beta and has only been tested on ubuntu 16.04. Report any bugs and I will do my best to fix them.

## Create a sudo user so you are not running as root
Replace username with an actual username such as "node"
```
adduser username
usermod -aG sudo username
su username
cd ~
```

## Download
```
wget https://raw.githubusercontent.com/zzzpotato/SnowGem-Masternode-Setup/master/masternode-setup.sh; chmod 755 masternode-setup.sh
```

## Run the script
```
bash masternode-setup.sh
```

## Thanks

If you need assistance or find an issue within the script, contact me on discord at potato#4515 and I will try to help you resolve it. You can thank me by mining on my SnowGem pool at https://xsgpool.com/
