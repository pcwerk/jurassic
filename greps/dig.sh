#!/usr/bin/env bash

TARGET=$1

if [ -z $TARGET ] ; then
  echo "usage: $0 <target dir>"
  exit 1
fi

export IFS=$'\n'
for key in `cat keys.txt`; do
  echo "== $key =="
  grep -n -r "$key" .
done

