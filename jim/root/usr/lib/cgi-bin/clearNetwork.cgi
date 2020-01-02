#!/bin/bash

#QUERY_STRING="?pass=this%20is%20a%20test"

echo "Content-type: text/html"
echo ""

sudo /bin/rm /etc/NetworkManager/system-connections/*
sudo /bin/rm /boot/config/network/*


echo "<body>"
echo "<div><h1>Network Credentials Cleared</h1></div>"
echo "</body>"

