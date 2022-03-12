#!/bin/sh
#
#fenfa pub to hosts
for ip in $*
do
	sshpass -phao@123 ssh-copy-id -i /root/.ssh/id_dsa.pub "-o StrictHostKeyChecking=no" root@$ip

done
echo $0
