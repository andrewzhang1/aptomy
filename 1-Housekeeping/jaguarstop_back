#!/bin/bash

# 2018/01/23:
# Jon made the following update:

# 1) Able not enter passed (password already entered)
# 2) Able to find ip from the listening port specified in the server.conf.




#############################################################################
##  ./jaguarstop -s      # safe shutdown jaguar server on current host
##  ./jaguarstop         # unsafe shutdown jaguar server on current host
##                       # On Windows servers, it defaults to safesutdown
##  ./jaguarstop -f      # force shutdown jaguar server on current host
##  ./jaguarstop -all    # shutdown jaguar server on all hosts
##  ./jaguarstop -h      # show help menu
#############################################################################

. `dirname $0`/jaguarenv

g_hn=`hostname`
g_ips=""
g_un=`uname -o`
g_pass=""

if  [[ "x$g_un" = "xMsys" ]]; then
	g_jql="jql.exe"
else
	g_jql="jql.bin"
fi

function help()
{
	echo
	echo "$0      (unsafe shutdown of jaguar server on current host)"
	echo "$0 -s   (safe shutdown of jaguar server on current host)"
	echo "$0 -f   (force shutdown of jaguar server on current host)"
	echo "$0 -all (shutdown of jaguar server on ALL hosts in the cluster)"
	echo "$0 -h   (show this help menu)"
	echo
}

function localIPs()
{
	ipv4="[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}"
	loop="127.0.0.1"
	if [[ "x$g_un" = "xMsys" ]]; then
		g_ips=`ipconfig|grep -i addr|egrep "$ipv4"|grep -v "$loop"|awk -F: '{print $2}'`
	elif [[ "x$g_un" = "GNU/Linux" ]]; then
		g_ips=`/sbin/ifconfig|grep -i addr|egrep "$ipv4"|grep -v "$loop"|awk '{print $2}'|cut -d: -f2`
	else
		g_ips=`/sbin/ifconfig|grep -i addr|egrep "$ipv4"|grep -v "$loop"|awk '{print $2}'|cut -d: -f2`
	fi
}

### Wait for all data operations to finish on this server
### This command requires user to enter password
function safeShutDown()
{
	echo "Safe shutdown of jaguar server ..."
	localIPs
	iparr=($g_ips)
	numip=${#iparr[@]}
	target=$g_ips
    if ((numip==1)); then
    	echo "Shutting down jaguar server on $target ..."
    else
    	echo "There are multiple IP addresses on this host $g_hn:"
		echo "$g_ips"
        echo -n "Please enter an IP address: "
        read target
        if [[ "x$target" = "x" ]]; then
        	echo "No server IP address was provided, quit"
        	exit 1
        fi
    
    	echo "Shutting down jaguar server on $ip ..."
    fi

	port=`grep PORT $JAGUAR_HOME/conf/server.conf |grep -v '#' | awk -F= '{print $2}'`
	pass=$g_pass
	if [[ "x$pass" = "x" ]] ;then
		echo -n "Enter admin password: "
		read -s pass
	fi

	echo
	echo "OK, shutting down jaguar ..."
	$JAGUAR_HOME/bin/$g_jql -u admin -p $pass -h localhost:$port -cx yes -x yes -f no -m "shutdown $target;"
}

### Send SIGINT to server, let it properly shutdown
### This command does not require user to enter password
function unsafeShutDown()
{
	echo "Shutdown of jaguar server on current host $g_hn ..."
	echo "START" > $JAGUAR_HOME/log/shutdown.cmd
	kill -INT $pid  2>/dev/null
	while true
	do
		sleep 5
		val=`cat $JAGUAR_HOME/log/shutdown.cmd`
		if [[ "x$val" = "xSTART" ]]; then
			kill -9 $pid
			break
		elif [[ "x$val" = "xWIP" ]]; then
			if $JAGUAR_HOME/bin/jaguarstatus > /dev/null
			then
				continue
			else
				break
			fi
		else
			break
		fi
	done
}


### Just send SIGKILL to the server
### This command does not require user to enter password
function forceShutDown()
{
	echo "Force shutdown jaguar server on current host $g_hn ..."
	kill -9 $pid
}

### Send message to all servers and ask them to stop
### This command requires user to enter password
function allShutDown()
{
	echo "Shutdown all jaguar servers in the cluster ..."
	port=`grep PORT $JAGUAR_HOME/conf/server.conf |grep -v '#' | awk -F= '{print $2}'`
	pass=$g_pass
	if [[ "x$pass" = "x" ]]; then
		echo -n "Enter admin password: "
		read -s pass
	fi
	echo
	echo "OK, shutting down jaguar on all servers ..."
	$JAGUAR_HOME/bin/$g_jql -u admin -p $pass -h localhost:$port -cx yes -x yes -f no -m "shutdown all;"
}


##################### main #############################
echo
if [[ "x$pid" = "x" ]]; then
  	echo "Jaguar server is already shut down on current host $g_hn"
	date
	echo
   	exit 0
fi

##############

cmds=""
g_pass=""
i=0
for arg in "$@"
do
	((i=i+1))
    case $arg in
        "-p")
            ((i_next=i+1))
            if [ $i_next -le $# ]; then
                g_pass=${!i_next}
            else
				help
                exit 1
            fi
			;;
        "-s")
            cmds="-s"
            ;;
        "-f")
            cmds="-f"
            ;;
        "-all")
            cmds="-all"
            ;;
        "-help")
            help
            exit 1
            ;;
        "-h")
            help
            exit 1
            ;;
        *)
            ;;
    esac
done


if [[ "x$cmds" = "x-s" ]]; then
	safeShutDown
elif [[ "x$cmds" = "x-all" ]]; then
	allShutDown
elif [[ "x$cmds" = "x-f" ]]; then
	forceShutDown
elif [[ "x$cmds" = "x-h" ]]; then
	help
else
	if [[ "$g_un" = "Msys" ]]; then
		safeShutDown
	elif [[ "$g_un" = "Cygwin" ]]; then
		safeShutDown
	else
		unsafeShutDown
	fi
fi

date
echo



The following update:




/mnt/AGZ1/GD_AGZ1117/AGZ_Home/workspace_pOD/1_HouseKeeper
(azhang@vmlxu1)\>diff jaguarstop_back jaguarstop
17c17
< g_pass=""
---
> g_pass="jaguar"
61,68c61,73
<       echo "There are multiple IP addresses on this host $g_hn:"
<               echo "$g_ips"
<         echo -n "Please enter an IP address: "
<         read target
<         if [[ "x$target" = "x" ]]; then
<               echo "No server IP address was provided, quit"
<               exit 1
<         fi
---
>               lip=`grep LISTEN_IP $JAGUAR_HOME/conf/server.conf |grep -v '#' | awk -F= '{print $2}'`
>               if [[ "x$lip" = "x" ]]; then
>               echo "There are multiple IP addresses on this host $g_hn:"
>               echo "$g_ips"
>             echo -n "Please enter an IP address: "
>             read target
>             if [[ "x$target" = "x" ]]; then
>               echo "No server IP address was provided, quit"
>               exit 1
>             fi
>               else
>                       target=$lip
>               fi
70c75
<       echo "Shutting down jaguar server on $ip ..."
---
>       echo "Shutting down jaguar server on $target ..."
150c155
< g_pass=""
---
> #g_pass=""


