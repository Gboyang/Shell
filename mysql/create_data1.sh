#!/bin/bash
#
# Batch data generation
# 此脚本用来生成测试数据
NUM=10000

# db username and password
DB_USER=root
DB_PASS=

# Command directory
ORDER_PATH=/application/mysql/bin
if [ $DB_PASS ];then
	$ORDER_PATH/mysql -u$DB_USER -p$DB_PASS -e "create database my_test;"
	$ORDER_PATH/mysql -u$DB_USER -p$DB_PASS -e "use my_test; create table test(id int(4) not null auto_increment, content text not null,primary key(id));"
	for i in `seq 1 $NUM`;
	do
		val=`head /dev/urandom | tr -dc 'A-Za-z0-9'`
		$ORDER_PATH/mysql -u$DB_USER -p$DB_PASS -e "use my_test; insert into test(content) values('$val');"
	done
else
	$ORDER_PATH/mysql -u$DB_USER -e "create database my_test"
	$ORDER_PATH/mysql -u$DB_USER -e "use my_test; create table test(id int(4) not null auto_increment,content text not null,primary key(id));"
	for i in `seq 1 $NUM`;
	do
		val=`head /dev/urandom | tr -dc 'A-Za-z0-9'`
		$ORDER_PATH/mysql -u$DB_USER -e "use my_test; insert into test(content) values('$val');"
	done
fi
	
