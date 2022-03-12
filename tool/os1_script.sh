#!/bin/sh
#---------------------------->
# File Name:	
# Version:1.1      
# Author:
# Organization:      
# Created Time :2017/3/23      
    
. /etc/init.d/functions
#Create a directory
function yh_dir (){
dir1="/server/scripts"
dir2="/server/tools"
mkdir -p $dir1
mkdir -p $dir2
}

#ssh optimize
function yh_ssh () {
    SSH_Port="port 888"
    SSH_ListenAddress=$(ifconfig eth0|awk -F "[ :]+" 'NR==2 {print $4}')
    SSH_PermitRootLogin="PermitRootLogin no"
    SSH_PermitEmptyPassword="PermitEmptyPasswords no"
    SSH_GSSAPI="GSSAPIAuthentication no"
    SSH_DNS="useDNS no"
	#更改端口号，生产环境使用
	#sed -i -e "13s/.*/$SSH_Port/g" /etc/ssh/sshd_config
	#sed -i -e "15s/.*/ListenAddress $SSH_ListenAddress/g" /etc/ssh/sshd_config
	#禁用root，生产环境打开这个参数
	#sed -i -e "42s/.*/$SSH_PermitRootLogin/g" /etc/ssh/sshd_config
	#sed -i -e "65s/.*/$SSH_PermitEmptyPassword/g" /etc/ssh/sshd_config
	sed -i -e "81s/.*/$SSH_GSSAPI/g" /etc/ssh/sshd_config
	sed -i -e "122s/.*/$SSH_DNS/g" /etc/ssh/sshd_config
}

#selinux optimize
function off_selinux (){
	if [ `getenforce` == Disabled ]
	then
	action "已经关闭的selinux" /bin/false
	else
	sed -i 's#SELINUX=.*#SELINUX=disabled#g' /etc/selinux/config &&\
    setenforce 0
	action "关闭selinux" /bin/true
	fi
}
off_selinux

#iptables
function stop_iptables (){
	/etc/init.d/iptables status >/dev/null 2>&1
	if [ $? -eq 3 ]
	then
	action "防火墙已经关闭" /bin/false
	else
	/etc/init.d/iptables stop >/dev/null 2>&1  
	chkconfig iptables off
	action "防火墙关闭" /bin/true
	fi
}
stop_iptables

#crond software optimize: time synchronization
function rsync_cron (){
	grep -i "#crond-id-001" /var/spool/cron/root >/dev/null 2>&1
	if [ $? -ne 0 ]
	then 
		echo '#time sync' >>/var/spool/cron/root
		echo '00 * * * * /usr/sbin/ntpdate pool.ntp.org >/dev/null 2>&1' >>/var/spool/cron/root
	fi
}
rsync_cron

#update yum info
function aliyun_yum (){
	rm -f /etc/yum.repo/*
	wget -q -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-6.repo
	wget -q -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-6.repo
	
}
aliyun_yum

function simplify_servvice () {
if [ `chkconfig |grep 3:on |wc -l` -eq 5 ]
then
action "已经优化的最小化服务" /bin/false
else
action "最小化服务" /bin/true
chkconfig |egrep -v "crond|sshd|network|rsyslog|sysstat" |awk '{print "chkconfig "$1 " off"}' |bash
fi
}
simplify_servvice

#History command optimization
function his_command () {
if [ `egrep "export HISTSIZE|export HISTFILESIZ" /etc/profile|wc -l ` -eq 2 ]
then
	action "已经优化过的历史命令" /bin/false
else
	echo 'export HISTSIZE=500' >>/etc/profile
	echo 'export HISTFILESIZE=500' >>/etc/profile
	source /etc/profile
	action "优化历史命令" /bin/true
fi 
}
his_command

#ssh time 
function conn_tmout () {
	grep "export TMOUT" /etc/profile >>/dev/null 2>&1
	if [ $? -eq 0 ]
	then
	action "已经优化过的连接超时" /bin/false
	else
	echo 'export TMOUT=50' >>/etc/profile
	source /etc/profile
	action "连接超时优化" /bin/true
fi
}
conn_tmout

#change profile file info
function terminal_color (){
	grep "PS1" /etc/profile >>/dev/null 2>&1
	if [ $? -ne 0 ]
	then
		echo  "PS1='\[\e[32;1m\][\u@\h \W]\\$ \[\e[0m\]'" >>/etc/profile
	fi
	grep "alias grep" /etc/profile >>/dev/null 2>&1
	if [ $? -ne 0 ]
	then
	echo "alias grep='grep --color=auto'" >>/etc/profile
	echo "alias ll='ls -l --color=auto --time-style=long-iso'" >>/etc/profile
	fi
	source /etc/profile
}

terminal_color
#kernel optimize
function yh_kernel () {
echo '*          -          nofile          65535' >>/etc/security/limits.conf
cat >>/etc/sysctl.conf <<EOF
net.ipv4.tcp_fin_timeout = 2
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_keepalive_time = 600
net.ipv4.ip_local_port_range = 4000    65000
net.ipv4.tcp_max_syn_backlog = 16384
net.ipv4.tcp_max_tw_buckets = 36000
net.ipv4.route.gc_timeout = 100
net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_synack_retries = 1
net.core.somaxconn = 16384
net.core.netdev_max_backlog = 16384
net.ipv4.tcp_max_orphans = 16384
net.nf_conntrack_max = 25000000
net.netfilter.nf_conntrack_max = 25000000
net.netfilter.nf_conntrack_tcp_timeout_established = 180
net.netfilter.nf_conntrack_tcp_timeout_time_wait = 120
net.netfilter.nf_conntrack_tcp_timeout_close_wait = 60
net.netfilter.nf_conntrack_tcp_timeout_fin_wait = 120
EOF
}
yh_kernel ()
