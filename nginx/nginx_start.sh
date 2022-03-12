#!/bin/bash
#------------------------------------------
# author   		:
# File Name		: 	start scripts
# Created Time	: 	2017/8/20
# Version  		: 	1.1.1
# describe 		: 	nginx start scripts
#------------------------------------------
. /etc/init.d/functions 
path=/application/nginx/sbin/nginx
#------------------------------------------>
if [ $# -ne 1 ];then
   echo "please input {status|start|stop|restart|reload}"
fi
#------------------------------------------>
nginx_status(){
status=`lsof -i:80|wc -l`
if [ $status -gt 2 ];then
   echo "nginx is running " 
   else
   echo  "nginx no running" 
fi
}
nginx_start(){
  $path
  if [ $? -eq 0 ];then
     action "nginx start" /bin/true
  else
     action "nginx no start" /bin/false
  fi
}
nginx_stop(){
  $path -s stop
  if [ $? -eq 0 ];then
     action "nginx stop" /bin/true
  else
     action "nginx no stop" /bin/false
  fi
}
nginx_restart(){
  $path -s stop
  if [ $? -eq 0 ];then
     action "nginx stop" /bin/true
  else
     action "nginx no stop" /bin/false
  fi
  sleep 3
  $path
  if [ $? -eq 0 ];then
     action "nginx start" /bin/true
  else
     action "nginx no start" /bin/false
  fi
}
nginx_reload(){
  $path -s reload
  if [ $? -eq 0 ];then
     action "nginx reload" /bin/true
  else
     action "nginx no reload" /bin/false
  fi
}
case "$1" in
start)
     nginx_start
;;
stop)
     nginx_stop
;;
restart)
     nginx_restart
;;
reload)
     nginx_reload
;;
status)
     nginx_status
;;
esac
