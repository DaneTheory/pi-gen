#!/bin/bash -e

ln -sf /etc/lighttpd/conf-available/10-cgi.conf /etc/lighttpd/conf-enabled/10-cgi.conf
ln -sf /usr/lib/cgi-bin/ /var/www/html/cgi-bin

echo "* * * * * /var/www/html/cgi-bin/getCurrent.cgi" > /tmp/crontab
echo "* * * * * /var/www/html/cgi-bin/readtemp-cron.sh" >> /tmp/crontab
echo "*/5 * * * * cp /var/www/temperature-history.txt /boot/config/temperature-history.txt" >> /tmp/crontab

cat /tmp/crontab | crontab -u root -

if ! grep -q '^dtoverlay=w1-gpio' /boot/config.txt; then
  echo "dtoverlay=w1-gpio" >> /boot/config.txt
fi

touch /var/www/temperature-history.txt

echo "root:strawberry" | chpasswd

echo "set incsearch!" >> /home/pi/.vimrc
echo "syntax on" >> /home/pi/.vimrc


sed -i 's!^ExecStart=.*!ExecStart=/usr/bin/nymea-networkmanager.sh -d!' /etc/systemd/system/multi-user.target.wants/nymea-networkmanager.service

