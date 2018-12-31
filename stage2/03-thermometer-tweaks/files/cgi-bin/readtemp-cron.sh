#!/bin/bash

#######################################################################################################

TZ='America/Denver'; export TZ

probe="$$"
maxAttempts=5
scratchDirectory=/tmp/


#######################################################################################################
getReading()
{
   if [ "$3" -eq $maxAttempts ]
   then
      # give up and use last temperature (assumption that this sensor has worked before so the file exists)
      rawData=$(cat $scratchDirectory/$2.txt)
      echo $2 max errors at $(date +"%a %b %d %H:%M:%S") >> $scratchDirectory/temperature_errors.txt
   else
      rawData=$(cat /sys/bus/w1/devices/*/w1_slave )
   fi
   name=$(cat /sys/bus/w1/devices/*/name)

   echo $rawData | grep YES   >/dev/null; crc=$?
   echo $rawData | grep 85000 >/dev/null; err=$?

   # note that this will be incorrect if either of the two crc or err checks above are met
   temperature=$(echo $rawData | awk -F '=' '{ print ( $3/1000) * ( 9.0/5.0 ) + 32 ;}' ;)
}
#######################################################################################################
getTemp()
{
   attempts=0

   getReading $1 $2 $attempts

   # note the check for 31.8884 - getting this incorrect reading from one sensor occassionally.
   # note that this will prevent a valid reading of exactly that temperature from any sensor :-(
   # note that the last floating comparison is an error - i.e. syntax error
   while [ $crc -eq 1 ] || [ $err -eq 0 ] # || [ $temperature -eq 31.8884 ]
   do
      attempts=$(($attempts+1))
      sleep 1
      getReading $1 $2 $attempts
   done

   echo $rawData > $scratchDirectory/$2.txt

   return $attempts
}
#######################################################################################################
readSensors()
{
   getTemp $probe probe ; probeAttempts=$? ; probeTemperature=$( printf "%.4f" $temperature )

   label=$(cat /var/www/html/label)
   color=$(cat /var/www/html/color)

}
#######################################################################################################

readSensors;

echo $(echo $(($(date +%s%N)/1000000)))\,$probeTemperature,$color,$label,$name>>/var/www/temperature-history.txt

# if we have more than two weeks worth, trim it back to one week
if (( $(wc -l /var/www/temperature-history.txt | cut -f 1 -d' ') > 20160 )); then
   tail -10080 /var/www/temperature-history.txt > /tmp/temperature-history.txt
   cp /tmp/temperature-history.txt /var/www/temperature-history.txt
fi

#######################################################################################################
