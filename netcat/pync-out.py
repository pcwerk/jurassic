#!/usr/bin/env python

#  source ftp://ftp.tummy.com/pub/tummy/pynetcat

from socket import *
import sys

host = sys.argv[1]
port = int(sys.argv[2])

s = socket(AF_INET, SOCK_STREAM)
s.connect(( host, port ))

while 1:
   data = sys.stdin.read(4096)
   if not data:
      break
   s.send(data)
