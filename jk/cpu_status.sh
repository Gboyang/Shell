#!/bin/bash
# author: Gboyanghao

args=$1

if test $(rpm -qa sysstat*|wc -l) == 0;
	then
		yum -y install sysstat*
fi


case $args in
	usr)
        mpstat|awk 'NR==4{print $4}'
		# 显示在用户级（应用程序）执行时发生的CPU利用率百分比
    ;;
	nice)
        mpstat|awk 'NR==4{print $5}'
		# 显示以优先级较高的用户级别执行时发生的CPU利用率百分比
    ;;
	sys)
        mpstat|awk 'NR==4{print $6}'
		# 显示在系统级（内核）执行时发生的CPU利用率百分比。请注意，这不包括维护硬件和软件的时间中断。
    ;;
	iowait)
        mpstat|awk 'NR==4{print $7}'
		# 显示系统具有未完成磁盘I / O请求的CPU或CPU空闲的时间百分比。
    ;;
	irq)
        mpstat|awk 'NR==4{print $8}'
		# 显示CPU或CPU用于服务硬件中断的时间百分比
    ;;
	soft)
        mpstat|awk 'NR==4{print $9}'
		# 显示CPU或CPU用于服务软件中断的时间百分比。
    ;;
	steal)
        mpstat|awk 'NR==4{print $10}'
		# 显示虚拟CPU或CPU在管理程序为另一个虚拟处理器提供服务时非自愿等待的时间百分比。
    ;;
	guest)
        mpstat|awk 'NR==4{print $11}'
		# 显示CPU或CPU运行虚拟处理器所花费的时间百分比。
    ;;
	idle)
        mpstat|awk 'NR==4{print $13}'
		# 显示CPU或CPU空闲且系统没有未完成的磁盘I / O请求的时间百分比。
    ;;
    *)
        echo -e "\e[033mUsage: sh  $0 [usr|nice|sys|iowait|irq|soft|steal|guest|idle]\e[0m"
esac
