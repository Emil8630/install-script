#!/bin/bash
#-----------------------
#--Required Packages-
#-ufw
#-fail2ban

kernel_version=$(uname -r)
usr=$(whoami)

if [[ $kernel_version == *"arch"* ]]; then
    sudo pacman -S --noconfirm ufw fail2ban netstat
else
    sudo apt install -y ufw fail2ban
fi


# --- Setup UFW rules
sudo ufw limit 22/tcp  
sudo ufw allow 80/tcp  
sudo ufw allow 443/tcp  
sudo ufw default deny incoming  
sudo ufw default allow outgoing
sudo ufw enable

# --- Harden /etc/sysctl.conf
sudo sysctl kernel.modules_disabled=1
sudo sysctl -a
sudo sysctl -A
sudo sysctl mib
sudo sysctl net.ipv4.conf.all.rp_filter
sudo sysctl -a --pattern 'net.ipv4.conf.(eth|wlan)0.arp'

# --- PREVENT IP SPOOFS
cat <<EOF > /etc/host.conf
order bind,hosts
multi on
EOF

# --- Enable fail2ban
sudo -U $usr cp $HOME/github/suckless/jail.local /etc/fail2ban/
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

echo "listening ports"
sudo netstat -tunlp
