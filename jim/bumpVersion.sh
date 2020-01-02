#!/bin/bash

echo $(($(cat current)+1))>current
#printf $(cat root/var/www/html/version | cut -f 1-3 -d'.').$(cat current)>root/var/www/html/version
printf $(cat root/var/www/html/version | cut -f 1-3 -d'.').$(printf "%02d" $(cat current))
echo
printf $(cat root/var/www/html/version | cut -f 1-3 -d'.').$(printf "%02d" $(cat current))>root/var/www/html/version
