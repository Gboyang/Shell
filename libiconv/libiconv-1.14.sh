#!/bin/sh
#
# libiconv-1.14 install 
. /etc/init.d/functions
install_dir=/usr/local/libiconv

function install_libiconv() {
	tar xf libiconv-1.14.tar.gz
	cd libiconv-1.14
	./configure --prefix=$install_dir
	make &&make install
	if [ $? = 0 ];then
		echo 'libiconv-1.14 安装成功'
	else
		echo 'libiconv-1.14 安装失败'
	fi
}

if [ -f libiconv-1.14.tar.gz ];then
	install_libiconv
else
	echo '开始下载,请耐心等待.........'
	wget -q http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.14.tar.gz
	install_libiconv
fi
