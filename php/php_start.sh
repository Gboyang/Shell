#!/bin/bash
#------------------------------------------
# author   		:	mr.yang
# File Name		: 	start scripts
# Created Time	: 	2017/8/20
# Version  		: 	1.1.1
# describe 		: 	nginx start scripts
#------------------------------------------
. /etc/init.d/functions 
path=/application/php/sbin/php-fpm 
status=`lsof -i:9000|wc -l`
#------------------------------------------
if [ $# -ne 1 ];then
   echo "please input {status|start|stop|restart}"
fi
php_status(){
if [ $status -lt 3 ];then
   echo "php no running"
else
   echo "php is running"
fi
}
php_start(){
  $path
      if [ $? -ne 0 ];then
    action "php running error" /bin/false
      else
    action "php is running" /bin/true
      fi
}
php_stop(){
  pkill php-fpm
      if [ $? -ne 0 ];then
    action "php stop error" /bin/false
      else
    action "php is stop" /bin/true
      fi
}
case "$1" in
status)
   php_status
;;
start)
   php_start
;;
stop)
   php_stop
;;
restart)
   php_stop
   sleep 3
   php_start
;;
esac