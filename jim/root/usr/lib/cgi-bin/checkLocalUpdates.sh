#!/bin/bash

UP="/boot/config/updateLocal.sh"

if [ -f "$UP" ]; then
   echo "Found $UP, rebooting to do the update"
   sync
   sync
   /sbin/reboot
fi


