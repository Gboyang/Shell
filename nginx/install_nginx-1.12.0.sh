#!/bin/bash
#
# install nginx-1.12.0
/usr/bin/rm -rf nginx-1.12.0*
wget -q http://nginx.org/download/nginx-1.12.0.tar.gz
if [ ! -f nginx-1.12.0.tar.gz ];then
	echo '下载失败'
	exit 1
fi
if [ `rpm -qa pcre pcre-devel openssl openssl-devel|wc -l` != 4 ];then
	yum -y install pcre pcre-devel openssl openssl-devel
fi
/usr/sbin/useradd -s /sbin/nologin -M www
/usr/bin/tar xf nginx-1.12.0.tar.gz && cd nginx-1.12.0
./configure --user=www \
--group=www \
--prefix=/application/nginx-1.12.0 \
--with-http_stub_status_module \
--without-http-cache \
--with-http_ssl_module \
--with-http_gzip_static_module
make && make install
ln -s /application/nginx-1.12.0 /application/nginx
chmod 775 /application/nginx/
chown -R www:www /application/nginx/
# 启动
/application/nginx/sbin/nginx