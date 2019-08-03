#!/usr/bin/ksh
#
# addtsk.sh : add task to the task queue
# 
# History:
# 04/08/2008 YKono - First edition
# 04/22/2008 YKono - Add parser information into task file.
# 06/03/2008 YKono - Change syntax
# 06/19/2008 YKono - Add "myself" option
# 08/06/2008 YKono - Use parse_one_task.sh
# 04/09/2009 YKono - Add task order priority
# 07/02/2009 YKono - Add AP format output and read&parse lock
# 07/29/2009 YKono - Fix Unix string compare problem
# 05/17/2010 YKono - Add script priority column.
# 07/14/2010 YKono - Allow null parameter for the build number.
#            addtsk.sh takes the latest build when build# is skipped.
# 12/12/2012 YKono - Add linuxx64exa
# 04/02/2013 YKono - Support <ver>:<bld> for the version name
# 05/15/2013 YKono - BUG 16571195 - PUT TASK FILES IN CLEARCASE

. apinc.sh
set_vardef=
set_vardef AP_TSKFLD

disp_help()
{
	#     0         1         2         3         4         5         6         7
	#     01234567890123456789012345678901234567890123456789012345678901234567890123456789
	echo "Add task to the task queue."
	echo ""
	echo "Syntax:"
	echo "  addtsk.sh [-i|-f <scrlst>|-d|-o <aopt>|-order <n>|<plat>|<node>|-m|-mp|-ap]"
	echo "            [-h|-help] <ver> [ <bld> [<test>]]"
	echo "Parameter:"
	echo " -h    : Display this help."
	echo " -help : Display this help with example."
	echo " -i    : Ignore done-recodes in the done buffer. Forcely add this task."
	echo " -o    : Define additional task option, <aopt>, to this task."
	echo " -order: Use <n>th script order in that build."
	echo " -f    : Use <scrlst> for the adding tasks."
	echo "         <scrlst> file only contain the name of the test scripts to execute."
	echo "         Each test script are added with <ver> <bld> information."
	echo " -d    : Add task as a disable mode."
	echo " <plat>: Target platform for the adding task. You can use following names:"
	echo "           win32, win64, winamd64, solaris, solaris64, solaris.x64, "
	echo "           aix, aix64, hpux, hpux64, linux, linuxamd64, linuxx64exa"
	echo " <node>: Target node definition for the adding task."
	echo "         The node parameter is construct by the account and the machine name."
	echo "           <node> := <user name>@<machine name>"
	echo "         If you want to add a task for another machine or user, you can define"
	echo "         this node by the target user on the target machine."
	echo "         Note: When you skip this parameter, the current user and machine name"
	echo "               will be used for it \$AP_NOPLAT isn't defined. When \$AP_NOPLAT"
	echo "               is set to \"false\", the current platformm will be used for it."
	echo " -m    : Using a current user and machine for the added task."
	echo " -mp   : Using a current platform as the target platform for the added task."
	echo " -ap   : AP format output."
	echo " <ver> : Essbase version number for this task."
	echo " <bld> : Essbase build number for this task."
	echo "         When you skip this parameter, addtsk.sh use \"HIT(latest)\" for the HIT"
	echo "         supported versions, or \"latest\" for other versions."
	echo " <test>: Test script."
	echo "         When the test need some parameters like agtpjlmain.sh, you need to"
	echo "         quote this parameter like below:"
	echo "           ex.) addtsk.sh dickens 090 \"agtpjlmain.sh parallel buffer\""
	echo "         Or use \"+\" instead of the space characger like below:"
	echo "           ex.) addtsk.sh dickens 090 agtpjlmain.sh+parallel+buffer"
	echo ""
	if [ -n "$1" ]; then
		echo "Example:"
		echo ""
		echo "1) Add agtpori1.sh for zola 122 on win32 platform."
		echo ""
		echo "     \$ addtsk.sh win32 zola 122 agtpori1.sh"
		echo "     ..."
		echo ""
		echo "     \$ lstsk.sh"
		echo "     0100    zola    122     agtpori1.sh     win32   Enable"
		echo ""
		echo "2) Add the tests defined in hpux64.tsk file for zola 122 on hpux64 machine."
		echo ""
		echo "     \$ cat \$AUTOPILOT/tsk/hpux64.tsk"
		echo "     zola:latest:agtpori1.sh:schedule(Mon Thu)"
		echo "     zola:latest:agtpori2.sh:schedule(Mon Thu)"
		echo "     zola:latest:agtpjlmain.sh serial direct:schedule(Mon Thu)"
		echo "     zola:latest:agtpbarmain.sh:schedule(Mon Thu)"
		echo ""
		echo "   With this task file, following command add 4 tasks with Zola 122."
		echo ""
		echo "     \$ addtsk.sh zola 122  # execute on hpux64 machine with AP_NOPLAT=false"
		echo "     ..."
		echo ""
		echo "     \$ lstsk.sh hpux64"
		echo "     0100    zola    122     agtpori1.sh     hpux64  Enable"
		echo "     0101    zola    122     agtpori2.sh     hpux64  Enable"
		echo "     0102    zola    122     agtpjlmain.sh serial direct     hpux64  Enable"
		echo "     0103    zola    122     agtpbarmain.sh  hpux64  Enable"
		echo ""
		echo "   When the task definition file contains multiple entry for one version,"
		echo "   you can define the version with the build number like below:"
		echo "     \$ cat hpux64.tsk"
		echo "     11.1.2.3.000:latest:maxlmain.sh:opackver(!bi)"
		echo "     11.1.2.3.000:hit(latest):maxlmain.sh:tag(_hit)"
		echo "     ..."
                echo "   Following command add task for 11.1.2.3.000:latest:"
		echo "     \$ addtsk.sh 11.1.2.3.000:la latest"
		echo "   And following command add task for 11.1.2.3.000:hit(latest):"
                echo "     \$ addtsk.sh 11.1.2.3.000:hit hit[latest]"
		echo ""
		echo "3) Add tasks using script list."
		echo "   Following example will add the tasks with Talleyrand 153 for each scripts"
		echo "   in the script list files."
		echo ""
		echo "     \$ cat ./testscripts.txt"
		echo "     93139main.sh"
		echo "     93139main.sh 35"
		echo "     93139main.sh 36 37"
		echo ""
		echo "     \$ addtsk.sh -f ./testscripts.txt -m talleyrand 153 # regryk1 on stnti23"
		echo "        ..."
		echo ""
		echo "     \$ lstsk.sh"
		echo "     0100    talleyrand      153     93139main.sh    regryk1@stnti23 Enable"
		echo "     0101    talleyrand      153     93139main.sh 35 regryk1@stnti23 Enable"
		echo "     0102    talleyrand      153     93139main.sh 36 37  regryk1@stnti23 Enable"
		echo ""
		echo "4) Add tasks using version controled script list file."
		echo "   When the script list file contains \"#From <ver>\" line, this script compare"
		echo "   the target version number and <ver>. And if <ver> is greater than the target"
		echo "   version number, adding task will stop at that line."
		echo ""
		echo "     \$ cat ./testscripts.txt"
		echo "     # Vesion controled script list file."
		echo "     agtpori1.sh"
		echo "     agtpori2.sh"
		echo "     #From barnes"
		echo "     agtpbarmain.sh"
		echo "     #from kennedy"
		echo "     agtpkenmain.sh"
		echo ""
		echo "     \$ addtsk.sh -f ./testscripts.txt -m 9.3.1.4.1 001 # regryk1 on stnti23"
		echo "        ..."
		echo ""
		echo "     \$ lstsk.sh"
		echo "     0100    9.3.1.4.1      001     agtpori1.sh     regryk1@stnti23 Enable"
		echo "     0101    9.3.1.4.1      001     agtpori2.sh     regryk1@stnti23 Enable"
		echo "     0102    9.3.1.4.1      001     agtpbarmain.sh  regryk1@stnti23 Enable"
		echo ""
		echo "   Note: the script files after \"#from kennedy\" are ignored with 9.3.1.4.0."
		echo "   If you define the zola for the target version, all script will be parsed."
	fi
}


