#!/bin/bash
#脚本定时分析 access.log 日志或网络连接数， PV 大于 100 的访问，封掉对应 IP。

log_file=access.log
ip=$(awk '{print $1}' $log_file|sort|uniq -c|sort|awk '{print $1}')
for i in $ip
do
    if [ $(iptables -L -n|grep $i|wc -l) -eq 100 ]
    then
        iptables -I INPUT -s $i -j DROP
    fi
done
