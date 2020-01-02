#!/bin/bash

filename=$(echo "$QUERY_STRING" | sed -n 's/^.*filename=\([^&]*\).*$/\1/p' | sed "s/%20/ /g")
sensor=$(echo "$QUERY_STRING" | sed -n 's/^.*sensor=\([^&]*\).*$/\1/p' | sed "s/%20/ /g")
dataDir="/var/www/html/data/"

#sensor="28-000004f7437f"

entries=10080

echo "Content-type: application/text"
echo ""

# if a specific sensor was not specified
if [ -z "$sensor" ]
then
   # see what's available
   sensor=$(cat /sys/bus/w1/devices/28*/name)

   # if there's more than one
   if [[ "$(echo "$sensor" | wc -l)" -gt 1 ]]; then
      # tell the caller he's going to have to choose
      echo "*MULTIPLE"
      echo "$sensor"
      exit
   fi
fi

tail -$entries  $dataDir/${sensor}.txt 2>/dev/null
