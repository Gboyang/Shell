#!/bin/bash
#
# author: gboyanghao@163.com

# log format
function Color_Definition(){
    RC='\033[1;31m'
    GC='\033[1;32m'
    BC='\033[1;34m'
    YC='\033[1;33m'
    EC='\033[0m'
}
Color_Definition
function nowTime(){
	date1=`date -d today '+%Y-%m-%d %H:%M:%S+%N'`
}

function errorlog() {
        nowTime
        echo -e "[$date1] ${RC} [ERROR]${EC} $@" >> $scpath/install.log
}
function infolog() {
        nowTime
        echo -e "[$date1] ${GC} [INFO]${EC} $@" >> $scpath/install.log
}
function warnlog() {
        nowTime
        echo -e "[$date1] ${YC} [WARN]${EC} $@" >> $scpath/install.log
}

# 调用方式
# errorlog error
# warnlog warning
# infolog info
#