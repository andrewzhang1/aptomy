#!/usr/bin/ksh
# monitor.sh : Monitor the memory and disk usage
# Description:
#    This script monitor current memory max and disk usage
#    for ARBORPATH/app and SXR_VIEWHOME folder.
#    And when ctl+C or $HOME/stop.req file will be created,
#    display the usage of memory and disk or write to <result>.
#    Result format:
#         mem=###(###KB) app=###(###KB) view=###(###KB) ttl=###(###KB)
# Note:
#    This scrip shoud work under the "sxr goview" environemnt and
#    Essbase runable environment.
#    Those mean your environment should have ARBORPATH and SXR_VIEWHOME
#    definitions.
# Syntax: monitor.sh [-r <result>|-l <log>|-w <wait>]
# Options:
#   -r <reuslt> : Result output file name.
#                 When you skip this parameter, this sript
#                 write the result to stdio.
#   -l <log>    : Log output file name.
#                 When you skip this parameter, this sript
#                 write the log to stdio.
#   -h          : Display this.
#   -w <wait>   : Interval time.
#                 When you skip this parameter, use 30 second as interval.
# History:
# 2012/02/08	YKono	First Edition (Windwos only)
# 2012/10/26	YKono	Add linux

# if [ "`uname`" != "Windows_NT" ]; then
#	echo "This script only support windows platform."
#	exit 1
#fi

comm=","
minmem=
maxmem=
minapp=
maxapp=
mixview=
maxview=
stopf=$HOME/stop.req

disp_result() {
	let mem=maxmem-minmem
	let app=maxapp-minapp
	let view=maxview-minview
	let ttl=app+view
	if [ -z "$result" ]; then
		echo "mem=`num $mem`(`num -u $mem`)" \
		     "app=`num $app`(`num -u $app`)" \
                     "view=`num $view`(`num -u $view`)" \
		     "ttl=`num $ttl`(`num -u $view`)"
	else
		echo "mem=`num $mem`(`num -u $mem`)" \
		     "app=`num $app`(`num -u $app`)" \
                     "view=`num $view`(`num -u $view`)" \
		     "ttl=`num $ttl`(`num -u $ttl`)" >> "$result"
	fi
	rm -rf $stopf 2> /dev/null
}

# num <numeric> [+c|-c|+u|-u]
num()
{
	commsep=true
	unitf=true
	while [ $# -ne 0 ]; do
		case $1 in
			+c)	commsep=true;;
			+u)	unitf=true;;
			-c)	commsep=false;;
			-u)	unitf=false;;
			*)	val=$1;;
		esac
		shift
	done
	r=
	unit="KB"
	if [ "$unitf" = "true" ]; then
		if [ $val -gt 1024 ]; then
			unit="MB"
			let r=val-val/1024\*1024
			let val=val/1024
		fi
		if [ $val -gt 1024 ]; then
			unit="GB"
			let r=val-val/1024\*1024
			let val=val/1024
		fi
		if [ -n "$r" ]; then
			let r=r\*100/1024
			r="00$r"
			r=".${r#${r%??}}"
		fi
	fi
	if  [ "$commsep" = "true" ]; then
		n=
		while [ -n "$val" ]; do
			v=${val#${val%???}}
			if [ -z "$v" ]; then
				[ -z "$n" ] && n=$val || n="${val}${comm}${n}"
				break
			fi
			[ -z "$n" ] && n=$v || n="${v}${comm}${n}"
			val=${val%???}
		done
		val=$n
	fi
	print -n "${val}${r}${unit}"
}

		
if [ -z "$ARBORPATH" ]; then
	echo "Plase define \$ARBORPATH"
	exit 2
fi
if [ -z "$SXR_VIEWHOME" ]; then
	echo "Please execute \"sxr goview <view>\" command."
	exit 3
fi

log=
result=
intval=30
me=$0
orgpar=$@
crr=`perl -e 'print time;'`
while [ $# -ne 0 ]; do
	case $1 in
		-lr|-rl)
			if [ $# -lt 1 ]; then
				echo "$1 need a log file name."
				exit 1
			fi
			shift
			log=$1
			result=$1
			;;
		-l)
			if [ $# -lt 1 ]; then
				echo "$1 need a log file name."
				exit 1
			fi
			shift
			log=$1
			;;
		-r)
			if [ $# -lt 1 ]; then
				echo "$1 need a result file name."
				exit 1
			fi
			shift
			result=$1
			;;
		-w)
			if [ $# -lt 1 ]; then
				echo "$1 need an interval time by second."
				exit 1
			fi
			shift
			intval=$1
			;;
		-h)
			display_help.sh $me
			exit 0
			;;
		*)
			echo "Syntax error."
			exit 1
			;;
	esac
	shift
done
		
app_path=$ARBORPATH/app
view_path=$SXR_VIEWHOME

trap 'echo "ctl+C"; disp_result; exit 0' 2


prev=0
while [ ! -f "$stopf" ]; do
	crr=`perl -e 'print time;'`
	let df=crr-prev
	if [ $df -ge $intval ]; then
		prev=$crr
		ts=`date +%D_%T`
		case `uname` in
        		Windows_NT)     mem=`psusage -k -t | awk '{print $10}'`;;
        		Linux)          mem=`free | grep ^Mem | awk '{print $3}'`;;
			HP-UX)		mem=`top -d 1 | grep Memory | awk '{print $2}'`
					mem=${mem%?};;
        		*)		mem=0;;
		esac
		appf=`du -ks $app_path | awk '{print $1}'`
		viewf=`du -ks $view_path | awk '{print $1}'`
		[ -z "$minmem" ] && minmem=$mem \
			|| [ $minmem -gt $mem ] && minmem=$mem
		[ -z "$maxmem" ] && maxmem=$mem \
			|| [ $maxmem -lt $mem ] && maxmem=$mem
		[ -z "$minapp" ] && minapp=$appf \
			|| [ $minapp -gt $appf ] && minapp=$appf
		[ -z "$maxapp" ] && maxapp=$appf \
			|| [ $maxapp -lt $appf ] && maxapp=$appf
		[ -z "$minview" ] && minview=$viewf \
			|| [ $minview -gt $viewf ] && minview=$viewf
		[ -z "$maxview" ] && maxview=$viewf \
			|| [ $maxview -lt $viewf ] && maxview=$viewf
		if [ -z "$log" ]; then
			echo "$ts" \
			"mem=`num -u $mem`" \
			"app=`num -u $appf`" \
			"view=`num -u $viewf`" \
			"(`num $minmem`-`num $maxmem`,`num $minapp`-`num $maxapp`,`num $minview`-`num $maxview`)"
		else
			echo "$ts" \
			"mem=`num -u $mem`" \
			"app=`num -u $appf`" \
			"view=`num -u $viewf`" \
			"( `num $minmem`-`num $maxmem` `num $minapp`-`num $maxapp` `num $minview`-`num $maxview` )" \
				>> "$log"
		fi
	fi
done
disp_result
exit 0
