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

echo "Content-type: application/json"
echo ""

parse_query label color scale id
#color=1
#label=1;
#scale="F"


[ ! -z "$label" ] && echo "$label" > /var/www/html/data/${id}.label
[ ! -z "$color" ] && echo "$color" > /var/www/html/data/${id}.color
[ ! -z "$scale" ] && echo "$scale" > /var/www/html/scale

  cat <<EOF
      {
      "id":"$id",
      "label":"$label",
      "color":"$color",
      "scale":"$scale"
      }
EOF

exit

