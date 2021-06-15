#!/bin/bash
if [[ $(/usr/bin/id -u) -ne 0 ]]; then
        echo "This script must be run as root"
        exit
fi
cd /etc/fail2ban/
cp jail.conf jail.local
find . -name 'jail.local' -exec sed -i -e 's/logpath\s*=\s*%(apache_error_log)s//g' {} \;
find . -name 'jail.local' -exec sed -i -e 's/logpath\s*=\s*%(apache_access_log)s//g' {} \;
find . -name 'jail.local' -exec sed -i -e 's/logpath\s*=\s*%(nginx_access_log)s//g' {} \;
find . -name 'jail.local' -exec sed -i -e 's/\[apache-auth\]/\[apache-404\]\nenabled = true\nport = http,https\nfilter = apache-404\nlogpath = \/var\/log\/fail2ban\/apache-404.log\nbantime = 3600\nfindtime = 600\nmaxretry = 5\n\n\[apache-auth\]/g' {} \;
find . -name 'jail.local' -exec sed -i -e 's/\[apache-auth\]/\[apache-auth\]\nenabled  = true\nfilter   = apache-auth\nlogpath = \/var\/log\/fail2ban\/apache-auth.log/g' {} \;
find . -name 'jail.local' -exec sed -i -e 's/\[apache-noscript\]/\[apache-noscript\]\nenabled  = true\nfilter   = apache-noscript\nlogpath = \/var\/log\/fail2ban\/apache-noscript.log/g' {} \;
find . -name 'jail.local' -exec sed -i -e 's/\[apache-overflows\]/\[apache-overflows\]\nenabled  = true\nfilter   = apache-overflows\nlogpath = \/var\/log\/fail2ban\/apache-overflows.log/g' {} \;
find . -name 'jail.local' -exec sed -i -e 's/\[apache-nohome\]/\[apache-nohome\]\nenabled  = true\nfilter   = apache-nohome\nlogpath = \/var\/log\/fail2ban\/apache-nohome.log/g' {} \;
find . -name 'jail.local' -exec sed -i -e 's/\[apache-badbots\]/\[apache-badbots\]\nenabled  = true\nfilter   = apache-badbots\nlogpath = \/var\/log\/fail2ban\/apache-badbots.log/g' {} \;
find . -name 'jail.local' -exec sed -i -e 's/\[php-url-fopen\]/\[php-url-fopen\]\nenabled  = true\nlogpath = \/var\/log\/fail2ban\/php-url-fopen.log/g' {} \;
mkdir /var/log/fail2ban
cd /var/log/fail2ban/
touch apache-404.log
touch apache-auth.log
touch apache-noscript.log
touch apache-overflows.log
touch apache-nohome.log
touch apache-badbots.log
touch php-url-fopen.log
systemctl restart fail2ban
