#!/bin/bash

#QUERY_STRING="?state=on"
state=`echo "$QUERY_STRING" | grep -oE "(^|[?&])state=[^&]+" | sed "s/%20/ /g" | cut -f 2 -d "="`

echo "Content-type: text/html"
echo ""



if [ "$state" == "off" ]; then
   sudo /bin/systemctl stop ssh
   sudo /bin/systemctl disable ssh
   cat /boot/config/updateLocal.sh > /tmp/updateLocal.sh 2>/dev/null
   cat <<EOF1>>/tmp/updateLocal.sh
   sudo /bin/systemctl stop ssh
   sudo /bin/systemctl disable ssh
EOF1
   sudo mv /tmp/updateLocal.sh /boot/config/updateLocal.sh
else
   if [ "$state" == "on" ]; then
      sudo /bin/systemctl enable ssh
      sudo /bin/systemctl start ssh
      cat /boot/config/updateLocal.sh > /tmp/updateLocal.sh 2>/dev/null
      cat <<EOF2>>/tmp/updateLocal.sh
      sudo /bin/systemctl enable ssh
      sudo /bin/systemctl start ssh
EOF2
      sudo mv /tmp/updateLocal.sh /boot/config/updateLocal.sh
   fi
fi

sudo /bin/systemctl is-enabled ssh

