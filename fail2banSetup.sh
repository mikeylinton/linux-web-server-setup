#!/bin/bash
if [[ $(/usr/bin/id -u) -ne 0 ]]; then
        echo "This script must be run as root"
        exit
fi
cd /etc/fail2ban/
cp jail.conf jail.local
#Clear default log paths
find . -name 'jail.local' -exec sed -i -e 's/logpath\s*=\s*%(apache_error_log)s//g' {} \;
find . -name 'jail.local' -exec sed -i -e 's/logpath\s*=\s*%(apache_access_log)s//g' {} \;
find . -name 'jail.local' -exec sed -i -e 's/logpath\s*=\s*%(nginx_access_log)s//g' {} \;
find . -name 'jail.local' -exec sed -i -e 's/\s*%(apache_access_log)s//g' {} \;
#apache-forbidden jail
find . -name 'jail.local' -exec sed -i -e 's/\[apache-auth\]/\[apache-forbidden\]\nenabled = true\nport = http,https\nfilter = apache-forbidden\nlogpath = \/var\/log\/fail2ban\/apache-forbidden.log\nbantime = 3600\nfindtime = 600\nmaxretry = 5\n\n\[apache-auth\]/g' {} \;
#apache-unavailable jail
find . -name 'jail.local' -exec sed -i -e 's/\[apache-auth\]/\[apache-unavailable\]\nenabled = true\nport = http,https\nfilter = apache-unavailable\nlogpath = \/var\/log\/fail2ban\/apache-unavailable.log\nbantime = 3600\nfindtime = 600\nmaxretry = 5\n\n\[apache-auth\]/g' {} \;
#apache-auth jail
find . -name 'jail.local' -exec sed -i -e 's/\[apache-auth\]/\[apache-auth\]\nenabled  = true\nfilter   = apache-auth\nlogpath = \/var\/log\/fail2ban\/apache-auth.log/g' {} \;
#apache-badbots jail
find . -name 'jail.local' -exec sed -i -e 's/\[apache-badbots\]/\[apache-badbots\]\nenabled  = true\nfilter   = apache-badbots\nlogpath = \/var\/log\/fail2ban\/apache-badbots.log/g' {} \;
#apache-nohome jail
find . -name 'jail.local' -exec sed -i -e 's/\[apache-nohome\]/\[apache-nohome\]\nenabled  = true\nfilter   = apache-nohome\nlogpath = \/var\/log\/fail2ban\/apache-nohome.log/g' {} \;
#apache-noscript jail
find . -name 'jail.local' -exec sed -i -e 's/\[apache-noscript\]/\[apache-noscript\]\nenabled  = true\nfilter   = apache-noscript\nlogpath = \/var\/log\/fail2ban\/apache-noscript.log/g' {} \;
#apache-overflow jail
find . -name 'jail.local' -exec sed -i -e 's/\[apache-overflows\]/\[apache-overflows\]\nenabled  = true\nfilter   = apache-overflows\nlogpath = \/var\/log\/fail2ban\/apache-overflows.log/g' {} \;
#php-url-fopen jail
find . -name 'jail.local' -exec sed -i -e 's/\[php-url-fopen\]/\[php-url-fopen\]\nenabled  = true\nlogpath = \/var\/log\/fail2ban\/php-url-fopen.log/g' {} \;
mkdir /var/log/fail2ban
cd /var/log/fail2ban/
touch apache-forbidden.log
touch apache-unavailable.log
touch apache-auth.log
touch apache-badbots.log
touch apache-nohome.log
touch apache-noscript.log
touch apache-overflows.log
touch php-url-fopen.log
cd /etc/fail2ban/filter.d/
printf "[Definition]\nfailregex = <HOST> - - .*HTTP/[0-9]+(.[0-9]+)?\" 403 *" > apache-forbidden.conf
printf "[Definition]\nfailregex = <HOST> - - .*HTTP/[0-9]+(.[0-9]+)?\" 503 *\n<HOST> - - .*HTTP/[0-9]+(.[0-9]+)?\" 500 *\n<HOST> - - .*HTTP/[0-9]+(.[0-9]+)?\" 404 451 *" > apache-unavailable.conf
systemctl restart fail2ban
fail2ban-client status
