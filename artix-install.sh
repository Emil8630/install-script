#!/bin/bash

usr=$(whoami)

# Backup the original pacman.conf file
sudo cp /etc/pacman.conf /etc/pacman.conf.backup

# Get Arch repository on artix
sudo pacman -Sy --noconfirm base-devel cmake gcc git artix-archlinux-support
sudo pacman-key --populate archlinux
sudo sed -i '/\[lib32\]/,+1 s/^#//' /etc/pacman.conf
echo -e "\n# Arch\n[extra]\nInclude = /etc/pacman.d/mirrorlist-arch\n\n[community]\nInclude = /etc/pacman.d/mirrorlist-arch\n\n[multilib]\nInclude = /etc/pacman.d/mirrorlist-arch" | sudo tee -a /etc/pacman.conf

# Install yay
git clone https://aur.archlinux.org/yay.git && cd yay
makepkg -si
cd .. && sudo rm -rf yay

# black arch mirrors
curl -O https://blackarch.org/strap.sh
chmod +x strap.sh
sudo ./strap.sh
sudo shred -fzu strap.sh
sudo pacman -Syu --noconfirm 

#Changing Hostname
sudo hostnamectl set-hostname "artix"

# Hardening network settings
#sudo sh /home/$usr/github/bw-dwm/archcraft-dwm/shared/bin/hardening.sh
sudo sh $(pwd)/hardening.sh

# packages
# Installed seperately incase of removal from repos or else all installs will fail.
sudo pacman -S --noconfirm xclip
sudo pacman -S --noconfirm discord
sudo pacman -S --noconfirm flatpak
sudo pacman -S --noconfirm caja
sudo pacman -S --noconfirm flameshot
sudo pacman -S --noconfirm python3
sudo pacman -S --noconfirm python-pip
sudo pacman -S --noconfirm feh
sudo pacman -S --noconfirm arandr
sudo pacman -S --noconfirm acpi
sudo pacman -S --noconfirm breeze
sudo pacman -S --noconfirm nodejs
sudo pacman -S --noconfirm npm
sudo pacman -S --noconfirm yarn
sudo pacman -S --noconfirm lxappearance
sudo pacman -S --noconfirm materia-gtk-theme
sudo pacman -S --noconfirm xonsh
sudo pacman -S --noconfirm eom
sudo pacman -S --noconfirm net-tools
sudo pacman -S --noconfirm nim
sudo pacman -S --noconfirm mesa
sudo pacman -S --noconfirm mpv
sudo pacman -S --noconfirm keepassxc
sudo pacman -S --noconfirm alacritty
sudo pacman -S --noconfirm curl
sudo pacman -S --noconfirm thunar
sudo pacman -S --noconfirm qbittorrent
sudo pacman -S --noconfirm ranger
sudo pacman -S --noconfirm lf
sudo pacman -S --noconfirm libx11
sudo pacman -S --noconfirm pixman
sudo pacman -S --noconfirm libdbus
sudo pacman -S --noconfirm libconfig
sudo pacman -S --noconfirm libev
sudo pacman -S --noconfirm uthash
sudo pacman -S --noconfirm libxinerama
sudo pacman -S --noconfirm libxft
sudo pacman -S --noconfirm freetype2
sudo pacman -S --noconfirm rofi
sudo pacman -S --noconfirm polybar
sudo pacman -S --noconfirm dunst
sudo pacman -S --noconfirm mpd
sudo pacman -S --noconfirm mpc
sudo pacman -S --noconfirm maim
sudo pacman -S --noconfirm xclip
sudo pacman -S --noconfirm viewnior
sudo pacman -S --noconfirm feh
sudo pacman -S --noconfirm xorg-xsetroot
sudo pacman -S --noconfirm wmname
sudo pacman -S --noconfirm ninja
sudo pacman -S --noconfirm pulsemixer
sudo pacman -S --noconfirm light
sudo pacman -S --noconfirm xcolor
sudo pacman -S --noconfirm fish
sudo pacman -S --noconfirm xfce4-settings
sudo pacman -S --noconfirm zsh
sudo pacman -S --noconfirm hsetroot
sudo pacman -S --noconfirm flatpak
sudo pacman -S --noconfirm wget
sudo pacman -S --noconfirm meson
sudo pacman -S --noconfirm curl
sudo pacman -S --noconfirm neovim
sudo pacman -S --noconfirm exa
sudo pacman -S --noconfirm bat
sudo pacman -S --noconfirm variety
sudo pacman -S --noconfirm adobe-source-code-pro-fonts
sudo pacman -S --noconfirm lib32-fontconfig
sudo pacman -S --noconfirm noto-fonts-emoji
sudo pacman -S --noconfirm ttf-firacode-nerd
sudo pacman -S --noconfirm ufw
sudo pacman -S --noconfirm opendoas
sudo pacman -S --noconfirm translate-shell


