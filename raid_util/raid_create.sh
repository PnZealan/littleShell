#!/bin/bash
#
#author zap

. /etc/init.d/functions    

function erro_exit() {
    case $* in
    1)
	echo "parameters"
	exit 1
	;;
    2)
	echo "raid_create <raid_level> <md_name> <raid_devices> <raid_devices> ..."
	exit 2
	;;
    3)
	echo "parted error"
	exit 3
	;;
    4)
	echo "mdadm error"
	exit 4
	;;
    *)
	;;
    esac
	
}
function scan_scsi() {
    $(echo "- - -" > /sys/class/scsi_host/host0/scan)
    if [ $? -eq 0 ];then
        action "scan_scsi - - -" /bin/true
    fi
}

function partition() {
    array=$*
    for i in ${array[@]};do
	`parted  -s $i  mkpart primary 2 100%`
        action "parted $i successfully" /bin/true
    done
    partprobe
}

function create() {
    `mdadm -C $1 -l$2 -n$3 $device_array`
    if [ $? -ne 0 ];then
        action "mdadm create" /bin/false
	erro_exit 4
    else
        action "mdadm create successfully" /bin/true
    fi
}

if [ $# -ge 4 ] && [[ $1 =~ raid.* ]];then
    level=${1//raid/}
    md_name=$2
    raid_devices=$(($#-2))
    scan_scsi
    for i in $*;do
	array[${#array[*]}]=$i
    done
    device_array=${array[@]:2}
    partition $device_array
    create  $md_name $level $raid_devices 
else
    erro_exit 2
fi
