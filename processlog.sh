#!/bin/sh

source config

if [ -z $OUTDIR ] ; then
  OUTDIR=.
fi

## setup
INIT=$(date +%F-%T)
OUT="${OUTDIR}/${INIT}-running-processes"
DELAY=10
PS='ps axuwww'
touch $OUT

## spin, action, delay
spin() {
  delay=$1
  msg=$2
  i=0
  count=0 
  marks='/ - \ |'
  while [ $count -lt $delay ] ; do
    if [ $# -lt 4 ]; then
      set -- "$@" $marks
    fi
    shift $(( (i+1) % $# ))
    printf '%s\r\r' " $1"
    count=$[$count +1]
    sleep 1
  done
}

while true; do
  NOW=$(date +%F-%T)
  echo "\n\n****** Process check at $NOW  ******\n\n" >> $OUT 
  $PS >> $OUT
  spin ${DELAY} " ${NOW} ${OUT}"
done 
