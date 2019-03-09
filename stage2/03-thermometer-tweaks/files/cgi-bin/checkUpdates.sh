#!/bin/bash

cd /var/www/html/cgi-bin/

status=$(curl -s -o updates.txt -w "%{http_code}" http://batbox.org/thermometer/updates.txt)

if [ $status -eq 200 ]; then

   remoteVersion=$(grep "\-$(cat /boot/config/model.txt).tar.gz" updates.txt | cut -f 2 -d'-' | tr -d .)
   remotePackage=$(grep "\-$(cat /boot/config/model.txt ).tar.gz" updates.txt )
   localVersion=$(cat /var/www/html/version | tr -d .)

   remoteVersion=$(printf "%-${#localVersion}s" $remoteVersion | tr ' ' 0)

   if [ $localVersion -lt $remoteVersion ]; then
      status=$(curl -s -o $remotePackage -w "%{http_code}" http://batbox.org/thermometer/$remotePackage)

      if [ $status -eq 200 ]; then
         tar xvzf $remotePackage
	 sudo cp update.tar.gz update.sh /boot/config/
         sudo cp /var/www/temperature-history.txt /boot/config/temperature-history.txt
	 sync
	 sync
	 sudo reboot
      fi
   fi
fi
