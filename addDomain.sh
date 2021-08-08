#!/bin/bash
if [[ $(/usr/bin/id -u) -ne 0 ]]; then
        echo "This script must be run as root"
        exit
fi
if [ "$1" = "" ] ; then
        echo "Usage: ./"$0" DomainName"
        exit
fi
domain=$1
mkdir /var/www/$domain
chown -R pi:www-data /var/www/$domain
touch /etc/apache2/sites-available/$domain.conf
echo "<VirtualHost *:80>
        ServerName "$domain"
        ServerAlias "$domain"
        ServerAdmin webmaster@"$domain"
        DocumentRoot /var/www/"$domain"/public_html
        Alias /favicon.ico /var/www/"$domain"/public_html/required/favicon.ico
        <Directory “/var/www/"$domain"/public_html”>
                Options -Indexes +FollowSymLinks
                AllowOverride All
        </Directory>
        ErrorLog \${APACHE_LOG_DIR}/"$domain"-error.log
        CustomLog \${APACHE_LOG_DIR}/"$domain"-access.log combined
</VirtualHost>" > /etc/apache2/sites-available/$domain.conf
printf "<Directory /var/www/"$domain"/public_html>\n\tAllowOverride All\n\tRequire all granted\n</Directory>\n" >> /etc/apache2/conf-enabled/security.conf
printf "<Directory /var/www/"$domain"/public_html/required>\n\tOptions -Indexes\n</Directory>\n" >> /etc/apache2/conf-enabled/security.conf
a2ensite $domain
systemctl restart apache2
#runuser -l pi -c 'eval `ssh-agent -s` && ssh-add /home/pi/.ssh/github.id_ed25519 && git clone git@github.com:mikeylinton/'$domain'.git /var/www/'$domain
