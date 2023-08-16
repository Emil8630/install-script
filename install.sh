#!/bin/bash

usr = $(whoami)

# Backup the original pacman.conf file
sudo cp /etc/pacman.conf /etc/pacman.conf.backup

# Enable the multilib repository by uncommenting the lines
sudo sed -i '/\[multilib\]/,+1 s/^#//' /etc/pacman.conf

# black arch mirrors
curl -O https://blackarch.org/strap.sh
chmod +x strap.sh
sudo ./strap.sh
sudo shred -fzu strap.sh
sudo pacman -Syu --noconfirm 

#Changing Hostname
sudo hostnamectl set-hostname "arch"

# Hardening network settings
sudo sh /home/$usr/github/bw-dwm/archcraft-dwm/shared/bin/hardening.sh

# packages
sudo pacman -Syu --noconfirm xclip discord flatpak caja flameshot python3 python-pip git feh arandr acpi breeze nodejs npm yarn lxappearance materia-gtk-theme xonsh eom net-tools nim mesa mpv keepassxc alacritty dnscrypt-proxy curl thunar qbittorrent ranger libx11 pixman libdbus libconfig libev uthash libxinerama libxft freetype2 geany rofi polybar dunst mpd mpc maim xclip viewnior feh xfce4-power-manager xorg-xsetroot wmname ninja pulsemixer light xcolor zsh fish xfce4-settings zsh hsetroot flatpak wget meson curl cmake neovim exa bat variety adobe-source-code-pro-fonts lib32-fontconfig noto-fonts-emoji ttf-firacode-nerd ufw opendoas

# Installs doas
sudo touch /etc/doas.conf 
sudo echo "permit persist $(whoami) as root" > /etc/doas.conf

# Enabling dnscrypt
sudo systemctl enable --now dnscrypt-proxy.socket

