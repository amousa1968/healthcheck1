#!/bin/sh

# Validate number of arguments
if [ $# -ne 1 ] ; then
  echo "UNCERTAIN: Invalid number of arguments  Usage: process_running "
  exit 1
fi

# Validate number of arguments
PR=`ps -C "$1" | awk '  { 
  if (NR==2) {
print "1"
  }
}'`

#Checks if the specified process is running
if [ "$PR" == "1" ]; then
  echo "SUCCESS: Process '$1' is running DATA:1"
else
  echo "ERROR: Process '$1' is not running DATA:2"
fi