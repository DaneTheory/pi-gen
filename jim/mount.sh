#!/bin/bash

offset=$(fdisk --list hdd.img | tail -1 | awk '{print $2 * 512}')
sizelimit=$(fdisk --list hdd.img | tail -1 | awk '{print $3 * 512}')

mount -o loop,offset=$offset,sizelimit=$sizelimit hdd.img root

offset=$(fdisk  --list hdd.img | tail -2 | head -1 | awk '{print $2 * 512}')
sizelimit=$(fdisk  --list hdd.img | tail -2 | head -1 | awk '{print $3 * 512}')
mount -o loop,offset=$offset,sizelimit=$sizelimit hdd.img boot


