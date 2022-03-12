#!/bin/bash
#
# author: gboyanghao@163.com
# describe: PXE install script
# env: openEuler system version 20.03
# -------------------------------------->
# tenancy
net_default_time=21600
net_max_time=43200
# ---------------------------------------->
# dir path
scpath="`dirname $0`"
curpath="`cd $scpath;pwd`"

# color 
BOOTUP=color
RES_COL=60
MOVE_TO_COL="echo -en \\033[${RES_COL}G"
SETCOLOR_SUCCESS="echo -en \\033[1;32m"
SETCOLOR_FAILURE="echo -en \\033[1;31m"
SETCOLOR_NORMAL="echo -en \\033[0;39m"

echoState() {
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

echoError() {
	$SETCOLOR_FAILURE
	echo -n "$1"
	$SETCOLOR_NORMAL
	echo
	return 0
}

# path
conf_file=$curpath/config/pxe.conf
if [ ! -e $conf_file ];then
	echoError "ERROR: check $conf_file"
	exit
fi

# Get the value
function get_file_value () {
	args=$1
	# args
	value=$(cat $conf_file |grep "$args"|awk -F= '{print $2}'|sed 's/[[:space:]]//g')
	if [ -z $value ];then
		echoError "Error: Check pxe.conf $args NOT NULL" 
		return 55
	fi
	echo $value
}

# YUM source mount directory
mount_dir1=$(get_file_value 'local_YUM_Dir')
if [ $? = 55 ];then
    echo ${mount_dir1}
    exit
fi
if [ ! -e $mount_dir1 ];then
	mkdir -p $mount_dir1
fi

#关闭防火墙和selinux
/usr/bin/sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
/usr/bin/systemctl stop firewalld && /usr/bin/systemctl disable firewalld
/usr/sbin/setenforce 0
if [ ! -f $curpath/iso/openEuler*.iso ];then
	echoError "ERROR: check $curpath/iso not exists"
	exit
fi
mount $curpath/iso/openEuler*.iso $mount_dir1
if mountpoint -q $mount_dir1;then
	/usr/bin/rm -rf /etc/yum.repos.d/*
	cat >/etc/yum.repos.d/local.repo <<-EOF
[development]
name=local
baseurl=file://${mount_dir1}
gpgcheck=0
enabled=1
EOF
else
	echoError "ERROR: check $mount_dir1 not exist!"
	exit
fi
/usr/bin/yum -q clean all
/usr/bin/yum -q makecache
if [ $? != 0 ];then 
	echoError 'ERROR: yum repo faill!'
	exit
fi
#--------------------------------------------------------->
net_sub=$(get_file_value 'network_segment')
if [ $? = 55 ];then
    echo ${net_sub}
    exit
fi
/usr/bin/ipcalc -cs $net_sub
if [ $? != 0 ];then
	echoError 'ERROR: check network_segment ip address legitimacy'
	exit
fi
net_mask=$(get_file_value 'network_mask')
if [ $? = 55 ];then
    echo ${net_mask}
    exit
fi
/usr/bin/ipcalc -cs $net_mask
if [ $? != 0 ];then
	echoError 'ERROR: check network_mask ip address legitimacy'
	exit
fi
start_range=$(get_file_value 'start_range')
if [ $? = 55 ];then
    echo ${start_range}
    exit
fi
/usr/bin/ipcalc -cs $start_range
if [ $? != 0 ];then
	echoError 'ERROR: check start_range ip address legitimacy'
	exit
fi
end_range=$(get_file_value 'end_range')
if [ $? = 55 ];then
    echo ${end_range}
    exit
fi
/usr/bin/ipcalc -cs $end_range
if [ $? != 0 ];then
	echoError 'ERROR: check end_range ip address legitimacy'
	exit
fi
net_next=$(get_file_value 'next_server')
if [ $? = 55 ];then
    echo ${net_next}
    exit
fi
/usr/bin/ipcalc -cs $net_next
if [ $? != 0 ];then
	echoError 'ERROR: check next_server ip address legitimacy'
	exit
fi
net_gateway=$(get_file_value 'network_gateway')
if [ $? = 55 ];then
    echo ${net_gateway}
    exit
fi
/usr/bin/ipcalc -cs $net_gateway
if [ $? != 0 ];then
	echoError 'ERROR: check network_gateway ip address legitimacy'
	exit
fi
#------------------------------------------------------------------>
function dhcp_service_config () {
	/usr/bin/yum -y -q install dhcp-server || /usr/bin/yum -y -q install dhcp
	cat >/etc/dhcp/dhcpd.conf <<EOF
subnet ${net_sub} netmask ${net_mask} {
	range ${start_range} ${end_range};
	option subnet-mask ${net_mask};
	option routers ${net_gateway};
	default-lease-time ${net_default_time};
	max-lease-time ${net_max_time};   
	next-server ${net_next};
	filename "uefi/grubaa64.efi";
}
EOF
    /usr/sbin/dhcpd -t 2&>1 >/dev/null
	if [ $? != 0 ];then
		echoError 'ERROR: DHCP Config Error.....'
		exit 3
	fi
	echo 'DHCP Configuration is successful........'
}


# TFTP CONFIG
function tftp_service_config () {
	/usr/bin/yum -y -q install xinetd tftp-server
	if [ $? != 0 ];then
		echoError "ERROR: xinetd tftp-server package install failed!"
		exit
	fi
	if [ ! -f /etc/xinetd.d/tftp ];then
		echoError "ERROR: check xinetd tftp-server package not install!"
		exit
	else
		/usr/bin/sed -i '/disable/s/yes/no/' /etc/xinetd.d/tftp
	fi
	echo 'TFTP Configuration is successful........'
}

# HTTP SERVICE
function http_service_config () {
	/usr/bin/yum -y -q install httpd
	if [ $? != 0 ];then
		echoError "ERROR: httpd package install failed!"
		exit 1
	fi
	/usr/bin/mkdir -p /var/lib/tftpboot/uefi
	mount_dir=/var/www/html/open
	/usr/bin/mkdir -p $mount_dir
	# openEuler
	mount $curpath/iso/openEuler*.iso /$mount_dir
	if mountpoint -q $mount_dir
	then
		/usr/bin/cp $mount_dir/EFI/BOOT/{BOOTAA64.EFI,grubaa64.efi} /var/lib/tftpboot/uefi/
		cd $curpath/config/
		if [ -f openEuler_grub.cfg ];then
			cp openEuler_grub.cfg /var/lib/tftpboot/uefi/grub.cfg
			/usr/bin/cat /root/*ks.cfg > /var/www/html/ks.cfg
			/usr/bin/sed -i '/^cdrom/s/cdrom/# cdrom/g' /var/www/html/ks.cfg
			/usr/bin/sed -i '/^clearpart/s#--none#--all#' /var/www/html/ks.cfg
			/usr/bin/sed -i "s@http://localhost/@http://$net_next/@g" /var/lib/tftpboot/uefi/grub.cfg
			/usr/bin/sed -i "2a install \nurl --url=http://${net_next}/open" /var/www/html/ks.cfg
			echo 'HTTP Configuration is successful........'
		else
			echoError 'ERROR: check $curpath/config/grub.cfg not file'
			exit
		fi
		/usr/bin/cp $mount_dir/images/pxeboot/{initrd.img,vmlinuz} /var/lib/tftpboot/uefi
		chmod 755  /var/lib/tftpboot/uefi/*
    else
		echoError "ERROR: not mounted...."
		exit
	fi
}

function public_tamplate () {
    service_name=$1
	systemctl start $service_name
	service_status=$(systemctl |grep $1|awk '{print $4}'|sed 's/[[:space:]]//g')
	if [ $service_status = 'running' ];then
		echoState OK "$service_name start successful"
	else
		echoState KO "$service_name start faill!"
	fi
}

function main () {
	# dhcp install and Configuration DHCP
	dhcp_service_config
	
	# TFTP install and Configuration TFTP
	tftp_service_config
	
	# HTTP install and Configuration HTTP
	http_service_config
	
	# State service
	Service_List=(dhcpd.service xinetd.service httpd.service)
	for server in ${Service_List[*]};do
		public_tamplate $server
	done
}
main