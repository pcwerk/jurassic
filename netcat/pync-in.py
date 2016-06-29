#!/usr/bin/env python

#  source ftp://ftp.tummy.com/pub/tummy/pynetcat

from socket import *
import sys

port = int(sys.argv[1])
s = socket(AF_INET, SOCK_STREAM)
s.bind(( '', port) )
s.listen(1)

conn, addr = s.accept()

while 1:
  data = conn.recv(4096)
  if not data:
    break
  sys.stdout.write(data)