### MAIN START AT HERE

if [ "$AP_NOPLAT" = "false" ]; then
	plat="${plat}"
	platkind=plat
else
	plat="${LOGNAME}@`hostname`"
	platkind=node
fi
orgpar=$@
unset ver bld tst tskf addopt mode ofs srchver
outfrm=norm
while [ $# -ne 0 ]; do
	case $1 in
		-h)
			disp_help
			exit 0
			;;
		-help)
			disp_help with sample
			exit 0
			;;
		-f|-t)
			shift
			if [ $# -eq 0 ]; then
				echo "Paramter error: -f or -t option need <scrlst> parameter."
				display_help
				exit 1
			fi
			tskf=$1
			;;
		-i)
			if [ -z "$addopt" ]; then
				addopt="igndone(true)"
			else
				addopt="$addopt igndone(true)"
			fi
			;;
		-o)
			shift
			if [ $# -eq 0 ]; then
				echo "Paramter error: -o option need <aopt> parameter."
				display_help
				exit 1
			fi
			if [ -z "$addopt" ]; then
				addopt="$1"
			else
				addopt="$addopt $1"
			fi
			;;
		-d)
			mode="-d"
			;;
		-m|me|myself)
			plat=${node}
			platkind=node
			;;
		-mp|plat|myplat)
			plat=`get_platform.sh -l`
			platkind=plat
			;;
		`isplat $1`)
			plat=$1
			platkind=plat
			;;
		-order)
			shift
			if [ $# -eq 0 ]; then
				echo "Paramter error: -order option need <n> parameter."
				display_help
				exit 1
			fi
			ofs=$1
			;;
		-ap)
			outfrm=apform
			;;
		*@*)
			plat=$1
			platkind=node
			;;
		*\.sh*|*\.ksh*)
			tst=$1
			;;
		*)
			if [ -z "$ver" ]; then
				ver=$1
				if [ "${ver#*:}" != "$ver" ]; then
					srchver=$ver
					ver=${ver#*:}
				else
					srchver="${ver}:"
				fi
			elif [ -z "$bld" ]; then
				bld=$1
			elif [ -z "$tst" ]; then
				tst=$1
			else
				echo "Too many parameters."
				exit 1
			fi
			;;
	esac
	shift
done

# Error check
if [ -z "$ver" ]; then
	echo "Too few parameter."
	echo "$0 need at least <ver> <bld>."
	if [ "$platkind" = "node" ]; then
		echo "<node>=$plat"
	else
		echo "<plat>=$plat"
	fi
	echo "<ver> =$ver"
	echo "<bld> =$bld"
	echo "<test>=$tst"
	echo "<tskf>=$tskf"
	echo "<aopt>=$addopt"
	disp_help
	exit 1
fi
if [ -z "$bld" ]; then
	tmp_hloc=`ver_hitloc.sh $ver`
	if [ "$tmp_hloc" = "not_ready" ]; then
		bld="latest"
	else
		bld="hit[latest]"
	fi
fi

# Check RC date
ret=`ckrcdate.sh $ver $bld "by addtsk.sh $orgpar"`
if [ $? -ne 0 ]; then
	echo "addtsk.sh: $ret"
	echo "Today(`date +%Y/%m/%d`) is over the RC date."
	echo "You can only add task which uses HIT installer after RC date."
	exit 1
fi

if [ -z "$tst" ]; then
	if [ -n "$tskf" ]; then
		[ "${tskf#*/}" = "$tskf" ] && \
			tskf=$AP_TSKFLD/$tskf
		tskfkind="list"
	else
		if [ "$platkind" = "node" ]; then
			tskf=$AP_TSKFLD/${plat%@*}.tsk
			tskfkind="personal"
		else
			tskf=$AP_TSKFLD/${plat}.tsk
			tskfkind="platform"
		fi
	fi
	if [ ! -f "$tskf" ]; then
		echo "addtsk.sh: $tskf not found."
		exit 1
	fi
fi

#	if [ "$platkind" = "node" ]; then
#		echo "<node>=$plat"
#	else
#		echo "<plat>=$plat"
#	fi
#	echo "<ver> =$ver"
#	echo "<bld> =$bld"
#	echo "<test>=$tst"
#	echo "<tsfk>=$tskfkind"
#	echo "<tskf>=$tskf"
#	echo "<aopt>=$addopt"

[ "$outfrm" = "norm" ] && echo "$platkind $plat"
# Decide read lock mode. (all, <plat>, <node>)
case $plat in
	*@*)
		if [ "${plat}" = "${plat#*\*}" -a "${plat}" = "${plat#*\?}" ]; then
			lckkind=$plat
		else
			lckkind=all
		fi
		;;
	`isplat $1`)
	# win32|win64|winamd64|hpux|hpux64|aix|aix64|solaris|solaris64|solaris.x64|linux|linuxamd64|linux64)
		lckkind=$plat
		;;
	*)
		lckkind=all
		;;
