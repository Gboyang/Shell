#!/bin/bash
############################ipmi###################################### 
insmod /lib/modules/3.10.0-1160.el7.x86_64/kernel/drivers/char/ipmi/ipmi_msghandler.ko.xz
insmod /lib/modules/3.10.0-1160.el7.x86_64/kernel/drivers/char/ipmi/ipmi_si.ko.xz
insmod /lib/modules/3.10.0-1160.el7.x86_64/kernel/drivers/char/ipmi/ipmi_devintf.ko.xz
/sbin/modprobe ipmi_devintf
/sbin/modprobe ipmi_si
/sbin/modprobe ipmi_msghandler
##########################读取IPMI地址####################
ipmi_addr=`ipmitool lan print 1 | grep "IP Address\ *:" | cut -d':' -f2`


##################读取参数值#################
cat list.txt |grep $ipmi_addr >/dev/null
if [ $? -eq 0 ];then
    hostname=`cat list.txt |grep $ipmi_addr |awk '{print$1}'`
    bond0_ip=`cat list.txt |grep $ipmi_addr |awk '{print$3}'`
    bond0_gateway=10.242.51.126
    bond1_ip=`cat list.txt |grep $ipmi_addr |awk '{print$4}'`
    bond1_gateway=172.88.254.254
fi

#####################hostname################
hostnamectl set-hostname --static $hostname
echo HOSTNAME=$hostname >> /etc/sysconfig/network

##################### NetworkManager###########
systemctl start NetworkManager

################Bond0#######业务#############
nmcli conn delete enp175s0f0
nmcli conn delete enp175s0f1
nmcli conn add con-name bond0 type bond ifname bond0 ipv4.address $bond0_ip/24 ipv4.gateway $bond0_gateway mode 802.3ad miimon 100
nmcli conn add con-name enp175s0f0 type bond-slave ifname enp175s0f0 master bond0
nmcli conn add con-name enp175s0f1 type bond-slave ifname enp175s0f1 master bond0

############Bond1######资源池互通###########
nmcli conn delete enp59s0f0
nmcli conn delete enp59s0f1
nmcli conn add con-name bond1 type bond ifname bond1 ipv4.address $bond1_ip/24 ipv4.gateway $bond1_gateway mode 802.3ad miimon 100
nmcli conn add con-name enp59s0f0 type bond-slave ifname enp59s0f0 master bond1
nmcli conn add con-name enp59s0f1 type bond-slave ifname enp59s0f1 master bond1

############Bond2######管理############
#nmcli conn delete eno1
#nmcli conn delete eno2
#nmcli conn add con-name bond2 type bond ifname bond2 ipv4.address $bond2_ip/24 ipv4.gateway $bond2_gateway mode 1 miimon 100
#nmcli conn add con-name eno1 type bond-slave ifname eno1 master bond2
#nmcli conn add con-name eno2 type bond-slave ifname eno2 master bond2

sed -i 's/dhcp/static/g' /etc/sysconfig/network-scripts/ifcfg-bond0
sed -i 's/dhcp/static/g' /etc/sysconfig/network-scripts/ifcfg-bond1
#sed -i 's/dhcp/static/g' /etc/sysconfig/network-scripts/ifcfg-bond2
cat /etc/sysconfig/network-scripts/ifcfg-bond* | grep BOOTPROTO
sleep 3

sed -i 's/miimon=100 mode=802.3ad/miimon=100 mode=802.3ad lacp_rate=1 xmit_hash_policy=layer3+4 updelay=100 downdelay=100/g' /etc/sysconfig/network-scripts/ifcfg-bond0
sed -i 's/miimon=100 mode=802.3ad/miimon=100 mode=802.3ad lacp_rate=1 xmit_hash_policy=layer3+4 updelay=100 downdelay=100/g' /etc/sysconfig/network-scripts/ifcfg-bond1


systemctl stop firewalld
systemctl disable firewalld

systemctl restart network

systemctl disable NetworkManager
systemctl restart network


cat /etc/hostname

#看一下速率是不是20000
#ethtool bond0 | grep -i speed
#ethtool bond1 | grep -i speed

#最后
#reboot
