wget -O - -q http://batbox.org/thermometer/ | grep -E 'update-.*-[0-9]{1,4}.tar.gz'  | cut -f 2 -d \"  | grep "\-$(cat model.txt)" | sort -r | head -1

