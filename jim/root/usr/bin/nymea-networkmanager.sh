#!/bin/sh

id=$(cat /proc/cpuinfo | grep Serial | cut -d ' ' -f 2 | tail -c 6)

sed -i "s/AdvertiseName=.*/AdvertiseName=Ras Pi $id/" /etc/nymea/nymea-networkmanager.conf

exec /usr/bin/nymea-networkmanager "$@"


