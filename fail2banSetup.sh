#!/bin/bash
if [[ $(/usr/bin/id -u) -ne 0 ]]; then
        echo "This script must be run as root"
        exit
fi
cd /etc/fail2ban/
cp jail.conf jail.local
find . -name 'jail.local' -exec sed -i -e 's/\[apache\]/\[apache\]\nenabled  = true/g' {} \;
find . -name 'jail.local' -exec sed -i -e 's/\[apache-noscript\]/\[apache-noscript\]\nenabled  = true/g' {} \;
find . -name 'jail.local' -exec sed -i -e 's/\[apache-overflows\]/\[apache-overflows\]\nenabled  = true/g' {} \;
find . -name 'jail.local' -exec sed -i -e 's/\[apache-overflows\]/\[apache-nohome\]\nenabled  = true\nfilter   = apache-nohome/g' {} \;
find . -name 'jail.local' -exec sed -i -e 's/\[apache-overflows\]/\[apache-badbots\]\nenabled  = true\nfilter   = apache-badbots/g' {} \;
find . -name 'jail.local' -exec sed -i -e 's/\[php-url-fopen\]/\[php-url-fopen\]\nenabled  = true/g' {} \;
