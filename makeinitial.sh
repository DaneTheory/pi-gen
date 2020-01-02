#!/bin/bash

sed -i "s/^export CLEAN.*/export CLEAN=1/" build.sh

sed -i "s/.*systemctl disable dhcpcd5/systemctl disable dhcpcd5/" stage2/02-net-tweaks/01-run-chroot.sh

rm -f stage0/SKIP
rm -f stage1/SKIP

time ./build.sh

