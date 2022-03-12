#!/bin/sh
#
#mysql 安装目录
install_dir=/application/mysql
#-------------------------------------
data_dir=/data
port=$(find $data_dir -type d |awk -F/ '{print $3}'|grep -v '^$')

chown -R mysql.mysql $data_dir
find $data_dir -name mysql|xargs chmod 700
for port in $port;
do
	$install_dir/scripts/mysql_install_db --defaults-file=/data/$port/my.cnf \
	--basedir=/application/mysql/ \
	--datadir=/data/$port/data \
	--user=mysql
	if [ ! $? = 0 ];then
		echo '初始化失败，脚本退出'
		exit 2
	fi
done
echo '脚本执行完毕..............'