#!/bin/bash
#
# author: Gboyanghao@163.com

#----------------------------------------
export scpath="`dirname $0`"

# load script
. $scpath/log_format.sh
# host ip address
host_ip=(
'192.168.1.10'
'192.168.1.11'
'192.168.1.12'
'192.168.1.13'
)
# host password
host_pw=123456

if [ ! -f ~/.ssh/id_rsa  ];then
	ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
fi
yum -y -q install sshpass
for ip in ${host_ip[*]}
do
	sshpass -p$host_pw ssh-copy-id -i /root/.ssh/id_rsa.pub "-o StrictHostKeyChecking=no" root@$ip 2>&1 >/dev/null
	if [ $? = 0 ];then
		infolog 'ssh Mutual trust is successful'
	else
		errorlog 'ssh Mutual trust is fail'
		exit 1
	fi
done
