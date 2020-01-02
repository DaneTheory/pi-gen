#!/bin/sh

echo "Content-type: text/plain"
echo ""

sudo /bin/systemctl stop ssh
sudo /bin/systemctl disable ssh

sudo /bin/systemctl is-enabled ssh
