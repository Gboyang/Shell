#!/bin/bash
. /etc/init.d/functions
num=$1
user_DB=/tmp/userlist
function user_add(){
for i in stu{01..10}
do
    pass_word=$(uuidgen)
    useradd $i &>/dev/null
    if [ $? -eq 0 ]
    then
        action "$i" /bin/true
        echo "user:$i,passwd:$pass_word" >> $user_DB
        echo $pass_word|passwd --stdin $i &>/dev/null 
    else
        action "$i" /bin/false
    fi
done
}

function user_del(){
	for i in stu{01..10}
    do
        userdel -r $i &>/dev/null
        if [ $? -eq 0 ]
        then
            action "delete user $i" /bin/true
        else
            action "delete user $i" /bin/false
        fi
    done
}
function main(){
    case "$num" in
        useradd)
            user_add
            ;;
        userdel)
            user_del
            ;;
        *)
            echo "please input $0 {useradd|userdel}"
            exit;
    esac
}

main
