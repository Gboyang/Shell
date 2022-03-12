#!/bin/bash
#
# Author: yanghao
# Email: Gboyanghao@163.com
# Version: 0.0.1
# Describe: This is the batch RAID configuration script
# Environment: 针对3108RAID卡进行操作，其他版本RAID卡兼容问题尚未可知

BMC_USER=ADMIN
BMC_PASS=ADMIN

scpath="`dirname $0`"
curpath="`cd $scpath;pwd`"
ip_file=$curpath/ip.txt


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

PARA_JSON01='{
	"ControllerId":0, 
	"Raid": "RAID5", 
	"Span": 2, 
	"PhysicalDrives":[
		"HA-RAID.0.Disk.3", 
		"HA-RAID.0.Disk.5", 
		"HA-RAID.0.Disk.7",
		"HA-RAID.0.Disk.11"
		], 
	"UsePercentage":100, 
	"LogicalDriveCount":1, 
	"StripSizePerDDF":"256K",
	"LdReadPolicy":"AlwaysReadAhead", 
	"LdWritePolicy":"WriteBack", 
	"LdIOPolicy":"DirectIO", 
	"AccessPolicy":"ReadWrite", 
	"DiskCachePolicy":"Unchanged", 
	"InitState":"QuickInit"
	}'
	
if [ ! -f $ip_file ];then
	echoError "$ip_file does not exist"
	exit 1
fi


for ip_addr in $(cat $ip_file);
do
	curl -X POST -H 'Content-Type':'application/json' -d  "$PARA_JSON01" -u $BMC_USER:$BMC_PASS https://$(ip_addr)/redfish/v1/Systems/1/Storages/HA-RAID/Actions/Oem/Storage.CreateVolume -k
	if [ $? = 0 ];then
		echo 'Succeeded in delivering a task'
	else
		echoError 'Failed to deliver a task'
	fi
done
