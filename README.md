# shells

Let us assume a simple data file which contains IP addresses scattered throughout the document.  Our goal is to determine count the number of class B and class C IP addresses in the text file.

```text
client 10.10.255.2 requests host1.domain.com
server responds domain.com 12.10.12.2
client 10.10.255.4 requests host2.domain.com
client 10.10.255.5 requests 10.10.255.3 10.10.255.4 10.10.10.12 
```

The regular expression for IP address is:

```text
'([0-9]{1,3}\.){3}[0-9]{1,3}'
```

Using bash shell, we can quickly see grab the IP addresses out from this text file.

```bash
cat README.md | egrep '([0-9]{1,3}\.){3}[0-9]{1,3}'
```

Note that the last line has multiple IP addresses.  So we would like to separate these and output each ip address into its own line.  Let's tackle this task with a simple python script.

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

Now we can extract IPs from the data file by feeding (by wipe of a pipe) the content of a text file (e.g. this `README.md` file) to the `snarf_ip.py` script.

```bash
cat README.md | ./snarf_ip.py 
```

For class C IP addresses, we need to grab only the first three octets using the `awk` command.

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

