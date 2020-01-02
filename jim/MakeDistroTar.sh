#!/bin/bash

# build an update tar - note the hard-coded type 9 (-1) 
echo update-$(cat root/var/www/html/version)-7.tar.gz 
echo
echo
tar cvzf update-$(cat root/var/www/html/version)-7.tar.gz update.sh update.tar.gz checkUpdates.sh

