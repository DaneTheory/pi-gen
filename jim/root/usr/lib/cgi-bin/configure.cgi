#!/bin/bash

#QUERY_STRING="?SSID=this%20is%20a%20test&password=blah%20blah"

parse_query()  #@ USAGE: parse_query var [var ...]
{
    local var val
    local IFS='&'
    vars="&$*&"
    [ "$REQUEST_METHOD" = "POST" ] && read QUERY_STRING
    set -f
    for item in $QUERY_STRING
    do
      var=${item%%=*}
      val=${item#*=}
      val=${val//+/ }
      case $vars in
         *"&$var&"* )
             case $val in
                 *%[0-9a-fA-F][0-9a-fA-F]*)
                      val=$( printf "%b" "${val//\%/\\x}." )
                      val=${val%.}
             esac
             eval "$var=\$val"
             ;;
      esac
    done
    set +f
}

echo "Content-type: text/html"
echo ""

parse_query label color scale id

echo "$label" > /var/www/html/data/${id}.label
echo "$color" > /var/www/html/data/${id}.color
echo "$scale" > /var/www/html/scale

echo "<body>"
echo "<div><h1>Color and Label changed</h1></div>"
echo "<h4>Color: " $color " Label : " $label "Scale " $scale "</h4>"
echo "</body>"

