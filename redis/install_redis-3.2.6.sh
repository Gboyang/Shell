#!/bin/sh
#
# redis intall shell
. /etc/init.d/functions
# installation path
port=6379
install_dir=/application
rd_server=$install_dir/redis/src/redis-server
rd_cli=$install_dir/redis/src/redis-cli
rd_pid=/var/run/redis_6379.pid
rd_conf=$install_dir/redis/redis.conf

function redis_config () {
	/bin/cp -a $install_dir/redis/utils/redis_init_script /etc/init.d/redis
	sed -i "s#REDISPORT=.*#REDISPORT=$port#g" /etc/init.d/redis
	#--------------------------------------------------------
	sed -i "s#EXEC=.*#EXEC=$rd_server#g" /etc/init.d/redis
	sed -i "s#CLIEXEC=.*#CLIEXEC=$rd_cli#g" /etc/init.d/redis
	#-------------------------------------------------------
	sed -i "s#PIDFILE=.*#PIDFILE=$rd_pid#g" /etc/init.d/redis
	sed -i "s#CONF=.*#CONF=$rd_conf#g" /etc/init.d/redis
	#-------------------------------------------------------
	sed -i 's#daemonize no#daemonize yes#g' $rd_conf
	/etc/init.d/redis start
	if [ $? = 0 ];then
		echo 'redis 启动成功'
	else
		echo 'redis 启动失败'
	fi
}

function redis_install () {
	/bin/tar xf redis-3.2.6.tar.gz
	/bin/mkdir $install_dir
	/bin/mv redis-3.2.6 $install_dir
	/bin/ln -s $install_dir/redis-3.2.6 $install_dir/redis
	cd $install_dir/redis
	if [ $(pwd) == $install_dir/redis ];then
		echo "开始make.............."
		/usr/bin/make -s
		if [ $? = 0 ];then
			redis_config
		else
			echo 'make 失败'
		fi
	else
		echo "Failed to enter directory"
	fi
}

if [ -f redis-3.2.6.tar.gz ];then
	redis_install
else
	wget -q  http://download.redis.io/releases/redis-3.2.6.tar.gz
	[ -f redis-3.2.6.tar.gz ] && redis_install
fi