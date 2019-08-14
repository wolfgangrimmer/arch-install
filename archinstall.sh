#!/bin/sh

partition(){
    (
    #echo o # Create a new empty DOS partition table

    ##wipe drive
    echo d      # Delete partition
    echo        # Partition numer
    echo d      # Delete partition
    echo        # Partition numer
    echo d      # Delete partition
    echo        # Partition numer
    echo d      # Delete partition
    echo        # Partition numer

    ##boot
    echo n      # Add a new partition
    echo p      # Primary partition
    echo 1      # Partition number
    echo        # First sector (Accept default: 1)
    echo +1G    # Last sector (Accept default: varies)

    ##swap
    echo n      # Add a new partition
    echo p      # Primary partition
    echo 2      # Partition number
    echo        # First sector
    echo +8G    # Last sector (Accept default: varies)

    ##root
    echo n      # Add a new partition
    echo p      # Primary partition
    echo 3      # Partition number
    echo        # First sector
    echo +32G   # Last sector (Accept default: varies)

    ##home
    echo n      # Add a new partition
    echo p      # Primary partition
    echo 4      # Partition number
    echo        # First sector
    echo        # Last sector (To the end)

    #Write Changes
    echo w 
    ) | sudo fdisk /dev/sd$driveletter
}

makefilesystems(){
    mkfs.ext4 /dev/sd$11
    mkfs.ext4 /dev/sd$13
    mkfs.ext4 /dev/sd$14
    mkswap /dev/sd$12
    swapon /dev/sd$12
}

mountpartitions(){
    mkdir /mnt/home
    mkdir /mnt/boot
    mount /dev/sd$13 /mnt/
    mount /dev/sd$11 /mnt/boot
    mount /dev/sd$14 /mnt/home
}

installarch(){
    pacstrap /mnt base base-devel vim networkmanager
}

postinstallation(){
    generatefstab
    arch-chroot /mnt                    # Switches to newly created arch as root
    systemctl enable NetworkManager     # NetworkManager enabled at startup
    installgrub $1
    generatelocale
    settimezone
    sethostname
    echo "Set root password"
    passwd
}

generatefstab(){
    genfstab -U /mnt                    # Displays fstab to user
    genfstab -U /mnt >> /mnt/etc/fstab  # -U is for UUIDS
}

installgrub(){
    pacman -S grub
    grub-install --target=i386-pc /dev/sd$1
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
    echo "gib hostname"
    read $hostname
    echo $hostname > /etc/hostname
}


lsblk
echo Which drive to format
read $driveLetter
partition $driveLetter
makefilesystems $driveLetter
mountpartitions
installarch
postinstallation $driveletter