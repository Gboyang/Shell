#!/bin/sh
LOG_DIR=/var/log
ROOT_UID=0
if [ "$UID" -ne "$ROOT_UID" ] 
    then 
        echo "Must be root to run this script." 
        exit 1 
fi
cd $LOG_DIR  || {
    echo "Cannot change to necessary directory."
exit 1
}
cat /dev/null >messages && {
echo "Logs cleaned up." 
exit 0 
}
