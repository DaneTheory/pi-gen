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
         status=$?

         # if this file is bad
         if [ $status -ne 0 ]; then
            echo "$(date) Bad update file, deleting" >>/usr/lib/cgi-bin/updatelog.txt
#            rm $remotePackage
            exit 1;
         fi

         cp update.tar.gz update.sh /boot/config/
         cp /var/www/temperature-history.txt /boot/config/temperature-history.txt
         sync
         sync
         /sbin/reboot
      fi
   fi
fi
