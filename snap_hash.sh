#!/bin/sh

source "./config"

if [ -z $OUTDIR ] ; then
  OUTDIR=.
fi

## setup
OUT=${OUTDIR}/hash
mkdir -p ${OUT}

o Collecting hashes...
echo OS Type: nix >> $OUT/Hashes.txt
echo >> $OUT/Hashes.txt
echo Computername: $hostname >> $OUT/Hashes.txt
echo >> $OUT/Hashes.txt
echo Time stamp: `date` >> $OUT/Hashes.txt
echo >> $OUT/Hashes.txt
echo ======================MD5 HASHES===================== >> $OUT/Hashes.txt
echo >> $OUT/Hashes.txt
find $HASH_DIRS -type f \( ! -name Hashes.txt \)-exec md5sum {} >> $OUT/Hashes.txt \; 
