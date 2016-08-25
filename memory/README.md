# How to dump memory on linux

There are several ways to dump memory.  The simplest and easiest is to use the GNU's `gcore` program. 

```bash
gcore $pid
```

This will create a file: `core.<pid>`.  You can then extract information from the file using a combination of `strings` and `grep`.

The second way is to use a wrapper script `dump-all-memory.sh` which requires the `gdb` debugger.  Note that `gdb` is not always available, so this cript might not work.

```bash
./dump-all-memory.sh $pid
```

Note that this script is messy and should be executed in it's own directory.

Finally, using a python script `memory-dump.py` which can be executed as followed:

```bash
./memory-dump.py $pid > $pid.mem
```


