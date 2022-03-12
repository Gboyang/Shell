#!/bin/bash
#
# author: gboyanghao@163.com
# description: uninstall script

SETCOLOR_FAILURE="echo -en \\033[1;31m"
SETCOLOR_NORMAL="echo -en \\033[0;39m"

echoError() {
	$SETCOLOR_FAILURE
	echo -n "$1"
	$SETCOLOR_NORMAL
	echo
	return 0
}

function uinstall () {
	server_name=$1
	if [ `rpm -qa|grep $server_name|wc -l` -ne 0 ];then
		echo "uninstall $server_name service............................"
		if [ $server_name = 'dhcp' ];then
			/usr/bin/yum -y -q remove dhcp*
			/usr/bin/rm -rf /etc/dhcp
		elif [ $server_name = 'xinetd' ];then
			/usr/bin/yum -y -q remove xinetd
			/usr/bin/rm -rf /etc/xinetd*
		elif [ $server_name = 'tftp-server' ];then
			/usr/bin/yum -y -q remove tftp-server
			/usr/bin/rm -rf /var/lib/tftpboot/
		elif [ $server_name = 'httpd' ];then
			/usr/bin/yum -y -q remove httpd
			/usr/bin/umount -f /var/www/html/open || /usr/bin/umount -f /var/www/html/CentOS 2>&1 >/dev/null
			/usr/bin/rm -rf /var/www
		else
			echoError 'ERROR: Is not supported'
		fi
	fi
}

service_list=(dhcp xinetd tftp-server httpd)
for server in ${service_list[*]};
do
	uinstall $server
done
