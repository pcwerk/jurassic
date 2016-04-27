#!/bin/sh

source "./config"

if [ -z $OUTDIR ] ; then
  OUTDIR=.
fi

DELAY=10
PS='ps axuwww'

## setup
mkdir -p ${OUTDIR}/processes
INDEX=${OUTDIR}/processes/index-$(date +%F-%T)
touch $INDEX

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
    printf '%s\r\r' "$1"
    sleep 1
    count=$[$count +1]
  done
}

echo "  Index: $INDEX"
echo "  Date & Time           Log File"
while true; do
  NOW=$(date +%F-%T)
  OUT="${OUTDIR}/processes/${NOW}"

  echo "$NOW $OUT" >> $INDEX
  echo "\n\n****** Process check at $NOW  ******\n\n" >> $OUT 
  $PS >> $OUT
  spin ${DELAY} "  ${NOW}   ${OUT}"
done 
