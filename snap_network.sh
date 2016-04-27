#!/bin/sh

source "./config"

if [ -z $OUTDIR ] ; then
  OUTDIR=.
fi

## setup
OUT=${OUTDIR}/network
mkdir -p ${OUT}

## capture network informations
lsof -i -n -P >> $OUT/lsof_network_connections.txt
ifconfig -a >> $OUT/Network_interface_info.tx
netstat -plantu >> $OUT/netstat_current_connections.txt
cat /etc/resolv.conf >> $OUT/DNS.txt
arp -an >> $OUT/ARP_table.txt
netstat -rn >> $OUT/Routing_table.txt
ip link | grep PROMISC >> $OUT/PROMISC_adapter_check.txt
iptables-save  >> $OUT/Firewall.txt
cat /etc/hosts.allow >> $OUT/Hosts_allow.txt
cat /etc/hosts.deny >> $OUT/Hosts_deny.txt
