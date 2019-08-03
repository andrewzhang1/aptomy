#!/usr/bin/ksh


disp_help()
{
	echo "\nDump execution record from platform record file.\n"
	echo "recdmp.sh [-h|-p[ <plat>]|-v] [-i|-r(*)|-a|-s <lst>] <ver> <bld>"
	echo " <ver>     : Version number to dump."
	echo " <bld>     : Build number to dump."
	echo " -h        : Display help."
	echo " -p        : Diaplay platform list."
	echo " -p <plat> : Define dump platform."
	echo " -v        : List version and build number in the <plat>.rec file."
	echo " -b        : List build number in the <plat>.rec file."
	echo " -i        : Dump I18N regression record."
	echo " -r        : Dump regular regression record."
	echo " -a        : Dump all recods in alphabeticaly order."
	echo " -s <lst>  : Script list for dump."
	echo ""
	if [ $# -ne 0 ]; then
	echo "Example)"
	echo "1) Display available version and help on this platform."
	echo "  recdmp.sh"
	echo "2) Display available build for zola on this paltform."
	echo "  recdmp.sh zola"
	echo "3) Dump regular reuslt for Zola Build 074 for this platform."
	echo "  recdmp.sh zola 074"
	echo "4) Dump I18N result for Zola Build 074."
	echo "  recdmp.sh -i zola 074"
	echo "5) Display availiable version on this platform."
	echo "  recdmp.sh -v"
	echo "6) Display availiable platform."
	echo "  recdmp.sh -p"
	echo "7) Display available version for hpux64."
	echo "  recdmp.sh -p hpux64 -v"
	echo "8) Diaplay all available version and build for solaris64."
	echo "  recdmp.sh -p solaris64 -b"
	echo "9) Dump all result for win32 platform for Zola build 074."
	echo "  recdmp.sh -p win32 zola 074"
	fi
}

disp_plat()
{
	echo "Avalable platforms:"
	ls $AUTOPILOT/mon/*.rec | while read line; do
		one=`basename $line`
		echo "  ${one%.*}"
	done
}

disp_bld()
{
	[ -z "$ver" ] && vtmp="version and build" || vtmp="build of $ver"
	echo "Recorded $vtmp for $plat."
	prevline=
	cat $AUTOPILOT/mon/${plat}.rec | awk -F'	' '{print $2":"$3}' | sort | while read line; do
		if [ -n "$ver" -a "${line#${ver}:}" = "$line" ]; then
			continue
		fi
		if [ "$prevline" != "$line" ]; then
			echo "  $line"
			prevline=$line
		fi
	done

}

disp_ver()
{
	echo "Recorded version for $plat."
	prevline=
	cat $AUTOPILOT/mon/${plat}.rec | awk -F'	' '{print $2}' | sort | while read line; do
		if [ "$prevline" != "$line" ]; then
			echo "  $line"
			prevline=$line
		fi
	done

}

i18n="i18n_j i18n_j_mlc i18n_i i18n_i_slc i18n_x i18n_xas"
reg="ori1 ori2 jlmain_sb 70main ukmain cwmain maxlmain jvmain jymain bkmain jlmain_sd jlmain_pb jlmain_pd barmain capitest kenmain"
orgpar=$@
plat=`get_platform.sh`
ver=
bld=
ord=$reg

if [ -z "$AUTOPILOT" ]; then
	echo "No \$AUTOPILOT defined."
	exit 10
fi

while [ $# -ne 0 ]; do
	case $1 in
		-h)
			disp_help with example
			exit 0
			;;
		-p)
			shift
			if [ $# -eq 0 ]; then
				disp_plat
				exit 1
			else
				plat=$1
			fi
			;;
		-v)
			disp_ver
			exit 0
			;;
		-b)
			disp_bld
			exit 0
			;;
		-i)
			ord=$i18n
			;;
		-r)
			ord=$reg
			;;
		-a)
			ord=all
			;;
		-s)
			shift
			if [ $# -eq 0 ]; then
				echo "\"-s\" nned second parameter."
				disp_help
			else
				ord=$1
			fi
			;;
		*)
			if [ -z "$ver" ]; then
				ver=$1
			elif [ -z "$bld" ]; then
				bld=$1
			else
				echo "Too many parameter."
				echo "current param:$orgpar"
				disp_help
				exit 2
			fi
			;;
	esac
	shift
done

if [ ! -f "$AUTOPILOT/mon/$plat.rec" ]; then
	echo "Couldn't find $plat.rec file under $AUTOPILOT folder."
	disp_plat
	disp_help
	exit 3
fi

if [ -z "$ver" -o -z "$bld" ]; then
	echo "Too few params:$orgpar"
	# disp_plat
	[ -z "$ver" ] && disp_ver || disp_bld
	disp_help
	exit 1
fi

tmpfile="$AUTOPILOT/tmp/${LOGNAME}@`hostname`_recdmp.tmp"
rm -f $tmpfile > /dev/null 2>&1

cat $AUTOPILOT/mon/${plat}.rec | grep "${ver}	${bld}" | awk -F'	' '{print $1"\t\t"$4"\t"$7"\t"$8"\t"$9"\t"$10}' > $tmpfile

if [ "$ord" = "all" ]; then
	sort $tmpfile
else
	for scr in $ord; do
		grep "^${scr}	" $tmpfile
		[ $? -ne 0 ] && echo $scr
	done
fi

rm -f $tmpfile > /dev/null 2>&1
