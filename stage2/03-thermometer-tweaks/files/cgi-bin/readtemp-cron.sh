#!/bin/bash

#######################################################################################################

TZ='America/Denver'; export TZ

probe="$$"
maxAttempts=5
scratchDirectory=/tmp/
dataDir="/var/www/html/data/"


#######################################################################################################
getReading()
{
   name=$(cat /sys/bus/w1/devices/$2/name 2>/dev/null)

   # if we don't have a sensor
   if [ $? -eq 1 && false ]
   then
      # base the name on the CPU serial number
      id=$(tail -1 /proc/cpuinfo | awk '{print $3}')
      name="CPU-"${id:(-8)}
      # use the CPU temperature
      rawData="crc=0 YES t=$(cat /sys/class/thermal/thermal_zone0/temp | awk '{printf int($1/1000) * 1000}')"
   else
      if [ "$1" -eq $maxAttempts ]
      then
         if [ -e $scratchDirectory/$2.txt ]
         then
            # give up and use last temperature. This sensor has worked before
            rawData=$(cat $scratchDirectory/$2.txt)
         else
            # This sensor has not worked before. Return a temperature of 0
            rawData="crc=0 YES t=-17777.7777777777777777"
         fi
         echo $2 max errors at $(date +"%a %b %d %H:%M:%S") >> $scratchDirectory/temperature_errors.txt
      else
         rawData=$(cat /sys/bus/w1/devices/$2/w1_slave 2>/dev/null )
      fi
   fi

   echo $rawData | grep YES   >/dev/null; crc=$?
   echo $rawData | grep 85000 >/dev/null; err=$?

   # note that this will be incorrect if either of the two crc or err checks above are met
   temperature=$(echo $rawData | awk -F '=' '{ print ( $3/1000) * ( 9.0/5.0 ) + 32 ;}' ;)

   # do some sanity checks. Bash can't handle floats, so test as integer
   IntegerTemperature=${temperature%%.*}

   if [ $IntegerTemperature -gt 199 ] || [ $IntegerTemperature -lt -199 ] ; then
      err = 0;
   fi

}
#######################################################################################################
getTemperature()
{
   attempts=0

   getReading $attempts $1

   while [ $crc -eq 1 ] || [ $err -eq 0 ]
   do
      attempts=$(($attempts+1))
      sleep 1
      getReading $attempts $1
   done

   echo $rawData > $scratchDirectory/$1.txt

   probeTemperature=$( printf "%.4f" $temperature )

   label=$(cat $dataDir/$1.label)
   color=$(cat $dataDir/$1.color)
}
#######################################################################################################

for probeName in $( cat /sys/bus/w1/devices/28*/name)
do
   getTemperature $probeName

# name to probe id - use for getDayTemp.cgi
# basename $(grep -l red $dataDir/28*label) .label
   fname="$dataDir/$probeName.txt"
   scratch="/tmp/temperature-history.txt"

   echo $(echo $(($(date +%s%N)/1000000)))\,$probeTemperature,$color,$label,$name >> $fname
   #echo $(echo $(($(date +%s%N)/1000000)))\,$probeTemperature,$color,$label,$name $fname

   # if we have more than two weeks worth, trim it back to one week
   if (( $(wc -l $fname | cut -f 1 -d' ') > 20160 )); then
      tail -10080 $fname > $scratch
      cp $scratch $fname
   fi
done

#######################################################################################################

