#!/usr/bin/env python

import sys

# create an empty table
data_table = dict()

# read in one line at a time from stdin
for line in sys.stdin:
   src, dest, port = line.split()   # break each line into three values

   if data_table.has_key(port):     # check if port exist in data_table
      if not data_table[port].has_key(dest): # check to see if dest is defined
         data_table[port][dest] = set()
   else:
      data_table[port] = dict()      # create a new port table
      data_table[port][dest] = set() # create a new dest set

   data_table[port][dest].add(src)   # add port, src, dest to data_table

# iteratest through and print the data_table
for port in data_table:
   print port
   for dest in data_table[port]:
      print "  ", dest
      for src in data_table[port][dest]:
         print "    ", src