esac

# Read Lock
trg=$AUTOPILOT/lck/${lckkind}.read
cnt=60
while [ $cnt -ne 0 ]; do
	pid=`lock.sh $trg $$ 2> /dev/null`
	if [ $? -ne 0 ]; then
		echo "addtsk.sh:Failed to lock $trg."
		cat $trg.lck 2> /dev/null | while read line; do
			echo " > $line"
		done
		let cnt="$cnt-1"
		echo "  wait 5 secs..."
		sleep 5
	else
		cnt=99
		break
	fi
done
if [ $cnt -eq 0 ]; then
	echo "Failed to lock $trg."
	exit 4
fi

# echo "Read Lock=$trg.lck"
# cat $trg.lck | while read line; do
# 	echo " # $line"
# done

# Parse lock
prs=$AUTOPILOT/lck/${lckkind}.parse
cnt=60
while [ $cnt -ne 0 ]; do
	pid=`lock.sh $prs $$ 2> /dev/null`
	if [ $? -ne 0 ]; then
		echo "addtsk.sh:Failed to lock $prs."
		cat $prs.lck 2> /dev/null | while read line; do
			echo " > $line"
		done
		let cnt="$cnt-1"
		echo "  wait 5 secs..."
		sleep 5
	else
		cnt=99
		break
	fi
