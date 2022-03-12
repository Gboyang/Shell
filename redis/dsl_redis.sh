#!/bin/sh
#
# redis 多实例的配置
. /etc/init.d/functions
# installation path
install_path=/application/redis
# ------------------------------------->
# 多实例配置文件存放路径
dir=/etc/redis
# 多实例端口的配置，需要起几个实例填写多少个端口
redis_port="6379 6380 6381"
#------------------------------------->
function start_file () {
	port=$1
	cp -a ./utils/redis_init_script $dir/$port/redis
	sed -i "/^REDISPORT=/s#REDISPORT=.*#REDISPORT=$port#g" $dir/$port/redis
	sed -i "/^EXEC=/s#EXEC=.*#EXEC=$install_path/src/redis-server#g" $dir/$port/redis
	sed -i "/^CLIEXEC=/s#CLIEXEC=.*#CLIEXEC=$install_path/src/redis-cli#g" $dir/$port/redis
	sed -i "/^PIDFILE=/s#PIDFILE=.*#PIDFILE=$dir/$port/redis_$port.pid#g" $dir/$port/redis
	sed -i "/^CONF=/s#CONF=.*#CONF=$dir/$port/$port.conf#g" $dir/$port/redis
}

function edit_config () {
	port=$1
	cp -a ./redis.conf $dir/$port/$port.conf
	sed -i "/^port/s#port 6379#port $port#g" $dir/$port/$port.conf
	sed -i "/^pidfile/s#pidfile .*#pidfile $dir/$port/redis_$port.pid#g" $dir/$port/$port.conf
	sed -i "/^logfile/s#logfile .*#logfile $dir/$port/redis_$port.log#g" $dir/$port/$port.conf
	sed -i "/^dbfilename/s#dbfilename .*#dbfilename dbfilename_$port.rbd#g" $dir/$port/$port.conf
	sed -i "/^dir/s#dir.*#dir $dir/$port#g" $dir/$port/$port.conf
	start_file $port
}


for port in $redis_port;
do
	if [ -d $dir/$port ];then
		echo "$dir/$port 已存在，请删除后再次执行！"
	else
		mkdir -p $dir/$port
		if [ `pwd` == $install_path ];then
			edit_config $port
		else
			cd $install_path
			edit_config $port
		fi
	fi
done