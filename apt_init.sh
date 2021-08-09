if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "This script must be run as root"
    exit
fi
apt update
apt upgrade -y
apt install apache2 php libapache2-mod-php ufw fail2ban neovim git -y
