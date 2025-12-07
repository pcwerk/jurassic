# AlmaLinux 9 Kickstart - NIST 800-171-oriented, server, headless, 2 disks
# Adjust language, timezone, network, users, and partition sizes as needed.

# Install OS
install
cdrom

# Language and keyboard
lang en_US.UTF-8
keyboard us

# Time & NTP
timezone America/Los_Angeles --utc
services --enabled="chronyd"

# Root password (prefer to disable and only use sudo)
rootpw --lock

# Create an administrative user (set a strong password or use --iscrypted)
user --name=admin --groups=wheel --homedir=/home/admin --shell=/bin/bash --password=changeme --plaintext

# Networking (example: DHCP on first NIC)
network --bootproto=dhcp --device=eno1 --onboot=on --activate
# Hostname
network --hostname=almalinux9-secure.example.local

# Use text mode (headless)
text
skipx

# Do not configure X
firstboot --disable

# SELinux enforcing
selinux --enforcing

# Enable FIPS mode (expected for many 800-171 / STIG baselines)
fips --enabled

# Firewall - strict, only SSH + Cockpit
firewall --enabled --service=ssh,cockpit

# Bootloader on /dev/sda
bootloader --location=mbr --boot-drive=sda --append="quiet"

# Wipe and initialize disks
zerombr
clearpart --all --initlabel --drives=sda,sdb

# Basic disk layout with full-disk encryption on both disks.
# /dev/sda for OS; /dev/sdb joined into same encrypted VG for data.

# 1. Create encrypted physical volumes
# OS disk
part /boot --fstype="xfs" --size=1024 --ondisk=sda
part /boot/efi --fstype="efi" --size=600 --ondisk=sda --fsoptions="umask=0077,shortname=winnt"
part pv.01 --fstype="lvmpv" --size=1 --grow --ondisk=sda --encrypted --passphrase="CHANGEME-STRONG-PASSPHRASE" --luks-version=luks2

# Data disk, also encrypted, added to same VG
part pv.02 --fstype="lvmpv" --size=1 --grow --ondisk=sdb --encrypted --passphrase="CHANGEME-STRONG-PASSPHRASE" --luks-version=luks2

# 2. Volume group spanning both encrypted PVs
volgroup vgroot pv.01 pv.02

# 3. Logical volumes (adjust sizes as needed)
logvol /      --fstype="xfs" --name=lv_root  --vgname=vgroot --size=32768
logvol /var   --fstype="xfs" --name=lv_var   --vgname=vgroot --size=16384
logvol /home  --fstype="xfs" --name=lv_home  --vgname=vgroot --size=8192
logvol /tmp   --fstype="xfs" --name=lv_tmp   --vgname=vgroot --size=8192
logvol /var/log       --fstype="xfs" --name=lv_varlog      --vgname=vgroot --size=8192
logvol /var/log/audit --fstype="xfs" --name=lv_varlogaudit --vgname=vgroot --size=4096
logvol swap   --fstype="swap" --name=lv_swap --vgname=vgroot --size=8192

# System authorization
authselect --enableshadow --passalgo=sha512

# Services: keep minimal; cockpit/sshd/chronyd will be enabled below
services --enabled="sshd,chronyd" --disabled="postfix,rsyslog"

# Reboot after installation
reboot

# =====================================================================
#  SECURITY / COMPLIANCE ADDON: OpenSCAP NIST 800-171 profile
#  (Verify profile + paths with `oscap info`)
# =====================================================================
%addon org_fedora_oscap
    content-type = scap-security-guide
    profile = xccdf_org.ssgproject.content_profile_nist-800-171-cui
    content-url = /usr/share/xml/scap/ssg/content/ssg-almalinux9-ds.xml
    datastream-id = scap_org.open-scap_cref_ssg-almalinux9-ds.xml
    xccdf-id = xccdf_org.ssgproject.content_benchmark_AlmaLinux-9
%end

# =====================================================================
#  PACKAGE SELECTION
#  - Minimal base + OpenSCAP tools + common server utilities
#  - Cockpit, Podman, and docker-compatible CLI via podman-docker
# =====================================================================
%packages
@^minimal-environment
@standard

# Security / auditing / SCAP tools
scap-security-guide
openscap-scanner
audit
aide

# Admin basics
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

# Headless web management via Cockpit
cockpit
cockpit-storaged
# If available on Alma 9 repo, nice to have:
cockpit-podman

# Container tooling (docker-compatible via podman-docker)
podman
podman-docker
# Optional but often useful:
containernetworking-plugins

%end

# =====================================================================
#  POST-INSTALL HARDENING & SERVICE SETUP
# =====================================================================
%post --log=/root/ks-post.log

# Ensure wheel sudo requires password; lock down sudoers
if ! grep -qE '^%wheel' /etc/sudoers; then
    echo '%wheel ALL=(ALL) ALL' >> /etc/sudoers
else
    sed -i 's/^%wheel\s\+ALL=(ALL)\s\+NOPASSWD: ALL/# &/' /etc/sudoers
    sed -i 's/^#\s*%wheel\s\+ALL=(ALL)\s\+ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
fi

# SSH hardening (basic; SCAP profile will further tweak)
SSHD_CONFIG="/etc/ssh/sshd_config"
sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' "$SSHD_CONFIG"
sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' "$SSHD_CONFIG"
sed -i 's/^#\?ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no/' "$SSHD_CONFIG"
sed -i 's/^#\?X11Forwarding.*/X11Forwarding no/' "$SSHD_CONFIG"
sed -i 's/^#\?UseDNS.*/UseDNS no/' "$SSHD_CONFIG"

# Restrict SSH to wheel group only (optional)
if ! grep -q '^AllowGroups' "$SSHD_CONFIG"; then
    echo 'AllowGroups wheel' >> "$SSHD_CONFIG"
fi

# Enable key services

# SSHD for remote management
systemctl enable sshd

# Auditd
systemctl enable auditd

# Chrony
systemctl enable chronyd

# Cockpit (socket-activated web UI on port 9090)
systemctl enable cockpit.socket

# Podman / docker wrapper:
# podman-docker provides /usr/bin/docker as a wrapper to podman.
# No additional enablement needed here, but we can ensure a basic config directory.
mkdir -p /etc/containers
chmod 755 /etc/containers

%end
