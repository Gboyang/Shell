#!/bin/sh
#
# 二进制包安装安装mysql 5.6.39
. /etc/init.d/functions
#---------------------------
mysql_dir=/application
mysql_user=mysql


function start_conf () {
	cp $mysql_dir/mysql/support-files/mysql.server  /etc/init.d/mysqld
	chmod +x /etc/init.d/mysqld
	sed -i "s#/usr/local/mysql#$mysql_dir/mysql#g" /etc/init.d/mysqld
	sed -i "s#/usr/local/mysql#$mysql_dir/mysql#g" /application/mysql/bin/mysqld_safe 
	\cp $mysql_dir/mysql/support-files/my-default.cnf /etc/my.cnf
	echo "PATH=$mysql_dir/mysql/bin/:$PATH" >>/etc/profile
	echo "安装成功........."
	echo '1、执行source /etc/profile'
	echo '2、启动mysql'
}

function mysql_initialize () {
	echo '开始initialize....................'
	$mysql_dir/mysql/scripts/mysql_install_db \
	--user=$mysql_user \
	--basedir=$mysql_dir/mysql \
	--datadir=$mysql_dir/mysql/data/
	if [ $? = 0 ];then
		echo 'initialize code 执行完毕.....'
		sleep 2
		start_conf
	else
		echo 'initialize mysql 失败'
	fi
}

function public () {
	package=$1
	if [ -f $1 ];then
		echo "$package下载成功.................."
		tar xf $package
		mkdir $mysql_dir
		find . -type d -name "mysql-5.6.39-*" -exec mv {} $mysql_dir/mysql-5.6.39 >/dev/null 2>&1 \;
		ln -s $mysql_dir/mysql-5.6.39 $mysql_dir/mysql
		useradd  $mysql_user  -M -s /sbin/nologin
		chown -R $mysql_user.$mysql_user $mysql_dir/mysql/*
		echo 'public code 执行完毕'
		sleep 2
		mysql_initialize
	else
		echo "$package下载失败"
	fi
}

function download () {
	echo '开始执行下载函数，请耐心等待。。。。。。。。。。。'
	if [ `uname -m` == 'x86_64' ];then
		wget -q http://mirrors.sohu.com/mysql/MySQL-5.6/mysql-5.6.39-linux-glibc2.12-x86_64.tar.gz
		public "mysql-5.6.39-linux-glibc2.12-x86_64.tar.gz"
	else
		wget -q http://mirrors.sohu.com/mysql/MySQL-5.6/mysql-5.6.39-linux-glibc2.12-i686.tar.gz
		public "mysql-5.6.39-linux-glibc2.12-i686.tar.gz"
	fi
}

if [ -f mysql-5.6.39-linux-glibc2.12-x86_64.tar.gz ];then
	public "mysql-5.6.39-linux-glibc2.12-x86_64.tar.gz"
elif [ -f mysql-5.6.39-linux-glibc2.12-i686.tar.gz  ];then
	public "mysql-5.6.39-linux-glibc2.12-i686.tar.gz"
else
	download
fi
