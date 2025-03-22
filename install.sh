#!/bin/bash

usr=$(whoami)
usr_home="/home/$usr"

# Initializing the keyring
sudo pacman -Sy --needed --noconfirm archlinux-keyring && pacman -Su --noconfirm
pacman-key --init
pacman-key --populate
clear

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

# Input for option to detect other OS in GRUB
read -p "Are you dual-booting this install? (y/N): " dualboot

# Wipe .zshrc and .bashrc
echo "#" > ~/.bashrc
echo "#" > ~/.zshrc

# Add the export line to ~/.zshrc
#echo "export WEATHER_LOCATION=\"$location\"" >> ~/.zshrc

# Add the export line to ~/.bashrc
#echo "export WEATHER_LOCATION=\"$location\"" >> ~/.bashrc

# Backup the original pacman.conf file
sudo cp /etc/pacman.conf /etc/pacman.conf.backup

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
sudo hostnamectl set-hostname "arch"

# Add cronjobs

#echo "*/10 * * * * /usr/bin/newsboat -x reload" | crontab -
#echo "*/10 * * * * /usr/bin/stow ~/dotfiles" | crontab -
#echo "*/2 * * * * /usr/local/bin/mailsync > ~/mailsync_dump 2>&1" | crontab -
#echo "*/360 * * * * /bin/bash /home/less/github/suckless/dellogs.sh" | crontab -

# Define the new cron jobs
CRON_JOB1="*/360 * * * * /bin/bash /home/less/github/suckless/dellogs.sh"
CRON_JOB2="*/10 * * * * /usr/bin/newsboat -x reload"
CRON_JOB3="*/10 * * * * /usr/bin/stow ~/github/dotfiles"

# Check if the cron jobs already exist to avoid duplicates
if ! crontab -l | grep -q "$CRON_JOB1"; then
    (crontab -l; echo "$CRON_JOB1") | crontab -
    echo "Added cron job: $CRON_JOB1"
else
    echo "Cron job already exists: $CRON_JOB1"
fi

if ! crontab -l | grep -q "$CRON_JOB2"; then
    (crontab -l; echo "$CRON_JOB2") | crontab -
    echo "Added cron job: $CRON_JOB2"
else
    echo "Cron job already exists: $CRON_JOB2"
for ((i = 0; i < 10; i++)); do
  echo "$i"
done
if ! crontab -l | grep -q "$CRON_JOB3"; then
    (crontab -l; echo "$CRON_JOB3") | crontab -
    echo "Added cron job: $CRON_JOB3"
else
    echo "Cron job already exists: $CRON_JOB3"
fi


# packages

packages_to_install=(
  	"base-devel"
  	"cmake"
	  "gcc"
  	"git"
	  "go"
    "xclip"
    "macchanger"
    "ufw"
    "netstat-nat"
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
    "xorg-xbacklight"
    "ranger"
    "lf"
    "libx11"
    "dnsutils"
    "pixman"
    "libdbus"
    "libconfig"
    "libev"
    "uthash"
    "libxinerama"
    "libxft"
    "freetype2"
    "qt5-graphicaleffects"
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
    "stow"
    "neovim"
    "exa"
    "bat"
    "variety"
    "adobe-source-code-pro-fonts"
    "lib32-fontconfig"
    "noto-fonts-emoji"
    "ttf-firacode-nerd"
    "ttf-jetbrains-mono-nerd"
    "ufw"
    "xdotool"
    "opendoas"
    "translate-shell"
    "lynx"
    "cron"
    "notmuch"
    "abook"
    "mpop"
    "urlview"
    "pass"
    "tealdeer"
    "msmtp"
    "isync"
    "curl"
    "neomutt"
    "obsidian"
    "nextcloud-client"
    "bash-completions"
    "zoxide"
)

for package in "${packages_to_install[@]}"; do
    sudo pacman -S --noconfirm "$package"
done

# Hardening network settings
#sudo sh /home/$usr/github/bw-dwm/archcraft-dwm/shared/bin/hardening.sh
sudo sh $(pwd)/artix-hardening.sh $usr

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

# Adds DWM to xsessions
echo -e "[Desktop Entry]\nEncoding=UTF-8\nName=dwm\nComment=Dynamic window manager\nExec=dwm\nIcon=dwm\nType=XSession" | sudo tee /usr/share/xsessions/dwm.desktop > /dev/null
sudo chmod 644 /usr/share/xsessions/dwm.desktop

