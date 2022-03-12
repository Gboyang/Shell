#!/bin/bash
#
# author: gboyanghao@163.com
# description: The entrance to the script
scpath="`dirname $0`"
curpath="`cd $scpath;pwd`"

# color 
SETCOLOR_FAILURE="echo -en \\033[1;31m"
SETCOLOR_NORMAL="echo -en \\033[0;39m"

echoError() {
	$SETCOLOR_FAILURE
	echo -n "$1"
	$SETCOLOR_NORMAL
	echo
	return 0
}

[ `uname -m` = 'aarch64' ] || exit
if [ ! -f /etc/system-release ];then
	echoError 'ERROR: The system type cannot be determined'
	exit
fi

sy_release=$(awk '{print $1}' /etc/system-release)
if [ $sy_release = 'CentOS' ];then
	cd $curpath/bin/ && ./CentOS_install.sh
	# . $curpath/bin/CentOS_install.sh
	
elif [ $sy_release = 'openEuler' ];then
	cd $curpath/bin/ && ./openEuler_install.sh
	# . $curpath/bin/openEuler_install.sh
	
else
	echoError 'ERROR: Unsupported version'
	exit
fi
