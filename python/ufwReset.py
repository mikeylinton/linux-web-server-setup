import subprocess, sys, os

if os.geteuid() != 0: 
    print("ERROR: uid must be 0 but uid is",str(os.geteuid())+'.',"Try running the script as root.")
    exit()

try:
    import pyufw as ufw
except ImportError:
    subprocess.check_call([sys.executable, "-m", "pip", "install", 'pyufw'])
finally:
    import pyufw as ufw

ufw.reset()
#subprocess.call(["rm","/etc/ufw/*rules.*"])

ufw.default(incoming='deny', outgoing='deny', routed='deny')
ufw.add("allow out ssh") #Outgoing SSH connections e.g. Git
ufw.add("allow out http") #APT Repositories
ufw.add("allow in https") #Allow HTTPS access to Apache2 Server
ufw.add("allow out https") #APT Repositories
ufw.add("allow out 53") #Resolve DNS services
ufw.add("allow in from 192.168.0.0/24 to any port 22 proto tcp") #Local SSH connestions
ufw.add("allow out 123") #Time date sync
ufw.add("allow out 587") #PHPMailer port
ufw.set_logging('on')
ufw.enable()
ufw.status()
