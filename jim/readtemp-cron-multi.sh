#!/bin/bash

#######################################################################################################

TZ='America/Denver'; export TZ

probe="$$"
maxAttempts=5
scratchDirectory=/tmp/


#######################################################################################################
getReading()
{
   name=$(cat /sys/bus/w1/devices/$2/name 2>/dev/null)

   # if we don't have a sensor
   if [ $? -eq 1 ]
   then
      # base the name on the CPU serial number
      id=$(tail -1 /proc/cpuinfo | awk '{print $3}')
      name="CPU-"${id:(-8)}
      # use the CPU temperature
      rawData="crc=0 YES t=$(cat /sys/class/thermal/thermal_zone0/temp | awk '{printf int($1/1000) * 1000}')"
   else
      if [ "$1" -eq $maxAttempts ]
      then
         if [ -e $scratchDirectory/$probe.txt ]
         then
            # give up and use last temperature. This sensor has worked before
            rawData=$(cat $scratchDirectory/$probe.txt)
         else
            # This sensor has not worked before. Return a temperature of 0
            rawData="crc=0 YES t=-17777.7777777777777777"
         fi
         echo $probe max errors at $(date +"%a %b %d %H:%M:%S") >> $scratchDirectory/temperature_errors.txt
      else
         rawData=$(cat /sys/bus/w1/devices/$probe/w1_slave 2>/dev/null )
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
   probe=$1

   attempts=0

   getReading $attempts $probe

   while [ $crc -eq 1 ] || [ $err -eq 0 ]
   do
      attempts=$(($attempts+1))
      sleep 1
      getReading $attempts
   done

   echo $rawData > $scratchDirectory/$probe.txt

   probeTemperature=$( printf "%.4f" $temperature )

   label=$(cat /var/www/html/$probe.label)
   color=$(cat /var/www/html/$probe.color)
}
#######################################################################################################

for probe in $( cat /sys/bus/w1/devices/28*/name)
do
   getTemperature $probe

# name to probe id - use for getDayTemp.cgi
# basename $(grep -l red /var/www/html/28*label) .label
   fname="/var/www/$probe-temperature-history.txt"
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

