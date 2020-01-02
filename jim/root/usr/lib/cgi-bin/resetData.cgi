#!/bin/bash

#QUERY_STRING="?pass=this%20is%20a%20test"

echo "Content-type: text/html"
echo ""

a=$(sudo /bin/rm -f /var/www/html/data/28*.txt 2>&1)
b=$(sudo /bin/rm -f /boot/config/28*.txt 2>&1)

echo "Result is " $a " " $b

echo "<body>"
echo "<div><h1>Data Cleared</h1></div>"
echo "</body>"

