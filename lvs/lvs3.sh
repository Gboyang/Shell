#!/bin/sh
#
# lvs客户端配置的脚本

RETVAR=0
VIP=(
	10.0.0.3
	10.0.0.4
	)

. /etc/init.d/functions

case "$1" init
	start)
	for ((i=0; i<`echo ${#VIP[*]}`; i++))
	do
		interface="lo:`echo ${VIP[$i]}|awk -F . '{print $4}'`"
		/sbin/ip addr add ${VIP[$i]}/24 dev lo label $interface
		REVTAR=$?
	done
	echo "1" >/proc/sys/net/ipv4/conf/lo/arp_ignore
	echo "2" >/proc/sys/net/ipv4/conf/lo/arp_announce
	echo "1" >/proc/sys/net/ipv4/conf/all/arp_ignore
	echo "2" >/proc/sys/net/ipv4/conf/all/arp_announce
	if [ $RETVAR -eq 0 ];then
	action "Start LVS Config of Rearserver." /bin/true
	else
	action "Start LVS Config of Rearserver." /bin/false
	fi
	;;
	stop)
		for ((i=0; i<`echo ${#VIP[*]}`; i++))
		do
		interface="lo:`echo ${VIP[$i]}|awk -F . '{print $4}'`"
		/sbin/ip addr del ${VIP[$i]}/24 dev lo label $interface >/dev/null 2>&1
		done
			echo "0" >/proc/sys/net/ipv4/conf/lo/arp_ignore
			echo "0" >/proc/sys/net/ipv4/conf/lo/arp_announce
			echo "0" >/proc/sys/net/ipv4/conf/all/arp_ignore
			echo "0" >/proc/sys/net/ipv4/conf/all/arp_announce
			if [ $RETVAR -eq 0 ];then
				action "Close LVS Config of RearServer." /bin/true
			else
				action "Close LVS Config of RearServer." /bin/false
			fi
			;;
	*)
		echo "Usage: $0 {start|stop}"
		exit 1
	esac
exit $RETVAR