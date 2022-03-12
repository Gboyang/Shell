#!/bin/bash
#
# ssh
password=123456

if [ ! -f ~/.ssh/id_rsa  ];then
	ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
fi
yum -y -q install sshpass
for ip in $*
do
	sshpass -p$password ssh-copy-id -i ~/.ssh/id_rsa.pub -o StrictHostKeyChecking=no root@$ip
done