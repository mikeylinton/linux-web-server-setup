#!/bin/bash
if [[ $(/usr/bin/id -u) -ne 0 ]]; then
        echo "Not running as root"
        exit
fi
if [ "$1" = "" ] ; then
        echo "Usage: ./"$0" DomainName"
fi
domain=$1
mkdir /var/www/$domain
mkdir /var/www/$domain/public_html
chown -R www-data: /var/www/$domain
touch /etc/apache2/sites-available/$domain.conf
echo "<VirtualHost *:80>
        ServerName "$domain"
        ServerAlias "$domain"
        ServerAdmin webmaster@"$domain"
        DocumentRoot /var/www/"$domain"/public_html

        <Directory “/var/www/"$domain"/public_html”>
                Options -Indexes +FollowSymLinks
                AllowOverride All
        </Directory>

        ErrorLog \${APACHE_LOG_DIR}/"$domain"-error.log
        CustomLog \${APACHE_LOG_DIR}/"$domain"-access.log combined
</VirtualHost>" > /etc/apache2/sites-available/$domain.conf
a2ensite $domain
systemctl restart apache2
