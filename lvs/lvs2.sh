#!/bin/bash
#

IPVSADM=/sbin/ipvsadm
VIP=10.0.0.3
PORT=80
RIPS=(
10.0.0.7
10.0.0.8
)
while true
do
	for((i=0;i<${#RIPS[*]};i++))
	do
	PORT_COUNT=`nmap ${RIPS[$i]} -P $RIPS|grep open |wc -l`
	if [ $PORT_COUNT -ne 1 ];then
		if [ `$IPVSADM -Ln|grep ${RIPS[$i]}|wc -l` -ne 0 ];then
		$IPVSADM -d -t $VIP:$PORT -r ${RIPS[$i]}:$PORT >/dev/null 2>&1
		fi
	else
		if [ `$IPVSADM -Ln|grep ${RIPS[$i]}|wc -l` -eq 0 ];then
		$IPVSADM -a -t $VIP:$PORT -r ${RIPS[$i]}:$PORT >/dev/null 2>&1
		fi
	fi
	done
	sleep 5
done
