#!/bin/bash
#
# author: gboyanghao@163.com

# color 
BOOTUP=color
RES_COL=60
MOVE_TO_COL="echo -en \\033[${RES_COL}G"
SETCOLOR_SUCCESS="echo -en \\033[1;32m"
SETCOLOR_FAILURE="echo -en \\033[1;31m"
SETCOLOR_NORMAL="echo -en \\033[0;39m"

function echoState() {
  echo -n $2
  [ "$BOOTUP" = "color" ] && $MOVE_TO_COL
  echo -n "["
  if [ "$1" = "OK" ];then
        $SETCOLOR_SUCCESS
        echo -n $"  OK  "
  fi
  if [ "$1" = "KO" ];then
        $SETCOLOR_FAILURE
        echo -n "FAILED"
  fi
  [ "$BOOTUP" = "color" ] && $SETCOLOR_NORMAL
  echo -n "]"
  echo
  return 0
}
