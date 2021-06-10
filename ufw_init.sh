if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "Not running as root"
    exit
fi
yes | ufw reset
ufw default deny incoming comment "Default Deny all incomming connections"
ufw default deny outgoing comment "Default Deny all outgoing connections"
ufw allow out ssh comment "Outgoing SSH connections e.g. Git"
ufw allow in http comment "Allow HTTP access to Apache2 Server"
ufw allow out http comment "HTTP APT Repositories"
ufw allow in https comment "Allow HTTPS access to Apache2 Server"
ufw allow out https comment "HTTPS APT Repositories"
ufw allow out 53 comment "Resolve DNS services"
ufw allow in from 192.168.0.0/24 to any port 22 proto tcp comment "Local SSH connestions"
ufw logging on
yes | ufw enable
