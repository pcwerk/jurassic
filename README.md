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

## Analyze

Once the data has been collected, we'd need to analyze for malware. The general approach for data analysis is based on chained processing flow:

1. Identify "known bads" by checking hash against blacklist
2. Eliminate "known "goods" by checking hash against whitelist
3. Tag potentially bad by checking filenames against blacklist 
4. Tag potentially bad by checking filenames not on the whitelist 
5. Manual review of remaining candidates from 1, 2, 3 and 4

#### `check_hash` program

The `check_hash` program is a fast C/C++ program that utilizes an `unordered_map` implementation to lookup known good or known bad artifacts.  It is capable of handling (for example, the NSRL database) 45 million hash entries in a couple of minutes.  Once loaded, the look up time is *< 1 sec* for each entry.

To compile the `check_hash` program, you'd need a C++ compiler and `make` program. On (almost all) Linux systems and OSX, just type `make` inside the `analyze` directory.  For OSX, make sure that XCode (with commandline tools) is installed.

### Known Bads 

There is no single recipe for obtaining known bads other that scouring the Internet for bad signatures.

Given two files `malware.txt` (a file containing all hash of know bad malwares) and `data.txt` which is the collected artifacts.

```bash
./check_hash bad malware.txt data.txt
```

The `check_hash` program will examine `data.txt` and report if any of its hashes are found in `malware.txt`

### Known Goods

The best source for known good hash can be obtained from the [NIST National Software Reference Library](http://www.nsrl.nist.gov/index.html).  Since the data provided on the ISO image from NSRL is large, we'd need to trim it down.

Unzip the file `NSRLFile.txt.zip` found in `RDS_Unified` ISO and extract the MD5 sum hash found in `NSRLFile.txt`:

```bash
cat NSRLFile.txt | \
  awk -F, 'NR>1{print $2}' | \
  sed -e s/\"//g | \
  tr '[:lower:]' '[:upper:]' | \
  sort | uniq > hash-sorted-by-md5.txt
```

Using `hash-sorted-by-md5.txt` as a reference file, we can tag/print those unconfirmed hashes (those not found in `hash-sorted-by-md5.txt`).

```bash
./check_hash good hash-sorted-by-md5.txt data.txt > unknown-hashes.txt
```

The file `unknown-hashes.txt` contains unconfirmed hashes and requires further investigation.

To obtain potentially known good filenames (note that this is the weakess claim in so far malware detection)

```bash
LC_ALL='C' cat NSRLFile.txt | \
  awk -F, 'NR>1{print $4}' | \
  sed -e 's/"//g' | \
  tr '[:lower:]' '[:upper:]' | \
  sort | uniq > filename-goods.txt 
```

* The `LC_ALL='C'` is to set the ENV variable `LC_ALL` so that `sed` won't choke on international filenames.  
* We now are interested in column 4, thus `$4` in the `awk` print 

The same technique can be applied to for identifying unrecognized files.  Again, we emphasize that this process supports an extremely weak claim and probably not worth doing.


## References

- https://cisofy.com/lynis
- https://github.com/pentestmonkey/unix-privesc-check
- http://www.nsrl.nist.gov/index.html
