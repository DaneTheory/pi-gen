#!/bin/bash

sed -i "s/^export CLEAN.*/export CLEAN/" build.sh

sed -i "s/.*systemctl disable dhcpcd5/#systemctl disable dhcpcd5/" stage2/02-net-tweaks/01-run-chroot.sh

touch stage0/SKIP
touch stage1/SKIP

time ./build.sh