# Install sddm theme
git clone https://github.com/RadRussianRus/sddm-slice.git ~/github/sddm-slice/
cp -r sddm-slice /usr/share/sddm/themes/sddm-slice
sudo sed -i 's/^Current=.*/Current=sddm-slice/' /usr/lib/sddm/sddm.conf.d/default.conf

# Make the autostart.sh start on boot
sudo tee /etc/systemd/system/autostart.service > /dev/null << 'EOF'
[Unit]
Description=Autostart service

[Service]
Type=simple
ExecStart=/home/$(whoami)/github/suckless/autostart.sh

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload
sudo systemctl enable autostart
sudo systemctl start autostart

# Take action on dualboot detection
if [ "$dualboot" == "y" ] || [ "$dualboot" == "Y" ]; then
  GRUB_FILE="/etc/default/grub"
  LINE_TO_UNCOMMENT="#GRUB_DISABLE_OS_PROBER=false"
  UNCOMMENTED_LINE="GRUB_DISABLE_OS_PROBER=false"

  if [ ! -f "$GRUB_FILE" ]; then
    echo -e "\e[31mError: $GRUB_FILE does not exist. Skipping step...\e[0m"
  fi

  if grep -q "^$LINE_TO_UNCOMMENT" "$GRUB_FILE"; then
    # Uncomment the line
    sed -i "s/^$LINE_TO_UNCOMMENT/$UNCOMMENTED_LINE/" "$GRUB_FILE"
    echo "Uncommented the line: $UNCOMMENTED_LINE"
  elif ! grep -q "^$UNCOMMENTED_LINE" "$GRUB_FILE"; then
    # Add the line if it doesn't exist
    echo "$UNCOMMENTED_LINE" >> "$GRUB_FILE"
    echo "Added the line: $UNCOMMENTED_LINE"
  else
    ;
  fi
  sudo pacman -Sy --noconfirm os-prober
  sudo grub-mkconfig -o /boot/grub/grub.cfg
fi

# Store weather location
cd ~/github/suckless
echo "$location" > .wl
cd -

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

sudo systemctl enable libvirtd.service
sudo systemctl start libvirtd.service

# check proper install in : /etc/libvirt/libvirtd.conf
# line 85 : unix_sock_group = "libvirt"
# line 108 : unix_sock_rw_perms = "0770"
sudo groupadd libvirt && : || echo "Adding group failed"
sudo newgrp libvirt && : || echo "Switching group failed"
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
mkdir ~/.config/alacritty/ 
sudo cp .config/alacritty/alacritty.yml ~/.config/alacritty/alacritty.yml 
cd ..

# Add bash completions to bashrc file
echo "if [ -f /usr/share/bash-completion/bash_completion ]; then" >> ~/.bashrc
echo "    . /usr/share/bash-completion/bash_completion" >> ~/.bashrc
echo "fi" >> ~/.bashrc

# Add zsh completions to zshrc file
echo "source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" >> ~/.zshrc
echo "source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ~/.zshrc

# Install Neovim Configurations
sudo rm -rf $HOME/.config/nvim
git clone https://github.com/Emil8630/nvim.git ~/.config/nvim

# Downloading Wallpapers
git clone https://github.com/Emil8630/wallpapers ~/github/wallpapers

# Installing Picom
git clone https://github.com/jonaburg/picom.git ~/picom && cd ~/picom && meson --buildtype=release . build && ninja -C build && ninja -C build install && cd .. && find picom -type f -exec shred -n 5 -fzu {} \; -exec rm -r {} +

# Changing default shell
sudo chsh -s /usr/bin/zsh root
chsh -s /usr/bin/zsh $usr

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
rm -rf ~/yay
rm -rf ~/picom
rm -rf ~/mutt-wizard

## Installing GRUB Theme
#Fallout Theme
wget -O - https://github.com/shvchk/fallout-grub-theme/raw/master/install.sh | bash

# flatpaks
#flatpak install flathub md.obsidian.Obsidian
#flatpak install flathub com.github.iwalton3.jellyfin-media-player

# Installing AUR packages

yay_packages_to_install=(
    "mullvad-vpn-bin"
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
#    "mullvad-browser-bin"
)

# Install AUR packages using yay
for package in "${yay_packages_to_install[@]}"; do
    yay -S --noconfirm "$package"
done

whiptail --title "Done!" --msgbox "Your install is now complete!" 10 33
reboot
