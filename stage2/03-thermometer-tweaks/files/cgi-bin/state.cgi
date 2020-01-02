#!/bin/bash

echo "Content-type: text/plain"
echo ""

echo "$(cat /var/www/html/data/28*label),$(cat /var/www/html/version),$(cat /var/www/html/model),$(df -h | grep rw | awk '{print $4}'), $(tail -1 /var/www/html/data/28*txt | cut -f 2 -d ','), $(uptime -p | tr -d , | sed -e 's/minutes/min/g; s/hour/hr/g; s/up //; s/minute/min/; s/week/wk/;' ), $(cat /var/www/html/data/28*color)"
