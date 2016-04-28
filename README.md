# Jurassic

Jurassic is a suite of tools and tutorials -- it is not a one stop shop for artifact collection.

## System Check

To check for unix system vulnerabilities, we recommend using 

  * [lynis](https://cisofy.com/lynis/)
  * [unix-privesc-check](https://github.com/pentestmonkey/unix-privesc-check)

Both of these are formidable tool sets and both of are freely available.

When doing an analysis on any systems, it's important to ensure that actions do not negatively affect the system in review.  While this is a noble goal, it's not always a realistic goal.  To deconflict who/how in the aftermath, we recommend using the [script](http://www.computerhope.com/unix/uscript.htm) command.

## Capture System Artifacts

In addition to the above tool sets, we provide here a few portable shell scripts that performs rudimentary artifact capture.  For each of the scripts, the main control file is `config`.  Note that default values can be used as-is; and if needed customization is recommended for specific projects and system and should only be made in the `config` and `config.$OS` files.

There are three artifact capture scripts:

* `snap_network.sh` captures the network artifacts
* `snap_basic.sh` captures miscellanous files, include user information and log files
* `snap_hash.sh` hash the files found in the `$HASH_DIRS` which is defined in `config`

Note that the `snap_hash.sh` can take a long time depending on the number of files and the file size.

### Capture Running Processes

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

### References

- https://cisofy.com/lynis
- https://github.com/pentestmonkey/unix-privesc-check
