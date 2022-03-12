#!/bin/bash
#desc:jk_upload && push to backup
#date :2017/3/15

/usr/bin/inotifywait -mrq /data/ --format "%w%f" -e moved_to,delete,create,close_write |while read line
do
   rsync -az /data/ --delete rsync_backup@172.16.1.41::backup --password-file=/etc/rsync.password
done