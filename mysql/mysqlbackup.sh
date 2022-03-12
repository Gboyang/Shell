#!/bin/sh
#--------------------->
PATH="/application/mysql/bin:$PATH"
DBPATH=/server/backup
MYUSER=root
MYPASS=root@123
SOCKET=/data/3306/mysql.sock
MYCMD="mysql -u$MYUSER -p$MYPASS -S $SOCKET"
MYDUMP="mysqldump -u$MYUSER -p$MYPASS -S $SOCKET"
[ ! -d $DBPATH ] && mkdir $DBPATH
for dbname in $($MYCMD -e "show databases;"|sed '1,2d'|egrep -v "mysql|schema")
do
	$MYDUMP $dbname|gzip >$DBPATH/${dbname}_$(date +%F).sql.gz
done
	

