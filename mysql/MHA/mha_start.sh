#!/bin/sh
. /etc/init.d/functions 
#config file
conf=/etc/mha/mha.cnf
logs=/var/log/mha/mha/manager.log
#------------------------------->
if [ $# -ne 1 ];then
   echo "please input {status|start|stop|restart}"
fi
#------------------------------->
status=$(/bin/ps -ef |grep 'masterha_manager'|grep -v 'grep masterha_manager'|wc -l)
function mha_status () {
	if [ $status -ne 0 ];then
		echo 'MHA is running'
		else
		echo 'MHA no running'
	fi
}

function mha_start () {
	if [ $status -ne 0 ];then
		echo 'MHA is running'
		else
		nohup masterha_manager --conf=$conf > $logs 2>&1 &
	fi
}

function mha_stop () {
	if [ $status -ne 0 ];then
		PID=$(ps -ef |grep 'masterha_manager'|grep -v 'grep masterha_manager' |awk '{print $2}')
		/bin/kill $PID
		else
		echo 'MHA no running'
	fi
}

function mha_restart () {
	if [ $status -ne 0 ];then
		mha_stop
		mha_start
	else
		mha_start
	fi
}

case "$1" in
start)
     mha_start
;;
stop)
     mha_stop
;;
restart)
     mha_restart
;;
status)
     mha_status
;;
esac