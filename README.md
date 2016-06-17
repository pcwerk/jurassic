# shells

This repository contains a series of tutorials designed to get users quickly up and running with shell programming and automation.  We will touch a number of areas, including **bash**, **perl**, **python**, etc.  To goal is to get something done quickly and not necessarily pretty.

## Finding Needles in a Haystack 

Consider a text file containing randomly scattered IP addresses, our objective is to count up the number of unique [Class C](https://en.wikipedia.org/wiki/IPv4_subnetting_reference) subnets.

```text
client 10.10.255.2 requests host1.domain.com
server responds domain.com 12.10.12.2
client 10.10.255.4 requests host2.domain.com
client 10.10.255.5 requests 10.10.255.3 10.10.255.4 10.10.10.12 
```
For a short text file, this can be done by hand.  However, for a large file, manual processing is not an option.  For this reason, we need to automate the process with scipts and native commands.

### The Linux Way

The idea is to chain the unix commands through a series of pipes.  A pipe is a concept that takes the output from one program and feed it into another program.

Let's first define the regular expression (or search pattern) for an IP address. This regex pattern is naive aas it searches four numeric octets and does not discrimate invalid ones, those with a value larger than 255.

```text
'([0-9]{1,3}\.){3}[0-9]{1,3}'
```

Using bash shell, we can quickly grab the IP addresses out from this text file.

```bash
cat README.md | egrep '([0-9]{1,3}\.){3}[0-9]{1,3}'
```

Note that the last line has multiple IP addresses.  So we would like to separate these and output each IP address into its own line.  Let's tackle this task with a simple python script.

```python
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
```

Now we can extract IPs from a text file (e.g. this `README.md` file) using to the `snarf_ip.py` script.

```bash
cat README.md | ./snarf_ip.py 
```

For Class C IP addresses, we need to grab only the first three octets using the `awk` command.

```bash
cat README.md  | \
  ./snarf_ip.py | \
  awk -F. '{print $1"."$2"."$3}' 
```

Next we want to sort and `uniq` the content and feed the output into a word counter `wc`.

```bash
cat README.md  | \
  ./snarf_ip.py | \
  awk -F. '{print $1"."$2"."$3}' | \
  sort | \
  uniq | \
  wc
```

Note that the `snarf_ip.py` script can be accomplished with the `grep` command and the `-o` option.

```bash
cat README.md | \
  egrep -o '([0-9]{1,3}\.){3}[0-9]{1,3}' \
  awk -F. '{print $1"."$2"."$3}' | \
  sort | \
  uniq | \
  wc
```
