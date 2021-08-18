#!/bin/bash
if [[ $(/usr/bin/id -u) -ne 0 ]]; then
        echo "This script must be run as root"
        exit
fi
printf "\nServerTokens Prod\nServerSignature  Off\n" >> /etc/apache2/conf-enabled/security.conf
printf "<Directory /var/www/>\n\tAllowOverride None\n\tRequire all denied\n</Directory>\n" >> /etc/apache2/conf-enabled/security.conf
printf "<Directorymatch \"^/.*/\.git/\">\n\tOrder 'deny,allow'\n\tDeny from all\n</Directorymatch>\n" >> /etc/apache2/conf-enabled/security.conf
printf "<Files ~ \"^\.git\">\n\tOrder 'deny,allow'\n\tDeny from all\n</Files>\n" >> /etc/apache2/conf-enabled/security.conf
mkdir /etc/apache2/ssl/
printf "\nServerName localhost\n" >> /etc/apache2/apache2.conf
cd /etc/php/7.3/apache2/
find . -name 'php.ini' -exec sed -i -e 's/expose_php = Off/expose_php = On/g' {} \;
systemctl reload apache2
