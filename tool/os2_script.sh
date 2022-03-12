#!/bin/bash
# author: Gboyanghao@163.com
# date: 2021-03-11
# env : CentOS 7
# description: 本脚本用于初次安装完系统后，对系统进行一个初步的优化
# ------------------------------>
. /etc/init.d/functions

function off_selinux () {
	# 关闭Selinux
	if [ $(getenforce) != 'Disabled' ];
	then
		setenforce 0
		sed -i 's#SELINUX=.*#SELINUX=disabled#g' /etc/selinux/config
	fi
}
off_selinux

function set_iptables () {
	# 针对防火墙设置一些策略
	iptables -F
	iptables -X
	iptables -Z
	iptables -P INPUT DROP
	iptables -P OUTPUT ACCEPT
	iptables -P FORWARD DROP
	iptables -A INPUT -p tcp --dport 22 -j ACCEPT
}
set_iptables

function sync_time () {
	# 同步服务器时间
	grep -i "#crond-id-001" /var/spool/cron/root >/dev/null 2>&1
	if [ $? -ne 0 ]
	then 
		echo '#time sync' >>/var/spool/cron/root
		echo '* * 00 * * /usr/sbin/ntpdate pool.ntp.org >/dev/null 2>&1' >>/var/spool/cron/root
	fi
}
sync_time

function rsync_aliyu () {
	# 同步阿里yum源
	wget -q -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
	wget -q -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
	yum clean all
	yum makecache
}
rsync_aliyu

function history_command () {
	# 保留历史命令， 这里最多保留500条
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
history_command

function conn_timeout () {
	# 长时间不操作自动退出ssh连接
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
conn_timeout

function color_terminal () {
	# 
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
color_terminal

function file_descriptor () {
	# 调整默认文件描述符
	echo '*          -          nofile          65535' >>/etc/security/limits.conf
}
file_descriptor

function ssh_opt () {
	# 修改ssh 默认端口
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
	#sed -i -e "81s/.*/$SSH_GSSAPI/g" /etc/ssh/sshd_config
	#sed -i -e "122s/.*/$SSH_DNS/g" /etc/ssh/sshd_config
}
ssh_opt

function kernel_args () {
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
kernel_args