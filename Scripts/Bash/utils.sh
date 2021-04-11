#!/bin/bash

########################################################
#List dir
#sh utils.sh LIST -> list elements in current file path
#sh utils.sh LIST "/var/www" -> list elements in /var/www

########################################################
#Create simple JSON file
#sh utils.sh JSON examplename.json "key=value" "DB_URL=192.168.0.100"

########################################################
#sh utils.sh INFO name cpu ram network disk mac
#sh utils.sh INFO mac
#Display system information

########################################################
#sh utils.sh INSTALL 
#Install software 7zip / java11 / python / chromium /.net


#List dir
list_dir () {
    if [ $# -eq 0 ]; then
        path='.'
    else
        path=$1
    fi
    find $path -type f -follow -print|xargs ls -l
}

#Create Json
create_json () {
    if  echo $1 | grep '.json' 
    then 
        filename=`echo $1`
        shift
        echo "{" > $filename
        i=1;
        for var in "$@"
        do
            key=` echo $var | awk -F "=" '{print $1}'`
            value=` echo $var | awk -F "=" '{print $2}'`
            if [ $i -eq $# ]; then
                echo '  "'$key'":"'$value'"' >> $filename
            else 
                echo '  "'$key'":"'$value'",' >> $filename
                i=$((i+1))
            fi
        done
        echo "}" >> $filename
    else 
        echo "You need to provide valid json filename."
        exit 1
    fi
}

#System information
system_info () {
    name () {
        hostname
    }
    cpu () {
        cpu=`cat /proc/cpuinfo  | grep 'name'| uniq |  awk -F ":" '{print $2}'`
        echo "CPU:" $cpu
    }
    ram () {
        ramTotal=`grep MemTotal /proc/meminfo | awk '{print $2 / 1024}' |  awk -F "." '{print $1}'`
        ramAvailable=`grep MemAvailable /proc/meminfo | awk '{print $2 / 1024}' |  awk -F "." '{print $1}'`
        echo 'RAM: Total: '$ramTotal' Used:'$(($ramTotal-$ramAvailable))' Available:'$ramAvailable''

    }
    mac () {
        i=1 
        echo "Interface MAC"
        countMacs=` cat /sys/class/net/*/address | wc -l`
        while [ "$i" -le $countMacs ]; do
            macAddr=` cat /sys/class/net/*/address | sed -n "$i"p `
            interface=` ip link | grep -B 1 $macAddr | awk '{print $2}' `
            echo $interface
            i=$(( i + 1 ))
        done
    }
    disk () {
        countDisks=`blkid | wc -l`
        i=1
        echo "Disk      Size    Used    Avail   Use%    Mount"
        while [ "$i" -le $countDisks ]; do
            diskName=`blkid | sed -n "$i"p | awk -F ":" '{print $1}'`
            diskUsage=`df -h | grep $diskName`
            echo $diskUsage
            i=$(( i + 1 ))
        done
    }

    declare -a options=("name" "cpu" "ram" "mac" "disk")
    optionslength=${#options[@]}
    parameters=( "$@" )
    paramslength=${#parameters[@]}

    for (( i=1; i<${paramslength}+1; i++ ));
    do
        for (( j=1; j<${optionslength}+1; j++ ));
            do
            [[ ${parameters[$i-1]} == ${options[$j-1]} ]] && ${options[$j-1]} 
            done
    done
}


#Install
install_env () {
    sudo apt-get update -y
    #7zip
    sudo apt-get install p7zip-full -y
    #java11
    sudo apt install default-jdk -y
    #python
    sudo apt-get install software-properties-common -y
    sudo add-apt-repository ppa:deadsnakes/ppa -y
    sudo apt-get update -y
    sudo apt-get install python3.8 -y
    #chromium
    sudo apt-get install chromium-browser
    #.net
    wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
    sudo dpkg -i packages-microsoft-prod.deb
    sudo apt-get update; \
    sudo apt-get install -y apt-transport-https && \
    sudo apt-get update && \
    sudo apt-get install -y dotnet-sdk-5.0
}

validation () {
    if [ $# -eq 0 ]; then
        echo "No params"
        exit 1
    fi
}

scriptMethod () {
case $1 in 
    "LIST")
        shift
        list_dir $1
    ;;
    "JSON")
        shift
        create_json $@
    ;;
    "INFO")
        shift
        system_info $@
    ;;
    "INSTALL")
        install_env 
    ;;
esac
}

validation $@
scriptMethod $@