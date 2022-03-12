#!/bin/sh
#
# rsync install
. /etc/init.d/functions
rsync_user=rsync
rsync_password=123456
backup_dir=/backup

yum -y install rsync
cat  >>/etc/rsyncd.conf <<EOF
uid = rsync
gid = rsync
use chroot = no
max connections = 200
timeout = 300
pid file = /var/run/rsyncd.pid
lock file = /var/run/rsync.lock
log file = /var/log/rsyncd.log
ignore errors
read only = false
list = false
hosts allow = 172.16.1.0/24
hosts deny = 0.0.0.0/32
auth users = rsync_backup
secrets file = /etc/rsync.password
[backup]
path = /backup/
[data]
path = /data/
EOF
useradd -s /sbin/nologin -M $rsync_user
mkdir -p $backup_dir
chown -R $rsync_user.$rsync_user /backup/
echo "rsync_backup:$rsync_password" >/etc/rsync.password
chmod 600 /etc/rsync.password
rsync --daemon
