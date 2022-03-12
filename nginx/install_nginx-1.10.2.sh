#!/bin/sh
#
# nginx install shell
. /etc/init.d/functions
# 
nginx_user=www
install_dir=/application


[ `uname -m` == 'x86_64' ] || exit 2

function download_nginx_package () {
	echo '-------开始下载nginx-1.10.2.tar.gz-----'
	wget -q http://nginx.org/download/nginx-1.10.2.tar.gz
	if [ -f nginx-1.10.2.tar.gz ];then
		echo 'nginx-1.10.2.tar.gz安装包下载完成'
		dependent_package
	else
		echo '下载nginx-1.10.2.tar.gz安装包下载失败'
		echo '脚本退出,返回错误代码1..........'
		exit 1
	fi
}

function dependent_package (){
	if [ `rpm -qa pcre pcre-devel openssl openssl-devel|wc -l` == 4 ];then
		compile_nginx
	else
		wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-6.repo
		yum -y install pcre pcre-devel openssl openssl-devel
		if [ ! `rpm -qa pcre pcre-devel openssl openssl-devel|wc -l` == 4 ];then
			echo 'pcre pcre-devel openssl openssl-devel安装失败,脚本退出'
			exit 2
		else
			compile_nginx
		fi
	fi
}

function compile_nginx () {
	/bin/tar xf nginx-1.10.2.tar.gz
	if [ -d nginx-1.10.2 ];then
		/usr/sbin/useradd -s /sbin/nologin -M $nginx_user
		cd nginx-1.10.2
		./configure --user=$nginx_user \
		--group=$nginx_user \
		--prefix=$install_dir/nginx-1.10.2 \
		--with-http_stub_status_module \
		--with-http_ssl_module
		make &&make install
		if [ $? = 0 ];then
			ln -s $install_dir/nginx-1.10.2 $install_dir/nginx
			chown -R $nginx_user.$nginx_user $install_dir/nginx/
			chmod -R 755 $install_dir/nginx/
			$install_dir/nginx/sbin/nginx
			echo 'nginx-1.10.2 安装成功'
		else
			echo 'make 安装失败，脚本退出'
			exit 3
		fi
	fi
}

function min () {
	if [ -f nginx-1.10.2.tar.gz ];then
		/bin/mkdir $install_dir
		dependent_package
	else
		/bin/mkdir $install_dir
		download_nginx_package
	fi
}
min
