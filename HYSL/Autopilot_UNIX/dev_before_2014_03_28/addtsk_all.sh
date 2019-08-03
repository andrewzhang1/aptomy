#!/usr/bin/ksh
# 2011/02/15	YKono	First edition.
# 2013/02/18	YKono	Add parameter
#                       Bug 16358515 - ADDTSK_ALL.SH TO HAVE AN OPTION TO SPECIFY OS PLATFORMS

. apinc.sh

display_help()
{
	echo "addtsk_all.sh : Add tasks for all or specific platform."
	echo " Syntax: addtsk.sh [all|-h|-p <plat>|-o <opt>|-f <tskf>] <ver> <bld> [<plat>...]"
	echo " <ver> : version numner."
	echo " <bld> : build number."
	echo " <plat>: Platform to add."
	echo " <opt> : Task option."
	echo " <tskf>: Task definition file."
}

me=$0
opar=$@
plats=
ver=
bld=
opt=
tskf=
while [ $# -ne 0 ]; do
	case $1 in
		-h)	display_help;;
		-p)	if [ $# -lt 2 ]; then
				echo "${me##*/}:'-p' need second parameter."
				exit 2
			fi
			shift
			[ -z "$plats" ] && plats=$1 || plats="$plats $1"
			;;
		`isplat $1`)
			[ -z "$plats" ] && plats=$1 || plats="$plats $1"
			;;
		all)	plats=`isplat`;;
		-o)	if [ $# -lt 2 ]; then
				echo "${me##*/}:'-o' need second parameter."
				exit 1
			fi
			shift
			[ -z "$opt" ] && opt=$1 || opt="$opt $1"
			;;
		-f)	if [ $# -lt 2 ]; then
				echo "${me##*/}:'-f' need second parameter."
				exit 1
			fi
			tskf=$1
			;;
		*)	if [ -z "$ver" ]; then
				ver=$1
			elif [ -z "$bld" ]; then
				bld=$1
			else
				[ -z "$opt" ] && opt=$1 || opt="$opt $1"
			fi
			;;
	esac
	shift
done

if [ -z "$ver" ]; then
	echo "${me##*/}:This program need <ver> to add tasks."
	exit 1
fi

[ -z "$plats" ] && plats=`isplat`
[ -z "$bld" ] && bld="latest"
[ -z "$tskf" ] && t="NoTsk" || t="Tsk"
[ -z "$opt" ] && o="NoOpt" || o="Opt"
for p in $plats; do
	echo "# Add $ver:$bld for $p."
	case "${t}-${o}" in
		NoTsk-NoOpt)	addtsk.sh $p $ver $bld;;
		NoTsk-Opt)	addtsk.sh $p -o "$opt" $ver $bld;;
		Tsk-NoOpt)	addtsk.sh $p -f "$tskf" $ver $bld;;
		Tsk-Opt)	addtsk.sh $p -f "$tskf" -o "$opt" $ver $bld;;
	esac
done

