#!/bin/bash
#
#author zap


erro_exit() {
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
scan_scsi() {
    $(echo "- - -" > /sys/class/scsi_host/host0/scan)
}

partition() {
    array=$*
    for i in ${array[@]};do
	`parted  -s $i  mkpart primary 2 100%`
    done
    partprobe
}

create() {
    `mdadm -C $1 -l$2 -n$3 $device_array`
    if [ $? -ne 0 ];then
	erro_exit 4
    fi
}

if [ $# -ge 4 ] && [[ $1 =~ raid.* ]];then
    level=${1/raid/}
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
