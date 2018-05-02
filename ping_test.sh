#! /bin/bash
#filename ping_test.sh
#author zap

if [ "$#" = "0" ];then
    echo "usage -------------"
    echo "    -t TARGET    IP/NAME"
    echo "    -p  PROCESS    num of threads(default:10)"
    exit 2
fi

num=10

while getopts "t:p:" OPT;do
    case $OPT in
        t)TARGET="$OPTARG";;
        p)num="$OPTARG";;
        *)
            echo "invalid args"
            exit 1
        ;;
    esac
done
    #echo $TARGET $num
    #TARGET="10.0.83.1"
    #num=10


function executor(){
    rm -f  /tmp/ping_tmp
    local sum1=0
    local count=0
    local p_num=$(($num*10))
    if [ -z $num ];then
        r_lost=$(ping -c 10 $TARGET 2> /dev/null |awk '/^10/{print $4}')
        echo "packet recive rate "$r_lost
    else
        for((i=0; i<$num; i++));do
            {
                $(ping -c 10 $TARGET 2> /dev/null |awk '/^10/{print $4}' >> /tmp/ping_tmp)
            }&
        done

        wait

        while read line ;do
        {
            if [ ! -z "$line" ];then
                #echo "------------"$line
                arry[$count]="$line"
            else
                break
            fi
            ((count++))
        }
        done</tmp/ping_tmp

        for((i=0; i<$num; i++));do
        {
            ((sum1+=${arry[$i]}))
        }
        done

        if [ ! -z "$sum1" ];then
            #echo "-----p_num$p_num-----$sum1"
            echo -e "\033[31mpacket receive average :\033[0m\c"
            echo "$sum1 $p_num" | awk '{printf "%2.2f%\n",($1/$2*100)}'
        fi
        rm -f /tmp/ping_tmp
    fi
}
executor
