#!/bin/bash

# Version 1.1 4/5/2019

BASE="/var/tmp/readings/"
ACCESS="$BASE/access.txt"
SCALE=$(cat /var/www/html/scale)

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
   hosts=$(avahi-browse -t -p -k -r _http._tcp | grep -E '^=.*v4.*atureP'| cut -f 8-10 -d';' | tr ";" ":" | sort -u )

   scratch=$BASE/scratch/temp$$

   echo "">/var/www/html/hosts.txt

   # for all of the records we received fromthe avahi browse command
   while read -r record; do
      hostPort=$(printf $record | cut -d":" -f 1,2)
      #url=$(printf "$record" | cut -d "\"" -f 2 | cut -d"=" -f 2)
      #url=$(printf "$record" | cut -d ":" -f 3 | cut -f 1 -d" " | tr -d "\"" | cut -f 2-3 -d "=")

      url=$(printf $record | cut -d "\"" -f 2)
      url=${url:4}
 
      # start with empty array of potentiall remote sensor list
      rsensors=();
      extraArg="";

      # Emulation of a do while loop
      while

      # if we have a list of sensors
      if [ ${#rsensors[@]} -gt 0 ]; then
         extraArg="&sensor=${rsensors[0]}";

         # remove this entry
         unset rsensors[0];

         # reset the array so next will always be [0]
         rsensors=( "${rsensors[@]}" );
      fi 

       # fetch this url with a potential sensor specification
       wget -q -O - http://$hostPort/${url}$extraArg > $scratch
       status=$?

       # if the wget returned data
       if [[ -s $scratch && $status -eq 0 ]]; then

          dataType=$(head -1 $scratch)

          # if we got a return indicating that we need to specify whih sensor to get
          # starts with * then has MULTIPLE somewhere following
          if [[ $dataType  =~ ^\*.*MULTIPLE.*  ]]; then

            rsensors=($(tail -n +2 $scratch ));

          else

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
       fi
       # this is the real check to terminte the loop - emulation of a do while loop
        [ ${#rsensors[@]} -gt 0 ];
       do
          :
       done
   done <<< "$hosts"

   # cleanup
   rm -f $BASE/scratch/*

   # clean up any files not acessed in the last 24 hours (24 * 60 );
   # this would likely be due to a probe that went away
   find $BASE/probes/ -mmin +1440 -type f -exec rm {} \;
   rm -f /tmp/sort*
}

# if this isn't a cgi-executed execution
# typically called from cron job
if [ -z ${QUERY_STRING} ]; then

   # if some one has accessed the data in the last three minutes (60 * 3), update as we have a current user
   if ((current-last < 180 )); then
      getCurrentData;
   fi

   for probeName in $( cat /sys/bus/w1/devices/28*/name)
   do
 
      # if the color has been updated
      if ! cmp -s /var/www/html/data/${probeName}.color /boot/config/data/${probeName}.color
      then
         cp /var/www/html/data/${probeName}.color /boot/config/
      fi

      # if the label has been updated
      if ! cmp -s /var/www/html/data/${probeName}.label /boot/config/${probeName}.label
      then
         cp /var/www/html/data/${probeName}.label /boot/config/
      fi
   done

   # if scale has been updated
   if ! cmp -s /var/www/html/scale /boot/config/scale
   then
      cp /var/www/html/scale /boot/config/scale
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
      temperature=$(printf "$lastData" | awk -v SCALE=$SCALE -F',' '{ if ( SCALE =="C" ) printf("%s", ($2 - 32.0 ) * 0.55555555555 ); else  printf("%s", $2 ) }')
      label=$(printf "%s: %2.2f°%c"  "$probe" $temperature $SCALE )

      printf ",\"excluded\":false,\"color\":\"$color\",\"label\": \"$label\",\"data\": ["
      awk -v SCALE=$SCALE -v days=$days -v mil=$daysback -F',' '
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
                      if ( SCALE =="C" ) { printf("[%s,%s]\n", $1,($2 - 32.0 )  * 0.55555555555) }
                      else { printf("[%s,%s]\n", $1,$2 ) }
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

printf "{\"debug\": \"$debug $(($(date +%s)-current)) seconds for $(cat /var/www/html/data/28$(cat /sys/bus/w1/devices/28*/name 2>/dev/null| head -1 | sed 's/^28//').label)\"}]"


