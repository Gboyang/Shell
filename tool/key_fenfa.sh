#!/bin/sh
#
#Distribute the public key 
host_ip='
192.168.1.10
192.168.1.30
192.168.1.40
'
host_password=123456

ssh-keygen -t dsa -f ~/.ssh/id_dsa -P ""
[ `rpm -qa sshpass|wc -l` == 1 ] || yum -y install sshpass 
for host in $host_ip;
do
	sshpass -p$host_password ssh-copy-id -i /root/.ssh/id_dsa.pub "-o StrictHostKeyChecking=no root@$host"
done
