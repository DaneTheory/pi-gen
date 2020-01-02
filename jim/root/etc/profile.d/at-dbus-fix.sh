if ! /usr/bin/dpkg -l at-spi2-core 2> /dev/null | /bin/grep -q ii ; then
   export NO_AT_BRIDGE=1
fi
