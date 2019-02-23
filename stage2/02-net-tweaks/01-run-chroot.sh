#!/bin/bash -e

systemctl enable ssh

systemctl is-enabled dhcpcd5
status=$?

echo status is $status

#systemctl disable dhcpcd5

