#!/bin/bash

# Version 1.0 6/7/2018

BASE="/var/tmp/readings/"
ACCESS="$BASE/access.txt"

# in seconds
current=$(date +%s);

# if the last access file does not exist
if [ ! -e $ACCESS ]
then
    echo $current > $ACCESS
fi

last=$(cat $ACCESS)


# Collect data from all the thermometers we can find.
# put the data in a file based on the 'name' field
getCurrentData()
{
   hosts=$(avahi-browse -t -p -k -r _http._tcp | grep -E '^=.*v4.*atureP'| cut -f 8-10 -d';' | tr ";" ":" | sort)

   scratch=$BASE/scratch/temp$$

   echo "">/var/www/html/hosts.txt
   while read -r record; do
      hostPort=$(printf $record | cut -d":" -f 1,2)
      #url=$(printf "$record" | cut -d "\"" -f 2 | cut -d"=" -f 2)
      #url=$(printf "$record" | cut -d ":" -f 3 | cut -f 1 -d" " | tr -d "\"" | cut -f 2-3 -d "=")

      url=$(printf $record | cut -d "\"" -f 2)
      url=${url:4}

      wget -q -O - http://$hostPort/$url > $scratch
      status=$?

      if [[ -s $scratch && $status -eq 0 ]]; then
         probe=$(tail -1 $scratch | cut -d"," -f 4 )

         # if the probe is blank, the data is bad, skip
         if [ -z "$probe" ]; then
            rm $scratch
            continue;
         fi

         id=$(tail -1 $scratch | cut -d"," -f 5 )
         if [ -z "$id" ]; then
            filename="$probe"
         else
            filename="$id"
         fi
   
         echo "$hostPort|$probe">>/var/www/html/hosts.txt
         mv $scratch "$BASE/probes/$filename"
      fi
   done <<< "$hosts"

   # cleanup
   rm -f $BASE/scratch/*

   # clean up any files not acessed in the last 24 hours (24 * 60 );
   # this would likely be due to a probe that went away
   find $BASE/probes/ -mmin +1440 -type f -exec rm {} \;
}

# if this isn't a cgi-executed execution
# typically called from cron job
if [ -z ${QUERY_STRING} ]; then

   # if some one has accessed the data in the last three minutes (60 * 3), update as we have a current user
   if ((current-last < 180 )); then
      getCurrentData;
   fi

   # if the color has been updated
   if ! cmp -s /var/www/html/color /boot/config/color
   then
      cp /var/www/html/color /boot/config/color
   fi

   # if the label has been updated
   if ! cmp -s /var/www/html/label /boot/config/label
   then
      cp /var/www/html/label /boot/config/label
   fi

   # kill any active getCurrent's that have been running longer that 45 seconds - hung?
   kill $(ps -eo comm,pid,etimes | grep -v defunct |  awk '/^getCurrent/ {if ($3 > 45) { print $2}}')

   exit 0

fi

# if the data is older than two minutes (60 * 2)
if ((current-last > 120 )); then
   getCurrentData;
#   cl=$((current-last));
#   debug=",</h2><h4>$cl Load time "
   debug=",</h2><h4>Load time "
else
#   seconds=$((current-last));
#   dots="";
#   for ((number=1;number < $seconds;number++))
#   {
#      dots="$dots."
#   }
dots="."
   debug="$dots</h2><h4>Load time "
fi

# we are a current user 
echo $current>$ACCESS

. /var/www/html/cgi-bin/urlDecode.sh
cgi_getvars BOTH ALL

if [ -z ${days} ]; then days=1;  fi

printf "Content-type: application/json\n\n"

num=$((days*1440))

DIR="$BASE/probes/"

export daysback=$(($(date -d "-$days days" +%s%N)/1000000))

printf "["

OIFS=$IFS
IFS=$'\n'       # make newlines the only separator

for file in $( ls $DIR )
do
   lastData=$(tail -1 $DIR/$file)

   probe=$(printf "$lastData" | awk -F',' '{ printf("%s", $4 ) }')

   printf "{"
   printf "\"excludelabel\" : \"$probe\""

   # if we're not excluding this one
   if [[ ! $exclude =~ .*$probe.* ]]; then

      color=$(printf "$lastData" | awk -F',' '{ printf("%s", $3 ) }')
      temperature=$(printf "$lastData" | awk -F',' '{ printf("%s", $2 ) }')
      label=$(printf "%s : %2.2f°F"  "$probe" $temperature )

      printf ",\"excluded\":false,\"color\":\"$color\",\"label\": \"$label\",\"data\": ["
      awk -v days=$days -v mil=$daysback -F',' '
                BEGIN { i=0; j=0 }
                {
                   # if this date is in-range
                   # thin down data when we have multiple days
                   if ( ( $1 >= mil ) && ( j++ % days == 0 ) )
                   {
                      {
                            # commas after first
                         if (i++>0) { printf(",");}
                      }
                      {
                         printf("[%s,%s]", $1,$2 )
                      }
                   }
                 }' $DIR/$file
      printf "]"
   else
      printf ",\"excluded\":true"
   fi
   printf "},"

done
IFS=$OIFS

printf "{\"debug\": \"$debug $(($(date +%s)-current)) seconds for  $(cat /var/www/html/label)\"}]"
