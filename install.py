import os

# I know this is shitty  just needed something that works...


# Checks if script is running as root
if os.geteuid() != 0:
        input("Make sure to run this in a root shell.")
else:
    # Pacman Packages
    os.system("pacman -Sy git flameshot mpv neovim keepassxc alacritty dnscrypt-proxy curl thunar qbittorrent discord cava tty-clock ranger libx11 libx11-xcb libXext xproto xcb xcb-damage xcb-xfixes xcb-shape xcb-renderutil xcb-render xcb-randr xcb-composite xcb-image xcb-åresent xcb-xinerama xcb-glx pixman libdbus libconfig libGL libpcre libev uthash libxinerama libxft freetype2 hsetroot geany rofi polybar dunst mpd mpc maim xclip viewnior feh ksuperkey betterlockscreen xfce4-power-manager xorg-xsetroot wmname ninja pulsemixer light xcolor zsh fish")
    # Enabling dnscrypt
    os.system("systemctl enable --now dnscrypt-proxy.socket")
    # Installing Picom
    os.system("git clone https://github.com/pijulius/picom && cd picom && git submodule update --init --recursive && meson --buildtype=release . build && ninja -C build && ninja -C build install && cd .. && rm -r picom")
    # Getting blackarch repo
    os.system("curl -Os https://blackarch.org/strap.sh")
    os.system("chmod +x strap.sh")
    os.system("sh strap.sh")
    # Install blackarch packages
    os.system("pacman -Sy blackarch")
    # Installing AUR packages
    os.system("yay -S mullvad-vpn mullvad-browser librewolf vscodium-bin freetube-bin")
    # Getting NixOS package manager & packages
    os.system("sh <(curl -L https://nixos.org/nix/install) --daemon")
    os.system("nix-env -iA nixpkgs.exa")
    os.system("nix-env -iA nixpkgs.bat")
    # Fixing RC files
    os.system("git clone https://github.com/Emil8630/rc-files.git")
    os.system("cd rc-files")
    os.system("cat .bashrc_input >> /home/less/.bashrc && cat .zshrc_input >> /home/less/.zshrc")
    os.system("cd .. && rm -r rc-files")
    os.system("source /home/less/.zshrc && source /home/less/.bashrc")
    # Install Neovim Configurations
    os.system("git clone https://github.com/Emil8630/nvim.git")
    os.system("mv nvim /home/less/.config/nvim")
    # Installing KVM
    os.system("pacman -Syu qemu libvirt virt-manager qemu-arch-extra dnsmasq bridge-utils")
    os.system("systemctl enable libvirtd")
    os.system("gpasswd -a less libvirt")
    os.system("gpasswd -a less kvm")
    # Installing WM
    wm = input("What WM would you like to install?\nAvailable Options Are: DWM\n")
    if wm == "dwm" or "DWM":
        os.system("git clone https://github.com/Emil8630/bw-dwm.git")
        os.system("cd bw-dwm && chmod +x build.sh && sh build.sh")
        input("You're Done! press any key to reboot.")
        os.system("reboot")
    else:
        input("Invalid WM, press any key to close.")
        os.system("exit")
