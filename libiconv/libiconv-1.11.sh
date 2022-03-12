#!/bin/sh
#
# libiconv-1.11 install 

install_dir=/usr/local/libiconv

wget -q http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.11.tar.gz
tar xf libiconv-1.11.tar.gz
cd libiconv-1.11
./configure --prefix=$install_dir
make &&make install
if [ $? = 0 ];then
	echo 'libiconv-1.11 安装成功'
else
	echo 'libiconv-1.11 安装失败'
fi