# Installs doas
sudo touch /etc/doas.conf 
sudo echo "permit persist $(whoami) as root" > /etc/doas.conf
echo "alias sudo='doas'" >> .zshrc
echo "alias sudo='doas'" >> .bashrc

# Installing DWM
sleep 5
        git clone https://github.com/emil8630/suckless.git ~/github/suckless
        sudo chown -R $(whoami) ~/github/suckless && cd ~/github/suckless && sh build.sh

#Changes power.sh to work with runit
# Define the path to the power.sh file
power_script_path=~/github/suckless/power.sh

# Check if the power.sh file exists
if [ -f "$power_script_path" ]; then
    # Replace the contents of power.sh with the provided script
    cat <<EOL > "$power_script_path"
#!/bin/bash

options=("🔴 Shutdown" "🔄 Reboot" "🔒 Lock" "👤 Logout")
selected_option=\$(printf '%s\\n' "\${options[@]}" | dmenu -i -p "Power Menu:")

case "\$selected_option" in
    "🔴 Shutdown")
        loginctl poweroff
        ;;
    "🔄 Reboot")
        loginctl reboot
        ;;
    "👤 Logout")
        pkill -u "\$USER"
        ;;
    "🔒 Lock")
        slock -m "The screen is locked"
        #betterlockscreen -q -l 
        ;;
    *)
        echo "Invalid option"
        ;;
esac
EOL

    echo "power.sh has been updated."
else
    echo "power.sh does not exist in ~/github/suckless."
fi

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
#sudo sh $HOME/github/bw-dwm/archcraft-dwm/shared/bin/iptables-removal.sh
sudo sh $HOME/github/suckless/dwm/iptables-removal.sh
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

#Enabling service
# Create the libvirtd service directory
sudo mkdir -p /etc/sv/libvirtd

# Create the run script for libvirtd
cat <<EOL > /etc/sv/libvirtd/run
#!/bin/sh
exec /usr/bin/libvirtd
EOL

# Make the run script executable
sudo chmod +x /etc/sv/libvirtd/run

# Create a symbolic link to enable the service
sudo ln -s /etc/sv/libvirtd /run/runit/service/

# Start the libvirtd service
sudo sv start libvirtd

# Optional: Enable automatic startup
sudo ln -s /etc/sv/libvirtd /etc/runit/runsvdir/default/

# check proper install in : /etc/libvirt/libvirtd.conf
# line 85 : unix_sock_group = "libvirt"
# line 108 : unix_sock_rw_perms = "0770"
sudo groupadd libvirt
newgrp libvirt
sudo usermod -aG libvirt $(whoami)

# nested virtualization

read -p "Whatkind of CPU do you have (I)ntel or (A)md: " cpuchoice

if [ "$cpuchoice" == "Intel" ] || [ "$cpuchoice" == "i" ] || [ "$cpuchoice" == "I" ]; then
    ### Intel Processor ###
    sudo modprobe -r kvm_intel
    sudo modprobe kvm_intel nested=1
    echo "options kvm-intel nested=1" | sudo tee /etc/modprobe.d/kvm-intel.conf
    systool -m kvm_intel -v | grep nested
elif [ "$cpuchoice" == "Amd" ] || [ "$cpuchoice" == "a" ] || [ "$cpuchoice" == "A" ]; then
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
sudo cp .config/alacritty/alacritty.yml ~/.config/alacritty/alacritty.yml
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
yay -S didyoumean

whiptail --title "Done!" --msgbox "Your install is now complete!" 10 33
sudo reboot
