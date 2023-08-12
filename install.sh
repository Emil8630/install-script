#!/bin/bash

# Backup the original pacman.conf file
sudo cp /etc/pacman.conf /etc/pacman.conf.backup

# Enable the multilib repository by uncommenting the lines
sudo sed -i '/\[multilib\]/,+1 s/^#//' /etc/pacman.conf

# black arch mirrors
curl -O https://blackarch.org/strap.sh
chmod +x strap.sh
sudo ./strap.sh
sudo rm -rf strap.sh
sudo pacman -Syu --noconfirm 

sudo hostnamectl set-hostname "arch"

# packages
sudo pacman -Syu --noconfirm xclip discord flatpak caja flameshot python3 python-pip git feh arandr acpi breeze nodejs npm yarn lxappearance materia-gtk-theme xonsh eom net-tools nim mesa mpv keepassxc alacritty dnscrypt-proxy curl thunar qbittorrent ranger libx11 pixman libdbus libconfig libev uthash libxinerama libxft freetype2 hsetroot geany rofi polybar dunst mpd mpc maim xclip viewnior feh xfce4-power-manager xorg-xsetroot wmname ninja pulsemixer light xcolor zsh fish xfce4-settings zsh hsetroot flatpak wget meson curl cmake

# Enabling dnscrypt
#sudo systemctl enable --now dnscrypt-proxy.socket

# Getting NixOS package manager & packages
sudo sh <(curl -L https://nixos.org/nix/install) --daemon
sudo nix-env -iA nixpkgs.exa
sudo nix-env -iA nixpkgs.bat

# Installing DWM
git clone https://github.com/Emil8630/bw-dwm.git ~/bw-dwm
sudo chown -R $(whoami) bw-dwm && cd ~/bw-dwm && cd ~/bw-dwm/archcraft-dwm/source && sudo make clean install && cd ~/bw-dwm/archcraft-dwm/ && makepkg -if --cleanbuild

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
sudo pacman -R --noconfirm iptables-nft
sudo rm -rf /usr/bin/iptables-nft /usr/bin/iptables-nft-restore /usr/bin/iptables-nft-restore@ /usr/bin/iptables-nft-save /usr/bin/iptables-nft-save@
sudo pacman -Syy --noconfirm  archlinux-keyring qemu virt-manager virt-viewer dnsmasq vde2 bridge-utils openbsd-netcat ebtables iptables libguestfs

sudo systemctl enable libvirtd.service
sudo systemctl start libvirtd.service

# check proper install in : /etc/libvirt/libvirtd.conf
# line 85 : unix_sock_group = "libvirt"
# line 108 : unix_sock_rw_perms = "0770"
sudo groupadd libvirt
newgrp libvirt
sudo usermod -a -G libvirt $(whoami)

# nested virtualization

### Intel Processor ###
sudo modprobe -r kvm_intel
sudo modprobe kvm_intel nested=1
echo "options kvm-intel nested=1" | sudo tee /etc/modprobe.d/kvm-intel.conf
systool -m kvm_intel -v | grep nested

### AMD Processor ###
#sudo modprobe -r kvm_amd
#sudo modprobe kvm_amd nested=1
#echo "options kvm-amd nested=1" | sudo tee /etc/modprobe.d/kvm-amd.conf
#systool -m kvm_amd -v | grep nested

# Fixing RC files
git clone https://github.com/Emil8630/rc-files.git
cd rc-files
cat .bashrc_input >> /home/$(whoami)/.bashrc && cat .zshrc_input >> /home/$(whoami)/.zshrc
cd .. && sudo rm -r rc-files

# Install Neovim Configurations
git clone https://github.com/Emil8630/nvim.git
mv nvim /home/$(whoami)/.config/nvim

# Installing Picom
git clone https://github.com/jonaburg/picom.git && cd picom && meson --buildtype=release . build && ninja -C build && ninja -C build install && cd .. && sudo rm -r picom

## Installing GRUB Theme
#Fallout Theme
wget -O - https://github.com/shvchk/fallout-grub-theme/raw/master/install.sh | bash

# flatpaks
flatpak install flathub md.obsidian.Obsidian

# Installing AUR packages
yay -Sy mullvad-vpn mullvad-browser librewolf vscodium-bin freetube-bin
yay -Sy picom-jonaburg-git

clear && echo "Installation is done!" && sleep 1200 && reboot
