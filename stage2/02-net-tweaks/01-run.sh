#!/bin/bash -e

install -v -d					"${ROOTFS_DIR}/etc/wpa_supplicant"
install -v -m 600 files/wpa_supplicant.conf	"${ROOTFS_DIR}/etc/wpa_supplicant/"

sed -i 's/-a nymea -p nymea-box/-a "Raspberry Pi" -p "Raspberry Pi"/' ${ROOTFS_DIR}/lib/systemd/system/nymea-networkmanager.service

if [ -v WPA_COUNTRY ]
then
	echo "country=${WPA_COUNTRY}" >> "${ROOTFS_DIR}/etc/wpa_supplicant/wpa_supplicant.conf"
fi

if [ -v WPA_ESSID -a -v WPA_PASSWORD ]
then
on_chroot <<EOF
wpa_passphrase ${WPA_ESSID} ${WPA_PASSWORD} >> "/etc/wpa_supplicant/wpa_supplicant.conf"
EOF
fi