# Getting NixOS package manager & packages
sudo sh <(curl -L https://nixos.org/nix/install) --daemon

# Installing DWM
mkdir ~/github
git clone https://github.com/Emil8630/bw-dwm.git ~/github/bw-dwm
sudo chown -R $(whoami) ~/github/bw-dwm && cd ~/github/bw-dwm/archcraft-dwm/source && sudo make clean install && cd ~/github/bw-dwm/archcraft-dwm/ && makepkg -if --cleanbuild

# virtual machines with "qemu" and "virtual machine manger"
# Checks for conflicts

if sudo pacman -Q gnu-netcat >/dev/null 2>&1; then
    sudo pacman -R --noconfirm gnu-netcat  # gnu-netcat is installed
else
    :  # gnu-netcat is not installed
fi
if sudo pacman -Q iptables-nft >/dev/null 2>&1; then
    sudo pacman -Rdd --noconfirm iptables-nft  # gnu-netcat is installed
else
    :  # iptables-nft is not installed
fi
#sudo rm -rf /usr/bin/iptables-nft /usr/bin/iptables-nft-restore /usr/bin/iptables-nft-restore@ /usr/bin/iptables-nft-save /usr/bin/iptables-nft-save@ /usr/bin/iptables /usr/bin/iptables-legacy /usr/bin/iptables-legacy-save /usr/bin/iptables-legacy-restore /usr/bin/iptables-restore /usr/bin/iptables-save /usr/bin/iptables-xml /usr/bin/iptables-translate /usr/bin/iptables-restore-translate /usr/share/iptables /etc/iptables
#sudo rm -f /usr/bin/iptables-apply
#Removing the cancerous iptables-nft package that wont go away and just f*cks up the entire QEMU installation
sudo sh $HOME/github/bw-dwm/archcraft-dwm/shared/bin/iptables-removal.sh
sleep 3
echo "




!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!      When it asks whether or not     !!!!
!!!!        to remove the ip tables       !!!!
!!!!             select (Y)es             !!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
"
sudo pacman -Syy archlinux-keyring qemu virt-manager virt-viewer dnsmasq vde2 bridge-utils openbsd-netcat ebtables iptables libguestfs

sudo systemctl enable libvirtd.service
sudo systemctl start libvirtd.service

# check proper install in : /etc/libvirt/libvirtd.conf
# line 85 : unix_sock_group = "libvirt"
# line 108 : unix_sock_rw_perms = "0770"
sudo groupadd libvirt
newgrp libvirt
sudo usermod -aG libvirt $(whoami)

# nested virtualization

read -p "Whatkind of CPU do you have (I)ntel or (A)md: " cpuchoice

if [ "$cpuchoice" == "Intel" ] || [ "$cpuchoice" == "i" ]; then
    ### Intel Processor ###
    sudo modprobe -r kvm_intel
    sudo modprobe kvm_intel nested=1
    echo "options kvm-intel nested=1" | sudo tee /etc/modprobe.d/kvm-intel.conf
    systool -m kvm_intel -v | grep nested
elif [ "$cpuchoice" == "Amd" ] || [ "$cpuchoice" == "a" ]; then
    ### AMD Processor ###
    sudo modprobe -r kvm_amd
    sudo modprobe kvm_amd nested=1
    echo "options kvm-amd nested=1" | sudo tee /etc/modprobe.d/kvm-amd.conf
    systool -m kvm_amd -v | grep nested
else
    # Wrong input moron
    echo "Invalid choice. Please enter 'I' or 'A'."
fi



: '
### Intel Processor ###
sudo modprobe -r kvm_intel
sudo modprobe kvm_intel nested=1
echo "options kvm-intel nested=1" | sudo tee /etc/modprobe.d/kvm-intel.conf
systool -m kvm_intel -v | grep nested

### AMD Processor ###
sudo modprobe -r kvm_amd
sudo modprobe kvm_amd nested=1
echo "options kvm-amd nested=1" | sudo tee /etc/modprobe.d/kvm-amd.conf
systool -m kvm_amd -v | grep nested
'



# Fixing RC files
git clone https://github.com/Emil8630/rc-files.git
cd rc-files
cat .bashrc_input >> /home/$(whoami)/.bashrc && cat .zshrc_input >> /home/$(whoami)/.zshrc
sudo cp .config/alacritty/alcritty.yml ~/.config/alacritty/alacritty.yml
cd .. && sudo mv -f rc-files $HOME/github/


# Install Neovim Configurations
git clone https://github.com/Emil8630/nvim.git
mkdir $HOME/.config/nvim
mv nvim /home/$(whoami)/.config/nvim

# Downloading Wallpapers
git clone https://github.com/Emil8630/wallpapers ~/wallpapers

# Installing Picom
git clone https://github.com/jonaburg/picom.git && cd picom && meson --buildtype=release . build && ninja -C build && ninja -C build install && cd .. && find picom -type f -exec shred -n 5 -fzu {} \; -exec rm -r {} +

## Installing GRUB Theme
#Fallout Theme
wget -O - https://github.com/shvchk/fallout-grub-theme/raw/master/install.sh | bash

# flatpaks
flatpak install flathub md.obsidian.Obsidian

# Installing AUR packages
# They're seperated because errors lead to 
# the entire command failing and not just skipping 
# the missing package so splitting it up is for redundancy
yay -Sy mullvad-vpn
yay -S picom-jonaburg-git
yay -S mullvad-browser
yay -S librewolf
yay -S vscodium-bin
yay -S freetube-bin
yay -S brave-bin
yay -S rofi-calc
yay -S github-desktop
yay -S icecat
yay -S cbonsai
yay -S pfetch
yay -S tty-clock




clear && echo "Installation is done!
All obsolete files and folders have been cleaned up.
Your system will restart within 20 minutes to secure that all files have been properly written and the drive is safe to be unmounted without causing data loss.

Note: Using ^C at this stage may cause data loss although unlikely better be safe than sorry right." && sleep 1200 && reboot
