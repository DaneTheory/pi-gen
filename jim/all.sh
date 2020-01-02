
tar -cvzf ../update.tar.gz \
\
lib/systemd/system/nymea-networkmanager.service \
\
usr/lib/cgi-bin/ \
var/www/ \
var/spool/cron/crontabs/ \
\
etc/sudoers.d/www \
etc/profile \
etc/lighttpd/lighttpd.conf \
etc/lighttpd/conf-available/10-cgi.conf \
etc/lighttpd/.htpasswd/lighttpd-htdigest.user \
etc/avahi/services/http.service \
etc/network/if-up.d/saveNetwork \
etc/rc.local \
\
home/pi/.bash_profile \
root/.bash_profile \
sbin/overlayRoot.sh \
\
usr/bin/nymea-networkmanager.sh \
etc/nymea/nymea-networkmanager.conf \

