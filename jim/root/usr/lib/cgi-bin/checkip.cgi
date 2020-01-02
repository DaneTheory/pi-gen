#!/bin/bash

. /var/www/html/cgi-bin/urlDecode.sh
cgi_getvars BOTH ALL

if [ -z ${ip} ]; then ip="127.0.0.1";  fi


echo "Content-type: text/html"
echo ""


cat <<EOF
<!DOCTYPE html>
<html class="full" lang="en">
   <head>
      <meta charset="UTF-8" />
      <meta name=viewport content="width=device-width, initial-scale=1" />
      <link rel="stylesheet" href="/css/main.css">
      <script src="/js/jquery-1.8.3.min.js"></script>
      <title>IP Check</title>
   </head>
   <body>

EOF

printf "<center><br><table border=10 style='background-color:rgba(247, 247, 247, 0.6)'>"
printf "<tr><th colspan=1>IP Address</th><th>DNS Record</th></tr>"
printf "<tr>"
printf "<td><a href='http://$ip/'</a>$ip</a>\n"
printf "</td><td>$(host $ip | awk '{print $5}')</td></tr>"
printf "<tr><td><a href='http://$ip:8080/'</a>$ip:8080</a>\n</tr>"
printf "<tr><td><a href='http://$ip:8000/'</a>$ip:8000</a>\n</tr>"
printf "</table>"

printf "<br><a href='javascript:history.back()'>Go Back</a>"

printf "</body></html>"


