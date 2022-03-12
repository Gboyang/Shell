#!/bin/bash
#
# install nginx-1.13.2
/usr/bin/rm -rf nginx-1.13.2*
wget -q http://nginx.org/download/nginx-1.13.2.tar.gz
if [ ! -f nginx-1.13.2.tar.gz ];then
	echo '下载失败'
	exit 1
fi
if [ `rpm -qa pcre pcre-devel openssl openssl-devel|wc -l` != 4 ];then
	yum -y install pcre pcre-devel openssl openssl-devel
fi
/usr/sbin/useradd -s /sbin/nologin -M www
/usr/bin/tar xf nginx-1.13.2.tar.gz && cd nginx-1.13.2
./configure --user=www \
--group=www \
--prefix=/application/nginx-1.13.2 \
--with-http_stub_status_module \
--without-http-cache \
--with-http_ssl_module \
--with-http_realip_module \
--with-http_gzip_static_module
make && make install
ln -s /application/nginx-1.13.2 /application/nginx
chmod 775 /application/nginx/
chown -R www:www /application/nginx/
/application/nginx/sbin/nginx
if [ `ps -ef|grep nginx |grep -v 'grep --color=auto nginx'|wc -l` -ge 1 ];then
	echo 'nginx 启动成功'
fi