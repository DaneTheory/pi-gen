#!/bin/sh

tar="/boot/config/update.tar.gz"

## cleanup
rm -f /var/www/html/cgi-bin/configure.cgi	
rm -f /var/www/html/cgi-bin/configurePassword.cgi
rm -f /var/www/html/cgi-bin/resetData.cgi

tar tzf $tar
status=$?

# if this file is bad
if [ $status -ne 0 ]; then
   echo "Bad update file, deleting"
   rm $tar
   exit 1;
fi

cd /

# backup so we can restore
cp /etc/lighttpd/.htpasswd/lighttpd-htdigest.user /tmp/lighttpd-htdigest.user

tar xvzf $tar

mv /tmp/lighttpd-htdigest.user /etc/lighttpd/.htpasswd/lighttpd-htdigest.user

exit 0
