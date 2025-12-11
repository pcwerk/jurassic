#version=RHEL9
# AlmaLinux 9 Kickstart - Secure/NIST 800-171 oriented
# - HTTP install (BaseOS + AppStream from URL)
# - Interactive selection of Disk 1 and Disk 2 (sdX or nvmeXnY)
# - Encrypted LVM across both disks
# - localadmin (wheel) primary user
# - FIPS via kernel args
# - Cockpit + Podman (docker-compatible CLI)
#
# BEFORE USE:
#   1. Set HTTP repo URLs below (BaseOS + AppStream).
#   2. Change localadmin password (or use --iscrypted).
#   3. Add your SSH public key (search: YOUR-SSH-PUBLIC-KEY-HERE).
#   4. You will be prompted for:
#        - Disk 1 and Disk 2
#        - LUKS passphrase (no passphrase stored in this file).

###############################################################################
# PRE-SCRIPT: INTERACTIVE DISK SELECTION (disk1 + disk2)
###############################################################################
%pre --log=/tmp/ks-pre.log
#!/bin/sh

# Use TTY3 for interaction
exec < /dev/tty3 > /dev/tty3 2>&1
chvt 3

echo "=== Kickstart pre-script: disk selection ==="
echo
echo "Available disks (numbered):"

# List only real disks (no partitions, no loops)
# Format: N) /dev/sdX SIZE MODEL
i=0
lsblk -dpno NAME,SIZE,MODEL,TYPE | awk '$4=="disk"{print $1, $2, $3}' | while read NAME SIZE MODEL; do
    i=$((i+1))
    printf "%2d) %-20s %-8s %s\n" "$i" "$NAME" "$SIZE" "$MODEL"
done

# Recompute a plain list of disk device names (for lookup)
DISK_LIST=$(lsblk -dpno NAME,TYPE | awk '$2=="disk"{print $1}')

echo
echo "Enter number for FIRST disk (OS disk) from the list above:"
read DISK1_NUM
echo "Enter number for SECOND disk (extra PV) from the list above:"
read DISK2_NUM

# Grab the Nth and Mth disk names from DISK_LIST
DISK1=$(echo "$DISK_LIST" | sed -n "${DISK1_NUM}p")
DISK2=$(echo "$DISK_LIST" | sed -n "${DISK2_NUM}p")

if [ -z "$DISK1" ] || [ -z "$DISK2" ]; then
    echo "ERROR: Invalid disk selection. Aborting installation."
    sleep 5
    exit 1
fi

echo
echo "Using disks:"
echo "  DISK1 = $DISK1"
echo "  DISK2 = $DISK2"
echo

# Write dynamic partitioning fragment
cat > /tmp/part-include.ks << EOF
zerombr
clearpart --all --initlabel --drives=${DISK1},${DISK2}

part /boot --fstype="xfs" --size=1024 --ondisk=${DISK1}
part /boot/efi --fstype="efi" --size=600 --ondisk=${DISK1} --fsoptions="umask=0077,shortname=winnt"

# LUKS PVs (no passphrase specified -> installer prompts)
part pv.01 --fstype="lvmpv" --ondisk=${DISK1} --size=1 --grow --encrypted --luks-version=luks2
part pv.02 --fstype="lvmpv" --ondisk=${DISK2} --size=1 --grow --encrypted --luks-version=luks2
EOF

# Back to main TTY for normal installer UI
chvt 1
%end

###############################################################################
# INSTALLATION SOURCE: PURE HTTP (NO DVD)
###############################################################################

# BaseOS HTTP repo (CHANGE THIS to your HTTP mirror)
url --url="http://https://plug-mirror.rcac.purdue.edu/almalinux/9/BaseOS/x86_64/os"

# AppStream repo
repo --name="appstream" \
     --baseurl="http://https://plug-mirror.rcac.purdue.edu/almalinux/9/AppStream/x86_64/os"

###############################################################################
# LOCALIZATION
###############################################################################
lang en_US.UTF-8
keyboard us
timezone America/Los_Angeles --utc

###############################################################################
# USERS
###############################################################################
# Lock root; use localadmin (wheel) for sudo
rootpw --lock

