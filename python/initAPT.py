import os, apt
from apt.progress.text import AcquireProgress
from apt.progress.base import InstallProgress
acquire = AcquireProgress()
install = InstallProgress()

#if restart.upper() == 'N' or restart.upper() == 'NO': exit()
cache = apt.Cache()
pkg = cache['apache2','php','libapache2-mod-php','ufw','fail2ban','neovim','git'] # Access the Package object for python-apt
pkg.mark_install()
cache.update()
cache.open(None)
cache.upgrade()
cache.upgrade(True)
cache.commit(acquire, install)
#os.system("shutdown /r /t 1")