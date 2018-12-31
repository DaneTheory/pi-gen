#!/bin/bash -e

ln -sf /etc/lighttpd/conf-available/10-cgi.conf /etc/lighttpd/conf-enabled/10-cgi.conf
ln -sf /usr/lib/cgi-bin/ /var/www/html/cgi-bin

chmod +x /sbin/overlayRoot.sh

echo "* * * * * /var/www/html/cgi-bin/readtemp-cron.sh" | crontab -u pi -

echo "* * * * * /var/www/html/cgi-bin/getCurrent.cgi" > /tmp/crontab
echo "*/5 * * * * cp /var/www/temperature-history.txt /boot/config/temperature-history.txt" >> /tmp/crontab

cat /tmp/crontab | crontab -u root -

if ! grep -q '^dtoverlay=w1-gpio' /boot/config.txt; then
  echo "dtoverlay=w1-gpio" >> /boot/config.txt
fi

touch /var/www/temperature-history.txt
chown pi:pi /var/www/temperature-history.txt

echo "pi:strawberry" | chpasswd
echo "root:strawberry" | chpasswd

mkdir -p /boot/config/network
