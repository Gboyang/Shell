#!/bin/bash
#
# install redis-2.2.7
root_dir=/application
port=6379


rm -rf redis-2.2.7*
wget -q http://download.redis.io/releases/redis-2.2.7.tar.gz
if [ ! -f redis-2.2.7.tar.gz ];then
	exit 2
fi
mkdir -p $root_dir
tar xf redis-2.2.7.tar.gz -C $root_dir
if [ -e $root_dir/redis-2.2.7 ];then
	ln -s $root_dir/redis-2.2.7 $root_dir/redis
	cd $root_dir/redis
	if [ `pwd` != $root_dir/redis ];then
		exit 3
	fi
	make -s
	if [ $? == 0 ];then
		echo '安装成功'
	fi
	cp -a ./utils/redis_init_script /etc/init.d/redis
	sed -i "s#REDISPORT=.*#REDISPORT=$port#g" /etc/init.d/redis
	sed -i "s#EXEC=.*#EXEC=$root_dir/redis/src/redis-server#g" /etc/init.d/redis
	sed -i "s#CLIEXEC=.*#CLIEXEC=$$root_dir/redis/src/redis-cli#g" /etc/init.d/redis
	sed -i "s#PIDFILE=.*#PIDFILE=/var/run/redis_6379.pid#g" /etc/init.d/redis
	sed -i "s#CONF=.*#CONF=$root_dir/redis/redis.conf#g" /etc/init.d/redis
	sed -i "s#daemonize no#daemonize yes#g" $root_dir/redis/redis.conf
	/etc/init.d/redis start
fi
