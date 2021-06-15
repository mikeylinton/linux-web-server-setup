#!/bin/bash
if [[ $(/usr/bin/id -u) -ne 0 ]]; then
        echo "This script must be run as root"
        exit
fi
printf "\nServerTokens Prod\nServerSignature  Off\n" >> /etc/apache2/conf-enabled/security.conf
cd /etc/php/7.3/apache2/
find . -name 'php.ini' -exec sed -i -e 's/expose_php = Off/expose_php = On/g' {} \;
sytemctl restart apache2.service
