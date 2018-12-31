#!/bin/bash

filename=$(echo "$QUERY_STRING" | sed -n 's/^.*filename=\([^&]*\).*$/\1/p' | sed "s/%20/ /g")
#filename=temperature-history

entries=1440
entries=10080


echo "Content-type: application/text"
echo ""

tail -$entries  /var/www/${filename}.txt 
