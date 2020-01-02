#!/bin/bash

getCurrentPeers()
{
   hosts=$(avahi-browse -t -p -k -r _http._tcp | grep -E '^=.*v4.*atureP'| cut -f 8-10 -d';' | tr ";" ":" | sort -u )

   echo "<br>"
   echo "<h4 align='center'>Thermometers detected on the network</h4>"
   echo "<center><table border=1 style='background-color:rgba(247,247,247,0.6)'>"
   echo "<tr><th>Unit</th><th>Version</th><th>Type</th><th>IP Address</th><th>Free</th><th>Temperature</th><th>Uptime</th><th>Color</th></tr>"
   while read -r record; do
      hostPort=$(printf $record | cut -d":" -f 1,2)

      data=$(wget -q -O - http://$hostPort/cgi-bin/state.cgi )

      echo $data | awk -F"," -v hp=$hostPort '{print "<tr><td><a href=\"http://"hp"\">"$1"</a></td><td>"$2"</td><td>"$3"</td><td>"hp"<td>"$4"</td><td>"$5"</td><td>"$6"</td><td bgcolor="$7"></td></tr>"}'

   done <<< "$hosts"
   echo "</table>"
}

echo "Content-type: text/html"
echo ""

cat <<EOF
<!DOCTYPE html>
<html class="full" lang="en">
   <head>
      <meta charset="UTF-8" />
      <meta name=viewport content="width=device-width, initial-scale=1" />
      <link rel="stylesheet" href="css/main.css">
      <link rel="stylesheet" href="css/setup.css">
      <script src="js/jquery-1.8.3.min.js"></script>
      <title>Thermometer Setup</title>
   </head>
   <body>

EOF
getCurrentPeers;

echo "</html></body>"

