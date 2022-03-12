#!/bin/sh
#
# cmake mysql 5.6.39 
#
. /etc/init.d/functions
#------------------------------>
#安装目录
install_dir=/application
#user
mysql_user=mysql
#data dir
mysql_data=$install_dir/mysql-5.6.39/data
#sock dir
mysql_sock=$install_dir/mysql-5.6.39/tmp


function initialize_mysql () {
	$install_dir/mysql/scripts/mysql_install_db --basedir=$install_dir/mysql/ --datadir=$mysql_data --user=$mysql_user
	if test `echo $?` -eq 0
	then
		chown -R $mysql_user.$mysql_user $install_dir/mysql/
		cp support-files/mysql.server /etc/init.d/mysqld
		chmod 700 /etc/init.d/mysqld
		chkconfig mysqld on
		echo "PATH=$install_dir/mysql/bin/:$PATH" >>/etc/profile
		echo '--------安装成功------------'
		echo '1、执行source /etc/profile使他生效'
		echo '2、启动mysql'
	fi
}

function cmake_mysql () {
	cd mysql-5.6.39
	cmake . -DCMAKE_INSTALL_PREFIX=$install_dir/mysql-5.6.39 \
	-DMYSQL_DATADIR=$mysql_data \
	-DMYSQL_UNIX_ADDR=$mysql_sock/mysql.sock \
	-DDEFAULT_CHARSET=utf8 \
	-DDEFAULT_COLLATION=utf8_general_ci \
	-DWITH_EXTRA_CHARSETS=all \
	-DWITH_INNOBASE_STORAGE_ENGINE=1 \
	-DWITH_FEDERATED_STORAGE_ENGINE=1 \
	-DWITH_BLACKHOLE_STORAGE_ENGINE=1 \
	-DWITHOUT_EXAMPLE_STORAGE_ENGINE=1 \
	-DWITH_ZLIB=bundled \
	-DWITH_SSL=bundled \
	-DENABLED_LOCAL_INFILE=1 \
	-DWITH_EMBEDDED_SERVER=1 \
	-DENABLE_DOWNLOADS=1 \
	-DWITH_DEBUG=0
	[ `echo $?` -eq 0 ] && make ||exit 1
	[ `echo $?` -eq 0 ] && make install ||exit 1
	if test `echo $?` -eq 0
	then
		ln -s $install_dir/mysql-5.6.39/ $install_dir/mysql
		\cp support-files/my*.cnf /etc/my.cnf
		mkdir $mysql_sock
		echo 'cmake函数执行完毕..............'
		sleep 2
		initialize_mysql
	fi
}

function preparatory () {
	if [ -f mysql-5.6.39.tar.gz ];then
		wget -q -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-6.repo
		wget -q -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-6.repo
		yum install ncurses-devel libaio-devel cmake -y
		[ `rpm -qa ncurses-devel libaio-devel cmake |wc -l` -eq 3 ] || exit 1
		useradd -s /sbin/nologin -M $mysql_user
		tar xf mysql-5.6.39.tar.gz
		cmake_mysql
	else
		echo '安装包不存在，脚本退出！'
		exit 1
	fi
}
preparatory

