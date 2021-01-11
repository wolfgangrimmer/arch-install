#!/bin/sh

postinstallation(){
    systemctl enable NetworkManager     # NetworkManager enabled at startup
    installgrub $1
    generatelocale
    settimezone
    sethostname
    echo "Set root password"
    passwd
}

installgrub(){
    pacman -S grub
    grub-install --target=i386-pc /dev/sd$
    grub-mkconfig -o /boot/grub/grub.cfg
}

generatelocale(){
    sed -i -e 's/#en_US/en_US/g' /etc/locale.gen
    locale-gen
    echo "LANG=en-US.UTF-8" > /etc/locale.conf
}

settimezone(){
    ls -sf /usr/share/zoneinfo/Poland /etc/localtime
}

sethostname(){
    read -p "Hostname : " hostname
    echo $hostname > /etc/hostname
}

lsblk
read -p "Drive letter : " driveLetter
postinstallation $driveLetter
echo "Run larbs.sh after reboot"
