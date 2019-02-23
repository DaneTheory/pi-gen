#!/bin/bash -e

mkdir -p ${ROOTFS_DIR}/boot/config/network
mkdir -p ${ROOTFS_DIR}/usr/lib/cgi-bin
mkdir -p ${ROOTFS_DIR}/var/www/html/css
mkdir -p ${ROOTFS_DIR}/var/www/html/js
mkdir -p ${ROOTFS_DIR}/var/www/html/images
mkdir -p ${ROOTFS_DIR}/var/www/html/setup
mkdir -p ${ROOTFS_DIR}/etc/lighttpd/.htpasswd

install -v files/cgi-bin/configure.cgi        "${ROOTFS_DIR}/usr/lib/cgi-bin/"
install -v files/cgi-bin/getCurrent.cgi       "${ROOTFS_DIR}/usr/lib/cgi-bin/"
install -v files/cgi-bin/getDayTemp.cgi       "${ROOTFS_DIR}/usr/lib/cgi-bin/"
install -v files/cgi-bin/readtemp-cron.sh     "${ROOTFS_DIR}/usr/lib/cgi-bin/"
install -v files/cgi-bin/urlDecode.sh         "${ROOTFS_DIR}/usr/lib/cgi-bin/"

install -v files/css/main.css                 "${ROOTFS_DIR}/var/www/html/css/"
install -v files/css/setup.css                "${ROOTFS_DIR}/var/www/html/css/"

install -v files/images/smallGear.png         "${ROOTFS_DIR}/var/www/html/images/"
install -v files/images/trianglify.svg        "${ROOTFS_DIR}/var/www/html/images/"

install -v files/js/jquery-1.8.3.min.js       "${ROOTFS_DIR}/var/www/html/js/"
install -v files/js/jquery.flot.js            "${ROOTFS_DIR}/var/www/html/js/"
install -v files/js/jquery.flot.selection.js  "${ROOTFS_DIR}/var/www/html/js/"

install -v files/html/favicon.ico             "${ROOTFS_DIR}/var/www/html/"
install -v files/html/index.html              "${ROOTFS_DIR}/var/www/html/"

install -v files/html/setup.html              "${ROOTFS_DIR}/var/www/html/setup/"
install -v files/html/hash.sh                 "${ROOTFS_DIR}/var/www/html/setup/"
install -v files/html/version.txt             "${ROOTFS_DIR}/var/www/html/setup/"
install -v files/lighttpd.conf                "${ROOTFS_DIR}/etc/lighttpd/lighttpd.conf"
install -v files/lighttpd-htdigest.user       "${ROOTFS_DIR}/etc/lighttpd/.htpasswd/lighttpd-htdigest.user"

install -v files/rc.local                     "${ROOTFS_DIR}/etc/"
install -v files/http.service                 "${ROOTFS_DIR}/etc/avahi/services/"
install -v files/saveNetwork                  "${ROOTFS_DIR}/etc/network/if-up.d/"
install -v files/overlayRoot.sh               "${ROOTFS_DIR}/sbin/"
install -v files/nymea-networkmanager.sh      "${ROOTFS_DIR}/usr/bin/"

if ! grep -q overlayRoot.sh ${ROOTFS_DIR}/boot/cmdline.txt; then
    sed -i 's/$/ init=\/sbin\/overlayRoot.sh/' ${ROOTFS_DIR}/boot/cmdline.txt
fi

if ! grep -q www-data ${ROOTFS_DIR}/etc/lighttpd/lighttpd.conf; then
    sed -i 's/www-data/root/'  ${ROOTFS_DIR}/etc/lighttpd/lighttpd.conf
fi

sed -i 's/BT WLAN setup/RaspberryPi/' ${ROOTFS_DIR}/etc/nymea/nymea-networkmanager.conf
sed -i 's/Mode=offline/Mode=start/'   ${ROOTFS_DIR}/etc/nymea/nymea-networkmanager.conf