done
if [ $cnt -eq 0 ]; then
	echo "Failed to lock $prs."
	unlock.sh $trg
	exit 4
fi

# echo "Parse Lock=$prs.lck"
# cat $prs.lck | while read line; do
# 	echo " # $line"
# done

addcnt=0
errcnt=0
if [ -z "$tst" ]; then
	tsktmp="$AUTOPILOT/tmp/${node}_addtsk.tmp"
	rm -f $tsktmp > /dev/null 2>&1
	if [ "$tskfkind" = "personal" ]; then
		cat $tskf 2> /dev/null | grep "^${plat#*@}:${srchver}" \
			| sed -e "s/^[^:]*://g" | sed -e "s/^\(${ver}:\)[^:]*:/\1${bld}:/g" \
			| tr -d '\r' | while read line; do
			echo "${tskf},$line" >> $tsktmp
		done
	elif [ "$tskfkind" = "platform" ]; then
		cat $tskf | grep "^${srchver}" \
			| sed -e "s/^\(${ver}:\)[^:]*:/\1${bld}:/g" \
			| tr -d '\r' | while read line; do
			echo "${tskf},$line" >> $tsktmp
		done
		if [ -f "$AP_TSKFLD/all.tsk" ]; then
			cat $AP_TSKFLD/all.tsk | grep "^${srchver}" \
				| sed -e "s/^\(${ver}:\)[^:]*:/\1${bld}:/g" \
				| tr -d '\r' | while read line; do
				echo "$AP_TSKFLD/all.tsk,$line" >> $tsktmp
			done
		fi
	else
		fromctl=$(
			crrvn=`ver_vernum.sh ${ver}`
			cat ${tskf} | egrep -n -i ^#from | tr -d '\r' | while read line ver; do
				vn=`ver_vernum.sh $ver`
				ln=${line%%\:*}
				sts=`cmpstr "${crrvn}" "${vn}"`
				if [ "$sts" = "<" ]; then
					echo "$ln"
					break
				fi
			done)
		if [ -z "$fromctl" ]; then
			cat $tskf | grep -v ^# | grep -v ^$ | while read line; do
				echo "${tskf},${ver}:${bld}:$line" >> $tsktmp
			done
		else
			cat $tskf | head -n $fromctl | grep -v ^# | grep -v ^$ | while read line; do
				echo "${tskf},${ver}:${bld}:$line" >> $tsktmp
			done
		fi
	fi
	[ -z "$ofs" ] && ofs=100
	while read line; do
		tskf=${line%%,*}
		line=${line#*,}
		if [ -n "$line" ]; then
			_pp=`chk_para.sh priority "${line}"`
			_pp=${_pp%% *}
			if [ -z "$_pp" -o "$_pp" -lt "900" ]; then
				let ordofs="$addcnt + $ofs"
				ordofs="order=$ordofs"
				if [ "$outfrm" = "norm" ]; then
					parse_one_task.sh $mode "$plat" "$line" \
						"from addtsk.sh using $tskf" "$addopt" ${ordofs}
				else
					parse_one_task.sh $mode "$plat" "$line" \
						"from addtsk.sh using $tskf" "$addopt" ${ordofs} > /dev/null 2>&1
				fi
				[ $? -eq 0 ] && let addcnt=addcnt+1 || let errcnt=errcnt+1
			fi # _pp < 900
		fi
	done < $tsktmp
	rm -f $tsktmp > /dev/null 2>&1
else
	if [ -n "$ofs" ]; then
		let ordofs="$addcnt + $ofs"
		ordofs="order=$ordofs"
	else
		unset ordofs
	fi
	if [ "$outfrm" = "norm" ]; then
		parse_one_task.sh $mode "$plat" "${ver}:${bld}:${tst}" \
			"from addtsk.sh" "$addopt" "$ordofs"
	else
		parse_one_task.sh $mode "$plat" "${ver}:${bld}:${tst}" \
			"from addtsk.sh" "$addopt" "$ordofs" > /dev/null 2>&1
	fi
	[ $? -eq 0 ] && let addcnt=addcnt+1 || let errcnt=errcnt+1
fi

unlock.sh $prs > /dev/null 2>&1
unlock.sh $trg > /dev/null 2>&1

if [ "$outfrm" = "norm" ]; then
	if [ $addcnt -gt 1 ]; then
		msg="${addcnt} tasks added."
	elif [ $addcnt -eq 0 ]; then
		msg="No task is added."
	else
		msg="One task added."
	fi

	if [ $errcnt -gt 1 ]; then
		msg="${msg} And $errcnt tasks skipped."
	elif [ $errcnt -eq 1 ]; then
		msg="${msg} And one task skipped."
	fi
	echo $msg
else
	echo "true"
fi

exit 0

### THIS LINE IS BOTTOM
