#!/bin/bash
if [[ $(/usr/bin/id -u) -ne 0 ]]; then
        echo "This script must be run as root"
        exit
fi
PHP_Version=$(php -v | grep -o "PHP "[0-9].[0-9] | grep -o [0-9].[0-9])
Apache2_Directory="/etc/apache2"
cd $Apache2_Directory
printf "\nServerTokens Prod\nServerSignature  Off\n" >> conf-enabled/security.conf
printf "<Directory /var/www/>\n\tAllowOverride None\n\tRequire all denied\n</Directory>\n" >> conf-enabled/security.conf
printf "<Directorymatch \"^/.*/\.git/\">\n\tOrder 'deny,allow'\n\tDeny from all\n</Directorymatch>\n" >> conf-enabled/security.conf
printf "<Files ~ \"^\.git\">\n\tOrder 'deny,allow'\n\tDeny from all\n</Files>\n" >> conf-enabled/security.conf
printf "\nServerName localhost\n" >> apache2.conf
find . -name 'apache2.conf' -exec sed -i -e 's/<Directory \/var\/www\/>/<Directory \/var\/www\/>\n\t<IfModule mod_headers.c>\n\t\tHeader always set X-Content-Type-Options nosniff\n\t<\/IfModule>/g' {} \;
cd /etc/php/$PHP_Version/apache2/
find . -name 'php.ini' -exec sed -i -e 's/expose_php = On/expose_php = Off/g' {} \;
mkdir $Apache2_Directory/ssl/
a2enmod ssl
systemctl reload apache2
