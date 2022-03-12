#!/bin/sh
# 必须配合redis自带启动脚本一起使用
. /etc/init.d/functions

dir=/etc/redis
port="6379 6380 6381"
#---------------------------->
if [ $# -ne 1 ];then
	echo "please input {start|stop}"
fi
#---------------------------->
function main () {
for port in $port;
do	
	[ -f $dir/$port/redis ] && $dir/$port/redis $1 || echo "no $dir/$port/redis file"
done
}
case "$1" in
start)
     main 'start'
;;
stop)
     main 'stop'
;;
esac
