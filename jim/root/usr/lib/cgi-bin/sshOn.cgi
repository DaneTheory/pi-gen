#!/bin/sh

echo "Content-type: text/plain"
echo ""

sudo systemctl enable ssh
sudo systemctl start  ssh

sudo systemctl is-enabled ssh

