#!/bin/bash


# black arch mirrors
curl -O https://blackarch.org/strap.sh
chmod +x strap.sh
sudo ./strap.sh
sudo rm -rf strap.sh
sudo pacman -Syu --noconfirm 

# packages
sudo pacman -Syu --noconfirm xclip discord flatpak caja flameshot python3 python-pip git feh arandr acpi breeze nodejs npm yarn lxappearance materia-gtk-theme xonsh eom net-tools nim mesa mpv keepassxc alacritty dnscrypt-proxy curl thunar qbittorrent ranger libx11 libx11-xcb libXext xproto pixman libdbus libconfig libev uthash libxinerama libxft freetype2 hsetroot geany rofi polybar dunst mpd mpc maim xclip viewnior feh xfce4-power-manager xorg-xsetroot wmname ninja pulsemixer light xcolor zsh fish xrandr xfce4-settings zsh hsetroot flatpak wget meson

# Enabling dnscrypt
#sudo systemctl enable --now dnscrypt-proxy.socket

# Getting NixOS package manager & packages
sudo sh <(curl -L https://nixos.org/nix/install) --daemon
sudo nix-env -iA nixpkgs.exa
sudo nix-env -iA nixpkgs.bat

# Installing DWM
git clone https://github.com/Emil8630/bw-dwm.git
sudo chown -R $(whoami) bw-dwm && cd bw-dwm && sh build.sh

# virtual machines with "qemu" and "virtual machine manger"
sudo pacman -Syy --noconfirm 
sudo pacman -S --noconfirm  archlinux-keyring qemu virt-manager virt-viewer dnsmasq vde2 bridge-utils openbsd-netcat ebtables iptables libguestfs

sudo systemctl enable libvirtd.service
sudo systemctl start libvirtd.service

# check proper install in : /etc/libvirt/libvirtd.conf
# line 85 : unix_sock_group = "libvirt"
# line 108 : unix_sock_rw_perms = "0770"
sudo usermod -a -G libvirt $(whoami)
newgrp libvirt

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
