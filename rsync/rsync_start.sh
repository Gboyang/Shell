#!/bin/bash
# chkconfig: 2345 64 36
# description: manager rsyncd server.

. /etc/init.d/functions
 
rsync=/usr/bin/rsync
prog=rsyncd
pidfile=${PIDFILE-/var/run/rsyncd.pid}
lockfile=${LOCKFILE-/var/lock/subsys/rsyncd}
RsyncConf="/etc/rsyncd.conf"
RETVAL=0
 
Usage(){
	$SETCOLOR_WARNING 
	echo -n "Rsync Daemon Program Need Configuration File,like /etc/rsyncd.conf"
	$SETCOLOR_NORMAL
	echo
	exit 6
}

start(){
	[ -x $rsync ] || exit 5
	[ -f $RsyncConf ] || Usage
        echo -n $"Starting $prog: "
        daemon --pidfile=${pidfile} $rsync --daemon
        RETVAL=$?
        echo
        [ $RETVAL = 0 ] && touch ${lockfile}
        return $RETVAL
}
 
stop(){
	echo -n $"Stopping $prog: "
	killproc $prog
	retval=$?
	echo
	[ $retval -eq 0 ] && rm -f ${lockfile}
	return $retval
}
 
restart() {
	stop
	sleep 1
	start
}
 
rh_status() {
	status $prog
}
 
rh_status_q() {
	rh_status >/dev/null 2>&1
}
 
case "$1" in
    start)
        rh_status_q && exit 0
        $1
        ;;
    stop)
        rh_status_q || exit 0
        $1
        ;;
    restart)
        $1
        ;;
    status)
        rh_status
        ;;
    *)
        echo $"Usage: $0 {start|stop|status|restart}"
        exit 2
esac
