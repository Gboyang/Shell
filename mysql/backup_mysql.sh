#!/bin/bash
#
# mysql 分库分表备份
. /etc/init.d/functions
PORT='3306'
BAKUPDIR='/server/backup'
MYSQLUSER='root'
MYSQLPASS='569825'
SOCK="/data/${PORT}/mysql.sock"
CMDDIR="/application/mysql/bin"
MYSQL="${CMDDIR}/mysql -u${MYSQLUSER} -p${MYSQLPASS} -S${SOCK}"
DBNAME=`${MYSQL} -e "show databases;"|sed 1d|egrep -v "_schema|mysql"`
AYYAYDB=($DBNAME)
MYSQLDUMP="${CMDDIR}/mysqldump -u${MYSQLUSER} -p${MYSQLPASS} -S${SOCK}"

function BAKDB(){
DBNAME=`${MYSQL} -e "show databases;"|sed 1d|egrep -v "_schema|mysql"`
AYYAYDB=($DBNAME)

    for((n=0;n<${#AYYAYDB[*]};n++))
           do
    TABLE_BAK_DIR="${BAKUPDIR}/${AYYAYDB[$n]}"
    TABLENAME=`${MYSQL} -e "show tables from ${AYYAYDB[$n]};"|sed 1d`
    ARRAYTABLE=(${TABLENAME})
        for((i=0;i<${#ARRAYTABLE[*]};i++))
            do
        [ -d ${TABLE_BAK_DIR}  ] || mkdir ${TABLE_BAK_DIR} -p
        ${MYSQLDUMP} ${AYYAYDB[$n]} ${ARRAYTABLE[$i]} |gzip >${TABLE_BAK_DIR}/${ARRAYTABLE[$i]}_$(date +%T-%F)_bak.sql.gz
        RETVAL=$?
        if [ $RETVAL -eq 0 ]
            then
                echo "${AYYAYDB[$n]}_${ARRAYTABLE[$i]} bak successfull `date +%F-%T` " >>/tmp/DB_table_bakstatus.log
            else
                echo "${AYYAYDB[$n]}_${ARRAYTABLE[$i]} bak fail `date +%F-%T` " >>/tmp/DB_table_bakstatus.log
        fi 
        done 
           done
    mail -s "DB STATUS" www.abcdocker.com@qq.com < /tmp/DB_table_bakstatus.log
    return
}

function DBstatus(){

[ -d ${BAKUPDIR} ] || mkdir ${BAKUPDIR} -p
${MYSQL} -e "show full processlist;" &> /dev/null
RETVAL=$?
if [ $RETVAL -eq 0 ]
  then
        >/tmp/DB_table_bakstatus.log
        BAKDB 
  else
       echo "DB BAD!!!  `date +%F-%T`" | mail -s "DB BAD!!!" www.abcdocker.com@qq.com
        exit
fi
}

DBstatus