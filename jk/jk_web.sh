#!/bin/sh
#
# 监控web站点目录（/var/html/www）下所有文件是否被恶意篡改
html_dir=/var/html/www
html_file=`find /var/html/www -type f`
check_dir=/tmp/checkdir

[ ! -d $check_dir ] && mkdir $check_dir
for n in $html_file
do
  md5sum $n >>$check_dir/1.txt
done

while true
do
  md5sum -c $check_dir/1.txt|grep FAILED >>$check_dir/2.txt
  [ -s $check_dir/2.txt ] && \
  echo "`cat $check_dir/2.txt`"|mail -s "date:`date +%F-%H:%M:%S` Web is dangerous" Gboyanghao@163.com
  >$check_dir/2.txt
sleep 3
done