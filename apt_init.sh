if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "This script must be run as root"
    exit
fi
PHP_Version="8.0"
apt update
apt upgrade -y
apt install apache2 ufw fail2ban neovim git libapache2-mod-php$PHP_Version php$PHP_Version-apcu php$PHP_Version-mysql php$PHP_Version-xml php$PHP_Version-zip php$PHP_Version-mbstring php$PHP_Version-gd php$PHP_Version-curl php$PHP_Version-redis php$PHP_Version-intl php$PHP_Version-bcmath php$PHP_Version-gmp php$PHP_Version-imagick imagemagick php$PHP_Version-fpm -y
reboot
