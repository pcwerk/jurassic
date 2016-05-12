#!/bin/sh

source "./config"

WD=`pwd`
( cd $OUTDIR ; \
  tar -cvf ${WD}/${hostname}.tar . ; \
  cd ${WD}; \
  ${COMPRESS} ${hostname}.tar )
