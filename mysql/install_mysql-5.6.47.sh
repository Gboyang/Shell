#!/bin/bash
#
# install mysql-5.6.47
# -------------------------------->
install_dir=/application
my_user=mysql
my_data=$install_dir/mysql/data/
# start the installation
# -------------------------------->
if [ `uname -m`=="x86_64" ];then
	cpu_info="x86_64"
else
	cpu_info="i686"
fi
rm -rf mysql-5.6.47*
mkdir $install_dir
if [ $cpu_info=="x86_64" ];then
	wget -q http://mirrors.163.com/mysql/Downloads/MySQL-5.6/mysql-5.6.47-linux-glibc2.12-x86_64.tar.gz
	if [ -f mysql-5.6.47-linux-glibc2.12-x86_64.tar.gz ];then
		tar zvxf mysql-5.6.47-linux-glibc2.12-x86_64.tar.gz
		mv mysql-5.6.47-linux-glibc2.12-x86_64 $install_dir/mysql-5.6.47
	else
		exit 1
	fi
else
	wget -q http://mirrors.163.com/mysql/Downloads/MySQL-5.6/mysql-5.6.47-linux-glibc2.12-i686.tar.gz
	if [ -f mysql-5.6.47-linux-glibc2.12-i686.tar.gz ];then
		tar zvxf mysql-5.6.47-linux-glibc2.12-i686.tar.gz
		mv mysql-5.6.47-linux-glibc2.12-i686 $install_dir/mysql-5.6.47
	else
		exit 1
	fi
fi
useradd -s /sbin/nologin -M $my_user
ln -s $install_dir/mysql-5.6.47 $install_dir/mysql
cd $install_dir/mysql
./scripts/mysql_install_db --datadir=$my_data --basedir=$install_dir/mysql-5.6.47 --user=$my_user
if [ $? != 0 ];then
	exit 2
fi
\cp ./support-files/mysql.server /etc/init.d/mysqld
chmod +x /etc/init.d/mysqld
sed -i "s#/usr/local/mysql#$install_dir/mysql#g" /etc/init.d/mysqld
sed -i "s#/usr/local/mysql#$install_dir/mysql#g" /application/mysql/bin/mysqld_safe 
\cp ./support-files/my-default.cnf /etc/my.cnf
echo "PATH=$install_dir/mysql/bin/:$PATH" >>/etc/profile
echo '-------------install successfully----------------'
echo '1、执行source /etc/profile 使环境变量生效'
echo '2、启动mysql，/etc/init.d/mysqld start'
echo '3、执行mysql'
echo '-------------------------------------------------'