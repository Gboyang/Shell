#!/bin/sh
#
# nfs services
# author:Gboyanghao@163.com
# --------------------------------
HOST_IP=${1:-"192.168.1.0"}/24
# NFS user
UNAME=${2:-"nfsdata"}
# --------------------------------
id $UNAME >/dev/null 2>&1
if [ $? != 0 ];then
	useradd -s /sbin/nologin -M $UNAME
fi
# --------------------------------
DIR=${3:-"/data"}
mkdir -p $DIR
chown -R $UNAME.$UNAME $DIR
# --------------------------------
# nfs permissions
# rw			可读可写
# ro			只读
# sync			同步，数据同步写到内存与硬盘中 
# async			异步，数据先暂存内存 
# root_squash	将root用户映射为来宾账号
# all_squash	全部映射为来宾账号 
# anonuid		指定映射的来宾账号的UID
# anongid		指定映射的来宾账号的GID
auth=rw,sync,all_squash,anonuid=$(id -u $UNAME),anongid=$(id -g $UNAME)
# ---------------------------------
# install nfs
if test `rpm -qa nfs-utils rpcbind|wc -l` -ne 2
	then
		yum install -y -q nfs-utils rpcbind
fi
# --------------------------------
# Creating configuration files
echo "#share $DIR------" >>/etc/exports
echo "$DIR $HOST_IP($auth)" >>/etc/exports
#----------------------------------
# rpcbind restart and start
rpc_cmd=/etc/init.d/rpcbind
nfs_cmd=/etc/init.d/nfs
# rpcbind
[ -f /var/run/rpcbind.pid ] && $rpc_cmd restart >/dev/null || $rpc_cmd start >/dev/null
# nfs
[ $(ps -ef|grep nfs|grep -v "grep nfs"|wc -l) -ne 0 ] && $nfs_cmd reload >/dev/null|| $nfs_cmd start >/dev/null
echo '脚本执行完成。。。。。。。。。。。。。。'