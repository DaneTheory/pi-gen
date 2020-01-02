#!/bin/bash

#QUERY_STRING="?state=on"
state=`echo "$QUERY_STRING" | grep -oE "(^|[?&])state=[^&]+" | sed "s/%20/ /g" | cut -f 2 -d "="`

tempfile=$(mktemp)

echo "Content-type: text/html"
echo ""

echo $state

if [ "$state" == "off" ]; then
   sed '/^dtoverlay/d' /boot/config.txt > $tempfile
   echo "dtoverlay=w1-gpio" >> $tempfile
else
   if [ "$state" == "on" ]; then
   sed '/^dtoverlay/d' /boot/config.txt > $tempfile
   echo "dtoverlay=w1-gpio,pullup=on" >> $tempfile
   fi
fi

