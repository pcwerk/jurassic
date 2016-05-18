# Jurassic

Jurassic is a suite of tools and tutorials -- it is not a one stop shop for artifact collection.

## System Check

To check for unix system vulnerabilities, we recommend using 

* [lynis](https://cisofy.com/lynis/)
* [unix-privesc-check](https://github.com/pentestmonkey/unix-privesc-check)

Both of these are formidable tool sets and both of are freely available.

When doing an analysis on any systems, it's important to ensure that actions do not negatively affect the system in review.  While this is a noble goal, it's not always a realistic goal.  To deconflict who/how in the aftermath, we recommend using the [script](http://www.computerhope.com/unix/uscript.htm) command.

## Collect

The data collection tools can be found in the [collect](collect) folder.

### Capture System Artifacts

In addition to the above tool sets, we provide here a few portable shell scripts that performs rudimentary artifact capture.  For each of the scripts, the main control file is `config`.  Note that default values can be used as-is; and if needed customization is recommended for specific projects and system and should only be made in the `config` and `config.$OS` files.

There are three artifact capture scripts:

* `snap_network.sh` captures the network artifacts
* `snap_basic.sh` captures miscellanous files, include user information and log files
* `snap_hash.sh` hash the files found in the `$HASH_DIRS` which is defined in `config`

Note that the `snap_hash.sh` can take a long time depending on the number of files and the file size.

#### Capture Running Processes

The program `log_process.sh` is a continuously running script that periodically snaps running processes and save the result in a file in the `$OUTDIR/$hostname/processes` directory.  It creates an index file and in this file, it lists timestamps and filenames of captured processes.

To capture running processes, start the script in a separate window.  The script will run continuously until stopped with `ctrl-c` or `kill -9 PID`. 

```bash
./log_process.sh
```

Because `log_process.sh`  runs continuously, we recommend that it is executed in a [screen](http://www.computerhope.com/unix/screen.htm) session.  If you are not familiar with `screen`, it's a simple builin-in (for most *nix systems) that lets users create, attach and detach from virtual terminals as neeeded.


### Data Collection Package

Once the data collection period is over, the entire data collection artifacts can be packaged together into a single package with the `data_packakge.sh` script. Its usage is simple:

```bash
./data_package.sh 
```

A package `$hostname.tar.gz` will be created.  This file can be copied back into a central repository for analysis at a later time.

## Analyze Collected Hashes

Once the data has been collected, we'd need to analyze for malware. The general approach for data analysis is based on chained processing flow:

1. Identify malware by checking hashes against a blacklist
2. Eliminate known goods by checking hashes against whitelist
3. The remaining hashes from 1 and 2 are now considered unknowns
4. Review files associated with hashes from 3
5. Submit remaining hashes against online sites

### Automated Tool: `check_hash`

The `check_hash` program is a fast C/C++ program that utilizes an `unordered_map` implementation to lookup known good or known bad artifacts.  It is capable of handling (for example, the NSRL database) 45 million hash entries in a couple of minutes.  Once loaded, the look up time is *< 1 sec* for each entry.

To compile the `check_hash` program, you'd need a C++ compiler and `make` program. On (almost all) Linux systems and OSX, just type `make` inside the `analyze` directory.  For OSX, make sure that XCode (with commandline tools) is installed.

```bash
cd analyze
make
```

This will generate the `check_hash` program which now can be used to analyze large hash contents.

### Known Bad Hashes

There is no single recipe for obtaining known bads other that scouring the Internet for bad signatures.

Given two files `malware.txt` (a file containing all hash of know bad malwares) and `data.txt` which is the collected artifacts.

```bash
./check_hash bad malware.txt data.txt data.txt.unkown data.txt.bad
```

The `check_hash` program will examine `data.txt` and report if any of its hashes are found in `malware.txt`  It generates two files:

* `data.txt.bad` which is a hash file that *definitely* contains evil hashes (based on the `malware.txt`)
* `data.txt.unknown` which is a hash file that contains undetermined contents

### Known Good Hashes

The best source for known goods can be obtained from the [NIST National Software Reference Library](http://www.nsrl.nist.gov/index.html).  Since the data provided on the ISO image from NSRL database is large, we'd need to trim it down.

Unzip the file `NSRLFile.txt.zip` found in `RDS_Unified` ISO. The MD5 hashes are embedded in file `NSRLFile.txt`:

```bash
cat NSRLFile.txt | \
  awk -F, 'NR>1{print $2}' | \
  sed -e s/\"//g | \
  tr '[:lower:]' '[:upper:]' | \
  sort | uniq > hash-sorted-by-md5.txt
```

Using `hash-sorted-by-md5.txt` as a reference file, we can tag/print those unconfirmed hashes (those not found in `hash-sorted-by-md5.txt`).

```bash
./check_hash good hash-sorted-by-md5.txt data.txt data.txt.unknown data.txt.good
```

When running the above command it generates two files:

* `data.txt.good` which is a hash file that *definitely* contains good hashes (based on the `hash-sorted-by-md5.txt`)
* `data.txt.unknown` which is a hash file that contains undetermined contents

### Filename Analysis

To obtain potentially known good filenames.  We emphasize that this process supports an extremely weak claim and is probably not worth doing.  That being said, the same technique can be applied to for identifying unrecognized files.  

```bash
LC_ALL='C' cat NSRLFile.txt | \
  awk -F, 'NR>1{print $4}' | \
  sed -e 's/"//g' | \
  tr '[:lower:]' '[:upper:]' | \
  sort | uniq > filename-goods.txt 
```

* The `LC_ALL='C'` is to set the ENV variable `LC_ALL` so that `sed` won't choke on international filenames.  
* We now are interested in column 4, thus `$4` in the `awk` print 
* `filename-goods.txt` is a messy text file that contains one filename per line and would need to be cleaned up somemore before being useful
* `check_hash.cpp` would have to be modified to support entries with spaces in between words


## References

- https://cisofy.com/lynis
- https://github.com/pentestmonkey/unix-privesc-check
- http://www.nsrl.nist.gov/index.html
