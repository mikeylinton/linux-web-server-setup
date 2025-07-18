#!/bin/bash
if [[ $(/usr/bin/id -u) -ne 0 ]]; then
        echo "This script must be run as root"
        exit
fi
systemctl stop apache2
PHP_Version="8.0"#$(php -v | grep -o "PHP "[0-9].[0-9] | grep -o [0-9].[0-9])
Apache2_Directory="/etc/apache2"
rm $Apache2_Directory/sites-available/*
rm $Apache2_Directory/sites-enabled/*
rm $Apache2_Directory/conf-avaliable/*
rm $Apache2_Directory/conf-enabled/*
apt-get --purge remove apache2 -y
apt-get autoremove -y
apt-get install apache2 -y
cd $Apache2_Directory/conf-avaliable/
printf "\nHeader unset X-Powered-By\nHeader always set X-XSS-Protection \"1; mode=block\"\nHeader always append X-Frame-Options \"DENY\"\nHeader always set X-Content-Type-Options \"nosniff\"\nHeader set Referrer-Policy \"no-referrer\"\nHeader always set Strict-Transport-Security \"max-age=31536000;includeSubdomains\"\nHeader always edit Set-Cookie ^(.*)\$ \$1;HttpOnly;Secure;SameSite=stric" >> security.conf
find . -name 'security.conf' -exec sed -i -e 's/ServerSignature On/ServerSignature Off/g' {} \;
find . -name 'security.conf' -exec sed -i -e 's/ServerTokens OS/ServerTokens Prod/g' {} \;
printf "<Directory /var/www/>\n\tAllowOverride None\n\tRequire all denied\n</Directory>\n" >> security.conf
#printf "<Directorymatch \"^/.*/\.git/\">\n\tOrder 'deny,allow'\n\tDeny from all\n</Directorymatch>\n" >> conf-avaliable/security.conf
#printf "<Files ~ \"^\.git\">\n\tOrder 'deny,allow'\n\tDeny from all\n</Files>\n" >> conf-avaliable/security.conf
#\n<LimitExcept GET POST HEAD>\n\tdeny from all\n</LimitExcept>
cd $Apache2_Directory/
printf "\nH2ModernTLSOnly off\nProtocols h2 http/1.1\n<LocationMatch \"\\/\\.\\\">\n\tRequire all denied\n</LocationMatch>\nFileETag None\nServerName localhost\n" >> apache2.conf
#find . -name 'apache2.conf' -exec sed -i -e 's/<Directory \/var\/www\/>/<Directory \/var\/www\/>\n\t<IfModule mod_headers.c>\n\t\tHeader always set X-Content-Type-Options nosniff\n\t\tHeader edit Set-Cookie ^(.*)$ $1;HttpOnly;Secure\n\t\tHeader always set X-Frame-Options SAMEORIGIN\n\t\tHeader always set X-XSS-Protection \"1; mode=block\"\n\t\tHeader always set Strict-Transport-Security \"max-age=31536000; includeSubdomains\"\n\t<\/IfModule>\n\t<IfModule mod_rewrite.c>\n\t\tRewriteEngine On\n\t\tRewriteCond %{THE_REQUEST} !HTTP\/1.1$\n\t\tRewriteRule .* - [F]\n\t<\/IfModule>/g' {} \;
find . -name 'apache2.conf' -exec sed -i -e 's/Timeout 300/Timeout 60/g' {} \;
#find . -name 'apache2.conf' -exec sed -i -e 's/Options FollowSymLinks/Options -Indexes/g' {} \;
#find . -name 'apache2.conf' -exec sed -i -e 's/FollowSymLinks//g' {} \;
#find . -name 'apache2.conf' -exec sed -i -e 's/Options Indexes/Options -Indexes/g' {} \;
#find . -name 'apache2.conf' -exec sed -i -e 's/Require all granted/Require all denied/g' {} \;
cd /etc/php/$PHP_Version/apache2/
find . -name 'php.ini' -exec sed -i -e 's/expose_php = On/expose_php = Off/g' {} \;
mkdir $Apache2_Directory/ssl/
a2enmod ssl
a2enmod rewrite
a2enmod headers
a2dismod php$PHP_Version
a2dismod mpm_prefork
a2dismod mpm_event
a2dismod mpm_worker
a2enmod proxy_fcgi setenvif
a2enconf php$PHP_Version-fpm
a2enmod mpm_event
sudo /etc/init.d/apache2 restart
systemctl reload apache2