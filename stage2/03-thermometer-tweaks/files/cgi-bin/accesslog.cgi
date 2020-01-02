#!/bin/bash

echo "Content-type: text/html"
echo ""

mynet=$(/sbin/ifconfig -a | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | cut -f 1-3 -d"." )

cat <<EOF
<!DOCTYPE html>
<html class="full" lang="en">
   <head>
      <meta charset="UTF-8" />
      <meta name=viewport content="width=device-width, initial-scale=1" />
      <link rel="stylesheet" href="/css/main.css">
      <script src="/js/jquery-1.8.3.min.js"></script>
      <title>Access Log</title>
   </head>
   <body>

EOF

echo "<center><table border=10 style='background-color:rgba(247, 247, 247, 0.6)'>"
echo "<tr><th></th><th>Access outside of $mynet. network</th></tr>"
echo "<tr><th>Source</th><th>Target</th><th>Status</th></tr>"

sudo /bin/cat /var/log/lighttpd/access.log | grep -v $mynet | grep -v 404 |
   awk '{
      print "<tr>"
         print "<td><a href=checkip.cgi?ip="$1">"$1"</a></td>"
         if ( NF > 10 ) {
            print "<td>",substr($6,2),substr($7, 1, 50),"</td>"
            if ( $9 ~/^2/ )
               color="green";
            else if ( $9 ~/^3/ )
               color="blue";
            else
               color="red";
            print "<td bgcolor="color">",$9,"</td>";
      }
      else {
         print "<td></td><td bgcolor='red'>" $7" </td>"
      }
      print "</tr>"
   }'

echo "</table>"
echo "</html>"

