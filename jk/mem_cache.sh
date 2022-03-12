#!/bin/bash
# author: Gboyanghao
# ------------------------
# args
in_args=$1

case $in_args in
	total_mem)
	# total memory
		vmstat -s -S K | awk 'NR==1{print $1}'
		;;
	user_mem)
	# used memory
		vmstat -s -S K | awk 'NR==2{print $1}'
		;;
	active_mem)
	# active memory
		vmstat -s -S K | awk 'NR==3{print $1}'
		;;
	inactive_mem)
	# inactive memory
		vmstat -s -S K | awk 'NR==4{print $1}'
		;;
	free_mem)
	# free memory
		vmstat -s -S K | awk 'NR==5{print $1}'
		;;
	buffer_mem)
	# buffer memory
		vmstat -s -S K | awk 'NR==6{print $1}'
		;;
	swap_cache)
	# swap cache
		vmstat -s -S K | awk 'NR==7{print $1}'
		;;
	total_swap)
	# total swap
		vmstat -s -S K | awk 'NR==8{print $1}'
		;;
	used_swap)
	# used swap
		vmstat -s -S K | awk 'NR==9{print $1}'
		;;
	free_swap)
	# free swap
		vmstat -s -S K | awk 'NR==10{print $1}'
		;;
	* )
		echo -e "\e[033mUsage: sh  $0 [total_mem|user_mem|active_mem|inactive_mem|free_mem|buffer_mem|swap_cache|total_swap|used_swap|free_swap]\e[0m"
		;;
esac