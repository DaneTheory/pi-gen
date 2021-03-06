#!/bin/bash -e

echo 1 >/boot/config/model.txt

ln -sf /boot/config/model.txt /var/www/html/model
ln -sf /etc/lighttpd/conf-available/10-cgi.conf /etc/lighttpd/conf-enabled/10-cgi.conf
ln -sf /usr/lib/cgi-bin/ /var/www/html/cgi-bin

echo "* * * * * /var/www/html/cgi-bin/getCurrent.cgi" > /tmp/crontab
echo "* * * * * /var/www/html/cgi-bin/readtemp-cron.sh" >> /tmp/crontab
echo "0 * * * * /var/www/html/cgi-bin/checkUpdates.sh" >> /tmp/crontab
echo "0 3 * * * /var/www/html/cgi-bin/checkLocalUpdates.sh" >> /tmp/crontab
echo "*/5 * * * * cp /var/www/html/data/28*.txt /boot/config/" >> /tmp/crontab

cat /tmp/crontab | crontab -u root -

if ! grep -q '^dtoverlay=w1-gpio' /boot/config.txt; then
  echo "dtoverlay=w1-gpio" >> /boot/config.txt
fi

echo "root:strawberry" | chpasswd

echo "set incsearch!" >> /home/pi/.vimrc
echo "syntax on" >> /home/pi/.vimrc
echo "set mouse-=a" >> /home/pi/.vimrc

cp /home/pi/.vimrc /root/

sed -i 's!^ExecStart=.*!ExecStart=/usr/bin/nymea-networkmanager.sh -d!' /lib/systemd/system/nymea-networkmanager.service

ln -sf /var/www/html/css          /var/www/html/setup/css
ln -sf /var/www/html/hosts.txt    /var/www/html/setup/hosts.txt
ln -sf /var/www/html/label        /var/www/html/setup/label
ln -sf /var/www/html/color        /var/www/html/setup/color
ln -sf /var/www/html/scale        /var/www/html/setup/scale
ln -sf /var/www/html/js           /var/www/html/setup/js
ln -sf /var/www/html/images       /var/www/html/setup/images

echo "www-data ALL=(ALL) NOPASSWD:/bin/mv /tmp/updateLocal.sh /boot/config/updateLocal.sh, /sbin/reboot, /usr/sbin/chpasswd, /bin/mv /tmp/htdigest.user /etc/lighttpd/.htpasswd/lighttpd-htdigest.user, /bin/rm -f /var/www/temperature-history.txt, /bin/rm -f  /boot/config/temperature-history.txt, /bin/systemctl enable ssh, /bin/systemctl disable ssh, /bin/systemctl stop ssh, /bin/systemctl start ssh, /bin/systemctl is-enabled ssh, /bin/rm /etc/NetworkManager/system-connections/*, /bin/rm /boot/config/network/*, /sbin/reboot, /bin/cat /var/log/lighttpd/access.log, /bin/mv /tmp/config.txt /boot/config.txt" > /etc/sudoers.d/www

echo "EDITOR=vim" >> /etc/profile
echo "EDITOR=vim" >> /home/pi/.bash_profile
echo "EDITOR=vim" >> /root/.bash_profile

