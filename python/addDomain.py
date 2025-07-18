#!/bin/bash
if [[ $(/usr/bin/id -u) -ne 0 ]]; then
        echo "This script must be run as root"
        exit
fi
if [ "$2" = "" ] ; then
        echo "Usage: ./"$0" DomainName SubDomain"
        exit
fi
domain=$1
subDomain=$2
mkdir /var/www/$domain
chown -R pi:www-data /var/www/$domain
touch /etc/apache2/sites-available/$domain.conf

echo "<VirtualHost *:80>
        ServerName "$domain"
        ServerAlias "$domain"
        ServerAdmin webmaster@"$domain"
        DocumentRoot /var/www/"$domain"/www/public_html
        ErrorLog \${APACHE_LOG_DIR}/"$domain"-error.log
        CustomLog \${APACHE_LOG_DIR}/"$domain"-access.log combined
        Redirect permanent / https://www."$domain"/
</VirtualHost>

<VirtualHost *:443>
        ServerName "$domain"
        ServerAlias "$domain"
        ServerAdmin webmaster@"$domain"
        DocumentRoot /var/www/"$domain"/www/public_html
        ErrorLog \${APACHE_LOG_DIR}/"$domain"-error.log
        CustomLog \${APACHE_LOG_DIR}/"$domain"-access.log combined
        SSLEngine On
        SSLCertificateKeyFile /etc/apache2/ssl/"$domain".key
        SSLCertificateFile    /etc/apache2/ssl/"$domain".crt
        SSLCertificateChainFile /etc/apache2/ssl/"$domain".ca.crt
        Redirect permanent / https://www."$domain"/
</VirtualHost>" > /etc/apache2/sites-available/$domain.conf

echo "<VirtualHost *:80>
        ServerName "$subDomain"."$domain"
        ServerAlias "$domain"
        ServerAdmin webmaster@"$domain"
        DocumentRoot /var/www/"$domain"/"$subDomain"/public_html
        <Directory “/var/www/"$domain"/"$subDomain"/public_html”>
                Options -Indexes +FollowSymLinks
                AllowOverride All
        </Directory>
        ErrorLog \${APACHE_LOG_DIR}/"$domain"-error.log
        CustomLog \${APACHE_LOG_DIR}/"$domain"-access.log combined
        ErrorDocument 404 /404/
        ErrorDocument 403 /404/
        Redirect permanent / https://www.whistlebarecottage.co.uk/
</VirtualHost>

<VirtualHost *:443>
        ServerName "$subDomain"."$domain"
        ServerAlias "$domain"
        ServerAdmin webmaster@"$domain"
        DocumentRoot /var/www/"$domain"/"$subDomain"/public_html
        <Directory “/var/www/"$domain"/"$subDomain"/public_html”>
                Options -Indexes +FollowSymLinks
                AllowOverride All
        </Directory>
        ErrorLog \${APACHE_LOG_DIR}/"$domain"-error.log
        CustomLog \${APACHE_LOG_DIR}/"$domain"-access.log combined
        ErrorDocument 404 /404/
        ErrorDocument 403 /404/
        SSLEngine On
        SSLCertificateKeyFile /etc/apache2/ssl/"$domain".key
        SSLCertificateFile    /etc/apache2/ssl/"$domain".crt
        SSLCertificateChainFile /etc/apache2/ssl/"$domain".ca.crt
</VirtualHost>" > /etc/apache2/sites-available/"$subDomain".$domain.conf
printf "<Directory /var/www/"$domain">\n\tOptions -Indexes\n</Directory>\n" >> /etc/apache2/conf-enabled/security.conf
printf "<Directory /var/www/"$domain"/"$subDomain"/public_html>\n\tAllowOverride All\n\tRequire all granted\n</Directory>\n" >> /etc/apache2/conf-enabled/security.conf
printf "<Directory /var/www/"$domain"/"$subDomain"/public_html/required>\n\tOptions -Indexes\n</Directory>\n" >> /etc/apache2/conf-enabled/security.conf
a2ensite $domain
a2ensite $subDomain.$domain
systemctl reload apache2