# NOTE: Change this password or use --iscrypted for production
user --name=localadmin --groups=wheel --homedir=/home/localadmin --shell=/bin/bash \
     --password=changeme --plaintext

###############################################################################
# NETWORK
###############################################################################
# Use first NIC with link (eno1, ens18, etc.)
network --bootproto=dhcp --device=link --onboot=on --activate
network --hostname=almalinux9-secure.example.local

###############################################################################
# INSTALL MODE / SECURITY / BOOTLOADER
###############################################################################
text
skipx
firstboot --disable

selinux --enforcing
firewall --enabled --service=ssh --service=cockpit

# FIPS via kernel args ONLY (no 'fips' Kickstart command)
bootloader --append="quiet fips=1"

###############################################################################
# DISK LAYOUT (DRIVES COME FROM %pre)
###############################################################################
%include /tmp/part-include.ks

volgroup vgroot pv.01 pv.02

# LV layout as planned
logvol /              --fstype="xfs" --name=lv_root        --vgname=vgroot --size=32768
logvol /var           --fstype="xfs" --name=lv_var         --vgname=vgroot --size=16384 --fsoptions="nodev"
logvol /var/tmp       --fstype="xfs" --name=lv_vartmp      --vgname=vgroot --size=4096  --fsoptions="nodev,nosuid,noexec"
logvol /var/log       --fstype="xfs" --name=lv_varlog      --vgname=vgroot --size=8192  --fsoptions="nodev,nosuid,noexec"
logvol /var/log/audit --fstype="xfs" --name=lv_varlogaudit --vgname=vgroot --size=4096  --fsoptions="nodev,nosuid,noexec"
logvol /home          --fstype="xfs" --name=lv_home        --vgname=vgroot --size=8192  --fsoptions="nodev,nosuid"
logvol /tmp           --fstype="xfs" --name=lv_tmp         --vgname=vgroot --size=8192  --fsoptions="nodev,nosuid,noexec"
logvol swap           --fstype="swap" --name=lv_swap       --vgname=vgroot --size=8192

###############################################################################
# AUTH / SERVICES
###############################################################################
authselect select sssd with-sudo with-mkhomedir --force

services --enabled="sshd,chronyd,auditd,cockpit.socket"

reboot

###############################################################################
# OpenSCAP addon - NIST 800-171 CUI profile
###############################################################################
%addon org_fedora_oscap
    content-type = scap-security-guide
    profile = xccdf_org.ssgproject.content_profile_cui
%end

###############################################################################
# PACKAGES
###############################################################################
%packages --ignoremissing
@^minimal-environment
@standard
# Security and compliance
scap-security-guide
openscap-scanner
audit
aide
# Utilities
vim-enhanced
tmux
bash-completion
less
tar
rsync
curl
wget
net-tools
bind-utils
# Container and management
cockpit
cockpit-storaged
cockpit-podman
podman
podman-docker
containernetworking-plugins
# Remove unnecessary packages
-iwl*firmware
-plymouth
%end

###############################################################################
# POST-INSTALL HARDENING
###############################################################################
%post --log=/root/ks-post.log
set -e

# --- SUDO CONFIG ---
cat > /etc/sudoers.d/wheel << 'EOF'
## Allow wheel group members to run all commands with password
%wheel ALL=(ALL) ALL
EOF
chmod 440 /etc/sudoers.d/wheel
sed -i 's/^%wheel\s\+ALL=(ALL)\s\+NOPASSWD: ALL/# &/' /etc/sudoers 2>/dev/null || true

# --- SSH HARDENING ---
cat > /etc/ssh/sshd_config.d/99-hardening.conf << 'EOF'
PermitRootLogin no
PasswordAuthentication no
KbdInteractiveAuthentication no
X11Forwarding no
UseDNS no
MaxAuthTries 3
ClientAliveInterval 300
ClientAliveCountMax 2
LoginGraceTime 60
AllowGroups wheel
Ciphers aes256-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-gcm@openssh.com,aes128-ctr
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512,hmac-sha2-256
KexAlgorithms ecdh-sha2-nistp521,ecdh-sha2-nistp384,ecdh-sha2-nistp256,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512
EOF
chmod 600 /etc/ssh/sshd_config.d/99-hardening.conf

