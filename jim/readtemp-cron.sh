#!/bin/bash

#######################################################################################################

TZ='America/Denver'; export TZ

probe="$$"
maxAttempts=5
scratchDirectory=/tmp/


#######################################################################################################
getReading()
{
   # assume success
   err=1;
   crc=0

   if [ "$1" -eq $maxAttempts ]
   then
      if [ -e $scratchDirectory/probe.txt ]
      then
         # give up and use last temperature. This sensor has worked before
         rawData=$(cat $scratchDirectory/probe.txt)
      else
         # This sensor has not worked before. Return a temperature of 0
         rawData="{"Temperature" : 0.0,"ChipID" : 10004612,"MAC" : "18-FE-34-98-A8-84","Heap" : 13680,"Ticks" : 552761798}"
      fi
      echo probe max errors at $(date +"%a %b %d %H:%M:%S") >> $scratchDirectory/temperature_errors.txt
   else
      rawData=$(wget --timeout=10 -q http://192.168.1.179/ -O - )
   fi

   if [ -z "$rawData" ]
   then
       err=0
       crc=1;
       temperature="";
   else
       temperature=$( echo $rawData | awk '{print $3}' | cut -f 1 -d',')
       name=$( echo $rawData | awk '{print $7}' | cut -f 1 -d',' | tr -d '"' )

       # do some sanity checks. Bash can't handle floats, so test as integer
       IntegerTemperature=${temperature%%.*}

       if [ $IntegerTemperature -gt 199 ] || [ $IntegerTemperature -lt -199 ] ; then
          err = 0;
       fi

       if [ -z "$temperature" ]; then
          err=0;
          crc=1;
       else
          # seems to be an error value
          if [ $( echo $temperature | cut -f 1 -d .) -eq "185" ]; then
             err=0;
             crc=1;
          fi
       fi
   fi
}
#######################################################################################################
getTemperature()
{
   attempts=0

   getReading $attempts

   while [ $crc -eq 1 ] || [ $err -eq 0 ]
   do
      attempts=$(($attempts+1))
      sleep 1
      getReading $attempts
   done

   echo $rawData > $scratchDirectory/probe.txt

   probeTemperature=$( printf "%.4f" $temperature )

   label=$(cat /var/www/html/label)
   color=$(cat /var/www/html/color)
}
#######################################################################################################

getTemperature

echo $(echo $(($(date +%s%N)/1000000)))\,$probeTemperature,$color,$label,$name>>/var/www/temperature-history.txt

# if we have more than two weeks worth, trim it back to one week
if (( $(wc -l /var/www/temperature-history.txt | cut -f 1 -d' ') > 20160 )); then
   tail -10080 /var/www/temperature-history.txt > /tmp/temperature-history.txt
   cp /tmp/temperature-history.txt /var/www/temperature-history.txt
fi

#######################################################################################################

