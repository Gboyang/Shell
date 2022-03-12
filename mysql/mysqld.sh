port=3307
mysql_user="mysql"
CmdPath="/application/mysql/bin"
mysql_sock="/application/data/${port}/mysql.sock"
mysqld_pid_file_path=/application/data/${port}/${port}.pid
start(){
    if [ ! -e "$mysql_sock" ];then
     	printf "Starting MySQL...\n"
        /bin/sh ${CmdPath}/mysqld_safe --defaults-file=/application/data/${port}/my.cnf --pid-file=$mysqld_pid_file_path 2>&1 > /dev/null &
        sleep 3
    else
        printf "MySQL is running...\n"
        exit 1
    fi
}
stop(){
    if [ ! -e "$mysql_sock" ];then
        printf "MySQL is stopped...\n"
        exit 1
    else
        printf "Stoping MySQL...\n"
        mysqld_pid=`cat "$mysqld_pid_file_path"`
         if (kill -0 $mysqld_pid 2>/dev/null)
           then
             kill $mysqld_pid
             sleep 2
         fi
    fi
}

restart(){
    printf "Restarting MySQL...\n"
    stop
    sleep 2
    start
}

case "$1" in
    start)
        start
    ;;
    stop)
        stop
    ;;
    restart)
        restart
    ;;
    *)
        printf "Usage: /data/${port}/mysql {start|stop|restart}\n"
esac