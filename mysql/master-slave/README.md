## *主库执行*

```
grant replication slave on *.* to rep@'192.168.1.%' identified by '123456';
如果是全新的刚部署的系统可以不用进行全备
mysqldump --master-data=2 -S /application/mysql/tmp/mysql.sock -A -B |gzip >/server/backup/mysql_bak.$(date +%F).sql.gz
```

## *从库执行*

```
zcat mysql_bak.2017-05-03.sql.gz >mysql_bak.2017-05-03.sql
mysql -S /application/mysql/tmp/mysql.sock <mysql_bak.2017-05-03.sql
change master to master_host='192.168.1.30',master_user='rep', master_password='123456', master_auto_position=1, master_port=3306;
start slave;
```

