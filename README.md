# jurassic
A suite of tools to collect *nix artifacts

# System Check

To check for potential *nix system vulnerability, there are two formidable tool sets: lynis [1] and unix-privesc-check [2].  Both of are freely available.

# Capturing Artifacts

### Capture running processes

To capture running processes:

```bash
./processlog.sh
```

Log files are written to `OUTDIR` in `config`.  This value can be overwritten.


- [1] https://cisofy.com/lynis/
- [2] https://github.com/pentestmonkey/unix-privesc-check
