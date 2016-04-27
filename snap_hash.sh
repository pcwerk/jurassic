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

for f in  $HASH_DIRS; do
  echo $f
  find $f -type f | xargs -d '\n' md5sum > $OUT/md5-hashes.txt
  find $f -type f | xargs -d '\n' sha1sum > $OUT/sha1-hashes.txt
done

