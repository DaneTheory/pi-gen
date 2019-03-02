#!/bin/bash

cd /var/www/html/cgi-bin/

status=$(curl -s -o digest.txt -w "%{http_code}" http://batbox.org/thermometer/digest.txt)

if [ $status -eq 200 ]; then

   remoteVersion=$(grep ^$(cat /boot/config/model.txt) digest.txt | cut -f 2 -d, | tr -d .)
   remotePackage=$(grep ^$(cat /boot/config/model.txt) digest.txt | cut -f 3 -d, )
   localVersion=$(cat /var/www/html/version | tr -d .)

   remoteVersion=$(printf "%-${#localVersion}s" $remoteVersion | tr ' ' 0)

   if [ $localVersion -lt $remoteVersion ]; then
      status=$(curl -s -o $remotePackage -w "%{http_code}" http://batbox.org/thermometer/$remotePackage)

      if [ $status -eq 200 ]; then
         tar xvzf $remotePackage
	 sudo cp update.tar.gz update.sh /boot/config/
	 sync
	 sync
	 sudo reboot
      fi
   fi
fi
