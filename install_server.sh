#! /bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin:$PATH
export PATH

__INTERACTIVE=""
if [ -t 1 ] ; then
    __INTERACTIVE="1"
fi

__green(){
    if [ "$__INTERACTIVE" ] ; then
        printf '\033[1;31;32m'
    fi
    printf -- "$1"
    if [ "$__INTERACTIVE" ] ; then
        printf '\033[0m'
    fi
}

__red(){
    if [ "$__INTERACTIVE" ] ; then
        printf '\033[1;31;40m'
    fi
    printf -- "$1"
    if [ "$__INTERACTIVE" ] ; then
        printf '\033[0m'
    fi
}

__yellow(){
    if [ "$__INTERACTIVE" ] ; then
        printf '\033[1;31;33m'
    fi
    printf -- "$1"
    if [ "$__INTERACTIVE" ] ; then
        printf '\033[0m'
    fi
}

rand(){
    index=0
    str=""
    for i in {a..z}; do arr[index]=${i}; index=`expr ${index} + 1`; done
    for i in {A..Z}; do arr[index]=${i}; index=`expr ${index} + 1`; done
    for i in {0..9}; do arr[index]=${i}; index=`expr ${index} + 1`; done
    for i in {1..10}; do str="$str${arr[$RANDOM%$index]}"; done
    echo ${str}
}

function rootness(){
if [[ $EUID -ne 0 ]]; then
   echo "Error:请使用root运行本程序" 1>&2
   exit 1
fi
}

function get_system(){
    if grep -Eqi "CentOS" /etc/issue || grep -Eq "CentOS" /etc/*-release; then
        system_str="0"
    elif  grep -Eqi "Ubuntu" /etc/issue || grep -Eq "Ubuntu" /etc/*-release; then
        system_str="1"
    elif  grep -Eqi "Debian" /etc/issue || grep -Eq "Debian" /etc/*-release; then
        system_str="1"
    elif  grep -Eqi "Raspbian" /etc/issue || grep -Eq "Raspbian" /etc/*-release; then
        system_str="1"
    else
        echo "This Script must be running at the CentOS or Ubuntu or Debian!"
        exit 1
    fi
}

function yum_install(){
    if [ "$system_str" = "0" ]; then
    #yum -y update
    yum -y install docker
    else
    apt-get install docker -y
    fi
}

function docker_init() {
	fileFolder=`rand`
    docker pull nginx
    mkdir -p /home/docker-nginx-${fileFolder}/file
    mkdir -p /home/docker-nginx-${fileFolder}/log
    echo "hello nginx-${fileFolder}" > /home/docker-nginx-${fileFolder}/file/index.html
    docker run -itd --name nginx-${fileFolder} -p 8899:80 -v /home/docker-nginx-${fileFolder}/file:/usr/share/nginx/html -v /home/docker-nginx-${fileFolder}/log:/var/log/nginx nginx
}

function get_my_ip(){
  	all_ips=$(hostname -I) 
		localIP=${all_ips%% *}
    echo "Preparing, Please wait a moment..."
    IP=`curl -s checkip.dyndns.com | cut -d' ' -f 6  | cut -d'<' -f 1`
    if [ -z $IP ]; then
        IP=`curl -s ifconfig.me/ip`
    fi
}

function success_info(){
    echo "#############################################################"
    echo -e "#"
    echo -e "# [$(__green "安装完成")]"
    echo -e "#"
    echo -e "# 请将提供的包名文件夹解压放置在:$(__green " /home/docker-nginx-${fileFolder}/file") 目录下"
    echo -e "------------------------"
    echo -e "# 访问日志输出文件位置在:$(__green " /home/docker-nginx-${fileFolder}/log") 目录下"
    echo -e "------------------------"
	echo -e "# 注意: $(__red "云服务安全组需开启8899端口。需将公网ip提供给我们，ip用于配置到域名供应商。")"
    echo -e "------------------------"
    echo -e "# 远程地址:$(__green "curl http://${IP}:8899")，测试是否有内容。"
    echo -e "# 局域网地址:$(__green "curl http://${localIP}:8899")，测试是否有内容。"
    echo -e "#############################################################"
    echo -e ""
}

function install(){
	rootness
	get_system
	yum_install
	docker_init
	get_my_ip
	success_info
}

install
