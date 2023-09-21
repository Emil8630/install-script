#!/bin/sh

#-------------------------
# Need to be ran with sudo
#--Required Packages-
#-ufw
#-fail2ban

kernel_version=$(uname -r)
usr=$1

if [ "$kernel_version" = *"arch"* ]; then
    pacman -S --noconfirm ufw fail2ban netstat
else
    apt install -y ufw fail2ban
fi

# --- Setup UFW rules
ufw limit 22/tcp  
ufw allow 80/tcp  
ufw allow 443/tcp  
ufw default deny incoming  
ufw default allow outgoing
ufw enable

# --- Harden /etc/sysctl.conf
sysctl kernel.modules_disabled=1
sysctl -a
sysctl -A
sysctl mib
sysctl net.ipv4.conf.all.rp_filter
sysctl -a --pattern 'net.ipv4.conf.(eth|wlan)0.arp'

# --- PREVENT IP SPOOFS
cat <<EOF > /etc/host.conf
order bind,hosts
multi on
EOF

# --- Enable fail2ban
cp /home/$usr/github/suckless/jail.local /etc/fail2ban/
ln -s /etc/runit/sv/fail2ban /etc/service/
sv start fail2ban

echo "listening ports"
netstat -tunlp

