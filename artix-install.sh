#!/bin/bash

usr=$(whoami)

# Prompt the user for their city
read -p "Enter your city for weather information: " location

# Additional packages prompt
read -p "Do you want to install additional packages? (y/N): " install_additional
if [ "$install_additional" == "y" ] || [ "$install_additional" == "Y" ]; then
    read -p "Enter additional packages to install (space-separated): " additional_packages
    for package in $additional_packages; do
        sudo pacman -Syu --noconfirm "$package"
    done
fi

# Wipe .zshrc and .bashrc
echo "#" > ~/.bashrc
echo "#" > ~/.zshrc

# Add the export line to ~/.zshrc
echo "export WEATHER_LOCATION=\"$location\"" >> ~/.zshrc

# Add the export line to ~/.bashrc
echo "export WEATHER_LOCATION=\"$location\"" >> ~/.bashrc

# Backup the original pacman.conf file
sudo cp /etc/pacman.conf /etc/pacman.conf.backup

# Get Arch repository on artix
sudo pacman -Sy --noconfirm base-devel cmake gcc git artix-archlinux-support go
sudo pacman-key --populate archlinux
sudo sed -i '/\[lib32\]/,+1 s/^#//' /etc/pacman.conf
echo -e "\n# Arch\n[extra]\nInclude = /etc/pacman.d/mirrorlist-arch\n\n[community]\nInclude = /etc/pacman.d/mirrorlist-arch\n\n[multilib]\nInclude = /etc/pacman.d/mirrorlist-arch" | sudo tee -a /etc/pacman.conf

# Install yay
git clone https://aur.archlinux.org/yay.git ~/yay && cd ~/yay
makepkg -si
cd .. 

# Installing black arch mirrors and pentesting tools
curl -O https://blackarch.org/strap.sh
chmod +x strap.sh
sudo ./strap.sh
sudo shred -fzu strap.sh
sudo pacman -Syyu --noconfirm 
sudo pacman -S --noconfirm nmap gobuster wireshark-qt burpsuite metasploit aircrack-ng sqlmap ettercap john oclhashcat wifite beef

# Changing Hostname
sudo hostnamectl set-hostname "artix"

# Add cronjobs
usr_home="/home/$usr"
echo "*/10 * * * * /usr/bin/newsboat -x reload" | crontab -
echo "*/2 * * * * /usr/local/bin/mailsync > ~/mailsync_dump 2>&1" | crontab -
echo "*/360 * * * * /bin/bash /home/less/github/suckless/dellogs.sh" | crontab -

# Hardening network settings
#sudo sh /home/$usr/github/bw-dwm/archcraft-dwm/shared/bin/hardening.sh
sudo sh $(pwd)/artix-hardening.sh $usr

# packages

packages_to_install=(
    "xclip"
    "xdg-utils"
    "macchanger"
    "discord"
    "caja"
    "flameshot"
    "python3"
    "python-pip"
    "feh"
    "arandr"
    "acpi"
    "breeze"
    "nodejs"
    "npm"
    "yarn"
    "lxappearance"
    "materia-gtk-theme"
    "xonsh"
    "eom"
    "net-tools"
    "nim"
    "mesa"
    "mpv"
    "keepassxc"
    "alacritty"
    "curl"
    "thunar"
    "qbittorrent"
    "ranger"
    "lf"
    "libx11"
    "pixman"
    "libdbus"
    "libconfig"
    "libev"
    "uthash"
    "libxinerama"
    "libxft"
    "freetype2"
    "rofi"
    "polybar"
    "dunst"
    "mpd"
    "mpc"
    "xclip"
    "feh"
    "xorg-xsetroot"
    "wmname"
    "ninja"
    "pulsemixer"
    "light"
    "xcolor"
    "fish"
    "xfce4-settings"
    "zsh"
    "hsetroot"
    "flatpak"
    "wget"
    "meson"
    "curl"
    "neovim"
    "exa"
    "bat"
    "variety"
    "adobe-source-code-pro-fonts"
    "lib32-fontconfig"
    "noto-fonts-emoji"
    "ttf-firacode-nerd"
    "ufw"
    "opendoas"
    "translate-shell"
    "lynx"
    "notmuch"
    "abook"
    "mpop"
    "urlview"
    "pass"
    "msmtp"
    "isync"
    "curl"
    "neomutt"
    "obsidian"
)

for package in "${packages_to_install[@]}"; do
    sudo pacman -S --noconfirm "$package"
done

# Detect network interfaces
interfaces=$(ip link | awk -F: '$0 !~ "lo|vir|wl|^[^0-9]"{print $2;getline}')

# Configure macchanger for each interface
for interface in $interfaces; do
    sudo macchanger -r $interface
done

echo "Mac addresses changed for all network interfaces."


# Install mutt-wizard
git clone https://github.com/lukesmithxyz/mutt-wizard ~/mutt-wizard
cd ~/mutt-wizard
sudo make install && cd ~

# Installs doas
sudo touch /etc/doas.conf 
sudo sh -c 'echo "permit persist $(logname) as root" > /etc/doas.conf'
echo "alias sudo='doas'" >> .zshrc
echo "alias sudo='doas'" >> .bashrc

# Take a break
sleep 5