# --- localadmin SSH KEY ---
LOCALADMIN_SSH_KEY="YOUR-SSH-PUBLIC-KEY-HERE"
mkdir -p /home/localadmin/.ssh
chmod 700 /home/localadmin/.ssh
if [ "$LOCALADMIN_SSH_KEY" != "YOUR-SSH-PUBLIC-KEY-HERE" ]; then
    echo "$LOCALADMIN_SSH_KEY" > /home/localadmin/.ssh/authorized_keys
    chmod 600 /home/localadmin/.ssh/authorized_keys
    chown -R localadmin:localadmin /home/localadmin/.ssh
    restorecon -R /home/localadmin/.ssh || true
else
    echo "WARNING: No SSH key configured. Password auth is disabled - you may be locked out!" >> /root/ks-post.log
    sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config.d/99-hardening.conf
    echo "WARNING: Password authentication left enabled due to missing SSH key" >> /root/ks-post.log
fi

# --- AIDE INIT ---
cat > /etc/systemd/system/aide-init.service << 'EOF'
[Unit]
Description=Initialize AIDE database
ConditionPathExists=!/var/lib/aide/aide.db.gz
After=local-fs.target

[Service]
Type=oneshot
ExecStart=/usr/sbin/aide --init
ExecStartPost=/bin/mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
systemctl enable aide-init.service

# --- SYSCTL HARDENING ---
cat > /etc/sysctl.d/99-security.conf << 'EOF'
net.ipv4.ip_forward = 0
net.ipv6.conf.all.forwarding = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv6.conf.all.accept_source_route = 0
net.ipv4.conf.all.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.tcp_syncookies = 1
net.ipv4.conf.all.log_martians = 1
fs.suid_dumpable = 0
kernel.randomize_va_space = 2
kernel.dmesg_restrict = 1
kernel.kptr_restrict = 2
EOF

# --- LIMITS / PWQUALITY / UMASK ---
cat > /etc/security/limits.d/99-core.conf << 'EOF'
* hard core 0
EOF

cat > /etc/security/pwquality.conf.d/99-hardening.conf << 'EOF'
minlen = 15
dcredit = -1
ucredit = -1
lcredit = -1
ocredit = -1
minclass = 4
maxrepeat = 3
maxclassrepeat = 4
EOF

sed -i 's/^UMASK.*/UMASK 027/' /etc/login.defs

chmod 600 /etc/crontab
chmod 700 /etc/cron.d /etc/cron.daily /etc/cron.hourly /etc/cron.monthly /etc/cron.weekly
chmod 600 /boot/grub2/grub.cfg 2>/dev/null || true
chmod 600 /boot/efi/EFI/almalinux/grub.cfg 2>/dev/null || true

# --- CONTAINERS ---
mkdir -p /etc/containers
chmod 755 /etc/containers
systemctl enable podman.socket || true

# --- AUDIT RULES ---
cat > /etc/audit/rules.d/99-custom.rules << 'EOF'
-w /etc/sudoers -p wa -k sudoers
-w /etc/sudoers.d/ -p wa -k sudoers
-w /etc/ssh/sshd_config -p wa -k sshd_config
-w /etc/ssh/sshd_config.d/ -p wa -k sshd_config
-w /etc/passwd -p wa -k passwd_changes
-w /etc/shadow -p wa -k shadow_changes
-w /etc/group -p wa -k group_changes
-w /etc/gshadow -p wa -k gshadow_changes
-w /var/log/lastlog -p wa -k logins
-w /var/log/faillock -p wa -k logins
EOF

# --- FINAL UPDATE & CLEANUP ---
dnf update -y --security 2>/dev/null || true
dnf clean all
rm -rf /var/cache/dnf/*

echo "Post-installation hardening completed at $(date)" >> /root/ks-post.log
%end

%post --nochroot --log=/mnt/sysimage/root/ks-post-nochroot.log
echo "Kickstart installation completed at $(date)"
%end
