#!/bin/bash

state=$(echo "$QUERY_STRING" | sed -n 's/^.*state=\([^&]*\).*$/\1/p' | sed "s/%20/ /g")

echo "Content-type: application/json"
echo ""
count=0;
echo "{ \"sensors\": [ "
for probeName in $( cat /sys/bus/w1/devices/28*/name)
do

  if [ $count -ne 0 ]; then echo "      ,"; fi

  cat <<EOF
      {
      "id":"$probeName",
      "label":"$( cat /var/www/html/data/$probeName.label)",
      "color":"$( cat /var/www/html/data/$probeName.color)"
      }
EOF
  count=$((count+1))
done
echo "]}"