# Installing DWM
git clone https://github.com/emil8630/suckless.git ~/github/suckless
sudo chown -R $(whoami) ~/github/suckless && cd ~/github/suckless && sh build.sh

# Adds DWM to lightDM which is the standard display manager on artix
echo -e "[Desktop Entry]\nEncoding=UTF-8\nName=dwm\nComment=Dynamic window manager\nExec=dwm\nIcon=dwm\nType=XSession" | sudo tee /usr/share/xsessions/dwm.desktop > /dev/null
sudo chmod 644 /usr/share/xsessions/dwm.desktop

# Make the autostart.sh start on boot
sudo mkdir -p /etc/sv/autostart 
echo '#!/bin/sh' | sudo tee /etc/sv/autostart/run > /dev/null 
echo 'exec /home/$(whoami)/github/suckless/autostart.sh' | sudo tee -a /etc/sv/autostart/run > /dev/null
sudo chmod +x /etc/sv/autostart/run 
sudo ln -s /etc/sv/autostart /var/service/ 
sudo sv start autostart 
sudo ln -s /etc/sv/autostart /etc/runit/runsvdir/default/

# Changes power.sh to work with runit
# Define the path to the power.sh file
power_script_path="~/github/suckless/power.sh"

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
sudo sh $HOME/github/suckless/iptables-removal.sh
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
:'
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
'

# Detect CPU brand
if lscpu | grep -qi "Intel"; then
    cpuchoice="Intel"
elif lscpu | grep -qi "AMD"; then
    cpuchoice="Amd"
else
    echo "CPU brand not recognized."
    exit 1
fi

# Configure CPU based on brand
if [ "$cpuchoice" == "Intel" ]; then
    ### Intel Processor ###
    sudo modprobe -r kvm_intel
    sudo modprobe kvm_intel nested=1
    echo "options kvm-intel nested=1" | sudo tee /etc/modprobe.d/kvm-intel.conf
    systool -m kvm_intel -v | grep nested
elif [ "$cpuchoice" == "Amd" ]; then
    ### AMD Processor ###
    sudo modprobe -r kvm_amd
    sudo modprobe kvm_amd nested=1
    echo "options kvm-amd nested=1" | sudo tee /etc/modprobe.d/kvm-amd.conf
    systool -m kvm_amd -v | grep nested
else
    # CPU brand not recognized
    echo "CPU brand not recognized."
    exit 1
fi

# Fixing RC files
git clone https://github.com/Emil8630/rc-files.git ~/github/rc-files
cd rc-files
cat .bashrc_input >> /home/$(whoami)/.bashrc && cat .zshrc_input >> /home/$(whoami)/.zshrc
sudo cp .config/alacritty/alacritty.yml ~/.config/alacritty/alacritty.yml 
cd ..

# Install Neovim Configurations
sudo rm -rf $HOME/.config/nvim
git clone https://github.com/Emil8630/nvim.git ~/.config/nvim

# Downloading Wallpapers
git clone https://github.com/Emil8630/wallpapers ~/wallpapers

# Installing Picom
git clone https://github.com/jonaburg/picom.git ~/picom && cd ~/picom && meson --buildtype=release . build && ninja -C build && ninja -C build install && cd .. && find picom -type f -exec shred -n 5 -fzu {} \; -exec rm -r {} +

# Swap default browser
DESKTOP_FILE_CONTENT="[Desktop Entry]
Version=1.0
Name=Mullvad Browser
Comment=Browse the web securely with Mullvad
Exec=/usr/bin/mullvad-browser %u
Icon=mullvad-browser
Terminal=false
Type=Application
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;application/x-xhtml+xml;application/xml;application/pdf;application/x-web-app-manifest+json;"
DESKTOP_FILE_PATH="$HOME/.local/share/applications/mullvad-browser.desktop"
echo "$DESKTOP_FILE_CONTENT" > "$DESKTOP_FILE_PATH"
chmod +x "$DESKTOP_FILE_PATH"
xdg-settings set default-web-browser mullvad-browser.desktop

# Cleanup
source ~/.bashrc
source ~/.zshrc
rmr ~/yay
rmr ~/picom
rmr ~/mutt-wizard
sudo pacman -Rnnd epiphany
sudo find / -type d -iname "Epiphany" -exec rm -rf {} \;


## Installing GRUB Theme
#Fallout Theme
wget -O - https://github.com/shvchk/fallout-grub-theme/raw/master/install.sh | bash

# flatpaks
#flatpak install flathub md.obsidian.Obsidian
flatpak install flathub com.github.iwalton3.jellyfin-media-player

# Installing AUR packages

yay_packages_to_install=(
    "mullvad-vpn-bin"
    "mullvad-browser-bin"
    "librewolf-bin"
    "vscodium-bin"
    "freetube-bin"
    "thorium-browser-bin"
    "github-desktop-bin"
    "pfetch"
    "tty-clock"
    "didyoumean"
    "pyradio"
    "musikcube-bin"
#    "icecat"
#    "picom-jonaburg-git"
)

# Install AUR packages using yay
for package in "${yay_packages_to_install[@]}"; do
    yay -S --noconfirm "$package"
done

whiptail --title "Done!" --msgbox "Your install is now complete!" 10 33
loginctl reboot
