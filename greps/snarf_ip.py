#!/usr/bin/env python

import sys  # module for system i/o
import re   # module for regular expression

# regular expression string
ip_regex = '(?:[0-9]{1,3}\.){3}[0-9]{1,3}'

# for each line find all ips 
for line in sys.stdin:
   matches = re.findall(ip_regex, line)
   for match in matches:
     print match
