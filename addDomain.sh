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
Apache2_Directory="/etc/apache2"
SSL_Files=$Apache2_Directory/ssl/$domain
SSL_Enabled=false
mkdir /var/www/$domain
chown -R pi:www-data /var/www/$domain
if [[ -f "$SSL_Files.key" && -f "$SSL_Files.crt" && -f "$SSL_Files.ca.crt" ]]; then
    SSL_Enabled=true
fi

printf "<VirtualHost *:80>
        ServerName "$domain"
        ServerAlias "$domain"
        ServerAdmin webmaster@"$domain"
        DocumentRoot /var/www/"$domain"/www/public_html
        ErrorLog \${APACHE_LOG_DIR}/"$domain"-error.log
        CustomLog \${APACHE_LOG_DIR}/"$domain"-access.log combined" > $Apache2_Directory/sites-available/$domain.conf
if $SSL_Enabled; then
        printf "\n\tRedirect permanent / https://www."$domain"/" >> $Apache2_Directory/sites-available/$domain.conf
else
        printf "\n\tRedirect permanent / http://www."$domain"/" >> $Apache2_Directory/sites-available/$domain.conf
fi
printf "\n</VirtualHost>

<VirtualHost *:443>
        ServerName "$domain"
        ServerAlias "$domain"
        ServerAdmin webmaster@"$domain"
        DocumentRoot /var/www/"$domain"/www/public_html
        ErrorLog \${APACHE_LOG_DIR}/"$domain"-error.log
        CustomLog \${APACHE_LOG_DIR}/"$domain"-access.log combined" >> $Apache2_Directory/sites-available/$domain.conf
if $SSL_Enabled; then
        printf "\n\tSSLEngine On
        SSLProtocol -all +TLSv1.2 +TLSv1.3
        SSLCertificateKeyFile "$Apache2_Directory"/ssl/"$domain".key
        SSLCertificateFile    "$Apache2_Directory"/ssl/"$domain".crt
        SSLCertificateChainFile "$Apache2_Directory"/ssl/"$domain".ca.crt" >> $Apache2_Directory/sites-available/$domain.conf
fi
printf "\n\tRedirect permanent / https://www."$domain"/
</VirtualHost>\n" >> $Apache2_Directory/sites-available/$domain.conf

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
        ErrorDocument 403 /404/" > $Apache2_Directory/sites-available/"$subDomain".$domain.conf
if $SSL_Enabled; then
        printf "\tRedirect permanent / https://www."$domain"/" >> $Apache2_Directory/sites-available/"$subDomain".$domain.conf
else
        printf "\tRedirect permanent / http://www."$domain"/" >> $Apache2_Directory/sites-available/"$subDomain".$domain.conf
fi
printf "\n</VirtualHost>

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
        ErrorDocument 403 /404/" >> $Apache2_Directory/sites-available/"$subDomain".$domain.conf
if $SSL_Enabled; then
        printf "\n\tSSLEngine On
        SSLProtocol -all +TLSv1.2 +TLSv1.3
        SSLCertificateKeyFile "$Apache2_Directory"/ssl/"$domain".key
        SSLCertificateFile    "$Apache2_Directory"/ssl/"$domain".crt
        SSLCertificateChainFile "$Apache2_Directory"/ssl/"$domain".ca.crt" >> $Apache2_Directory/sites-available/"$subDomain".$domain.conf
fi
printf "\n</VirtualHost>\n" >> $Apache2_Directory/sites-available/"$subDomain".$domain.conf
printf "<Directory /var/www/"$domain">\n\tOptions -Indexes\n</Directory>\n" >> $Apache2_Directory/conf-enabled/security.conf
printf "<Directory /var/www/"$domain"/"$subDomain"/public_html>\n\tAllowOverride All\n\tRequire all granted\n</Directory>\n" >> $Apache2_Directory/conf-enabled/security.conf
printf "<Directory /var/www/"$domain"/"$subDomain"/public_html/required>\n\tOptions -Indexes\n</Directory>\n" >> $Apache2_Directory/conf-enabled/security.conf
a2ensite $domain
a2ensite $subDomain.$domain
systemctl reload apache2