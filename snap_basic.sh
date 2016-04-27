#!/bin/sh

source "./config"

if [ -z $OUTDIR ] ; then
  OUTDIR=.
fi

## setup
OUT=${OUTDIR}/basic
mkdir -p ${OUT}

## capture basic information
ps -axjf >> $OUT/List_of_Running_Processes.txt
pstree -ah >> $OUT/Process_tree_and_arguments.txt
mount >> $OUT/Mounted_items.txt
diskutil list >> $OUT/BasicInfo/Disk_utility.txt
uptime >> $OUT/System_uptime.txt
printenv >> $OUT/System_environment_detailed.txt
cat /proc/version >> $OUT/OS_kernel_version.txt
top -n 1 -b >> $OUT/Process_memory_usage.txt
df -h >> $OUT/Disk_usage.txt
hostname >> $OUT/hostname.txt
date >> $OUT/date.txt
uname -a >> $OUT/System_environment.txt
lsof >> $OUT/Open_Files.txt
find / -type d -perm -1000 -exec ls -ld {} \; >> $OUT/World_Writable.txt
lsmod >> $OUT/Loaded_modules.txt
chkconfig --list >> $OUT/chkconfig.txt
service --status-all >> $OUT/Running_services.txt


