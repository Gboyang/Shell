#!/bin/sh
#
# 启动并配置lvs服务

. /etc/init.d/functions
VIP=10.0.0.3
INTERFACE=eth0
SubINTERFACE=${INTERFACE}:`echo $VIP|cut -d. -f4`
PORT=80
GW=10.0.0.254
RETVAR=0

IP=/sbin/ip
ROUTE=/sbin/route
IPVSADM=/sbin/ipvsadm
ARPING=/sbin/arping

RIPS=(
	10.0.0.7
	10.0.0.8
	)

function usage () {
	echo "Usgae : $0 {start|stop|restart}"
	return 1
}

function ipvsStart () {
	$IP addr add $VIP/24 dev ${INTERFACE} label $SubINTERFACE
	$ROUTE add -host $VIP dev $SubINTERFACE
	$IPVSADM -C
	$IPVSADM -A -t $VIP:$PORT -s wrr -p 60
	for ((i=0; i<`echo ${#RIPS[*]}`; i++))
	do
	$IPVSADM -a -t $VIP:$PORT -r ${RIPS[$i]}:$PORT -g -w 1
	done
	RETVAR=$?
	$ARPING -c 1 -I ${INTERFACE} -s $VIP $GW &>/dev/null
	if [ $RETVAR -eq 0 ]
	then
	action "ipvsadm startted." /bin/true
	else
	action "ipvsadm startted." /bin/false
	fi
	return $RETVAR
}

main () {
if [ $# -ne 1 ];then
	usage $0
fi
case "$1" in 
	start)
	ipvsStart
	;;
	stop)
	ipvsStop
	;;
	restart)
	ipvsStop
	ipvsStart
	;;
	* )
	usage $0
	;;
	esac
}
main $*
	