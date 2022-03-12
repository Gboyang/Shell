*1、所以节点执行*

```
yum install perl-DBD-MySQL -y
rpm -ivh mha4mysql-node-0.56-0.el6.noarch.rpm
做好ssh免密钥认证
```

*2、主库执行*

```
grant all privileges on *.* to mha@'%' identified by 'mha';
select user,host from mysql.user;
```

*3、部署管理节点执行*

```
yum install -y perl-Config-Tiny epel-release perl-Log-Dispatch perl-Parallel-ForkManager perl-Time-HiRes
rpm -ivh mha4mysql-manager-0.56-0.el6.noarch.rpm
[root@db03 ~]# mkdir -p /etc/mha
[root@db03 ~]# mkdir -p /var/log/mha/app1
------配置文件----------------------------
mv mha.cnf /etc/mha/app1.cnf
------测试ssh----------------------------
masterha_check_ssh --conf=/etc/mha/app1.cnf
#输出如下表示成功
All SSH connection tests passed successfully.
------测试复制--------------------------
masterha_check_repl --conf=/etc/mha/app1.cnf
#看到如下字样，则测试成功
MySQL Replication Health is OK.

#启动mha
nohup masterha_manager --conf=/etc/mha/mha.cnf --remove_dead_master_conf --ignore_last_failover < /dev/null > /var/log/mha/app/manager.log 2>&1 &
```

*4、从库查看*

```
mysql> show slave status\G
*************************** 1. row ***************************
               Slave_IO_State: Waiting for master to send event
                  Master_Host: 192.168.1.30
                  Master_User: rep
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: mysql-bin.000001
          Read_Master_Log_Pos: 903
               Relay_Log_File: DB02-relay-bin.000002
                Relay_Log_Pos: 1113
        Relay_Master_Log_File: mysql-bin.000001
             Slave_IO_Running: Yes
            Slave_SQL_Running: Yes
mysql> show slave status\G
*************************** 1. row ***************************
               Slave_IO_State: Waiting for master to send event
                  Master_Host: 192.168.1.30
                  Master_User: rep
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: mysql-bin.000001
          Read_Master_Log_Pos: 903
               Relay_Log_File: DB03-relay-bin.000002
                Relay_Log_Pos: 1113
        Relay_Master_Log_File: mysql-bin.000001
             Slave_IO_Running: Yes
            Slave_SQL_Running: Yes
#停掉主库
[root@db01 ~]# /etc/init.d/mysqld stop
Shutting down MySQL..... SUCCESS!
#登录数据库（db02）
show slave status\G
Empty set (0.00 sec)

cp master_ip_failover /etc/mha/
chmod +x /etc/mha/master_ip_failover
db01手动绑定VIP
ifconfig eth1:0 192.168.1.35/24
#停掉主库
[root@db01 ~]# /etc/init.d/mysqld stop
Shutting down MySQL..... SUCCESS!
```