#!/bin/bash

#QUERY_STRING="?pass=this%20is%20a%20test"

echo "Content-type: text/html"
echo ""

user="pi"
realm="temperature"
pass=`echo "$QUERY_STRING" | grep -oE "(^|[?&])pass=[^&]+" | sed "s/%20/ /g" | cut -f 2 -d "="`

hash="$(echo -n "$user:$realm:$pass" | md5sum | cut -b -32 )"

cat <<EOF >/tmp/updateLocal.sh
#!/bin/bash

echo "$user:$realm:$hash" > /etc/lighttpd/.htpasswd/lighttpd-htdigest.user
echo "pi:$pass" | chpasswd

EOF

sudo mv /tmp/updateLocal.sh /boot/config/updateLocal.sh

# note that these are only temporary since we have an overlay filesystem
# the above script is meant to run at boot time to make permamnt.
echo "$user:$realm:$hash" > /etc/lighttpd/.htpasswd/lighttpd-htdigest.user
echo "pi:$pass" | sudo /usr/sbin/chpasswd


echo "<body>"
echo "<div><h1>Password changed</h1></div>"
echo "</body>"

