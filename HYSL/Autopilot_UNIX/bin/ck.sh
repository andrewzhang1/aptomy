#!/usr/bin/ksh
# ck.sh : Check current folder contetns between AUTOPILOT and current snapshot.
# Description:
#     This command compare the files under $AUTOPILOT/<fld> and <crrsnap>/<fld>.
#     When define -d option, this command do:
#         $ diff $AUTOPILOT/<fld>/<file> <crrsnap>/<fld>/<file>
#     Then the delelted line mean it is new part in $AUTOPILOT/<fld> folder.
#     And added line mean old part remained in <crrsnap>/<fld>.
# Syntax:
#     ck.sh [-h|-v|-d] [<fld>]
# Parameter:
#   <fld> : The folder name to compare.
#           Default is bin.
# Option:
#   -h: Display help
#   -v: Verbose mode.
#       This mode display diff output between each files.
#   -d: Check date also
# History:
# 2012/05/05	YKono	First edition
# 2012/07/10	YKono	Fix syntax error.
# 2013/04/05	YKono	Support other AUTOPILOT folders.
# 2013/04/11	YKono	Cut CR when the platform is windows

me=$0
orgpar=$@

if [ -z "$BUILD_ROOT" ]; then
	echo "${me##*/}:\$BUILD_ROOT not defined."
	exit 1
fi
if [ ! -f "$BUILD_ROOT/common/bin/ap.sh" ]; then
	echo "${me##*/}:Couldn't access to the \$BUILD_ROOT/common/bin/ap.sh."
	echo "  BUILD_ROOT=$BUILD_ROOT"
	exit 1
fi
[ -n "$AP_SNAPROOT" -a -d "$AP_SNAPROOT" ] \
	&& snaploc=$AP_SNAPROOT \
	|| snaploc=${AUTOPILOT%/*/*}
crrsnap=`cat $BUILD_ROOT/common/bin/ap.sh 2> /dev/null | grep "Current bin=" | head -1`
crrsnap=${crrsnap#* bin=}
crrsnap=${crrsnap%%:*}
if [ -d "${snaploc}/${crrsnap}/vobs/essexer/autopilot" ]; then
	crrap="${snaploc}/${crrsnap}/vobs/essexer/autopilot"
elif [ -d "${snaploc}/${crrsnap}/essexer/autopilot" ]; then
	crrap="${snaploc}/${crrsnap}/essexer/autopilot"
else
	echo "${me##*/}:Failed to get current snapshot for autopilot framework."
	echo "  Please check the BUILD_ROOT, and snapshot location ?"
	echo "  BUILD_ROOT=$BUILD_ROOT"
	echo "  ap.sh loc =$BUILD_ROOT/common/bin/ap.sh"
	echo "  CrrSNAP   =$crrsnap # From ap.sh"
	echo "  SNAPROOT  =$snaploc"
	echo "  ExpectedAP=${snaploc}/${crrsnap}/essexer/autopilot"
	exit 1
fi

flds=
verbose=false
date=false
while [ $# -ne 0 ]; do
	case $1 in
		-v)	verbose=true ;;
		-d)	date=true ;;
		-h)	display_help.sh $me
			exit 0 ;;
		*)	if [ "$1" = "bin" ]; then
				if [ ! -d "${APBIN%/*}/bin" ]; then
					echo "${me##*/}:${APBIN%/*}/bin not found."
					exit 1
				elif [ ! -d "${AUTOPILOT}/dev" ]; then
					echo "${me##*/}:${AUTOPILOT}/dev/ not found."
					exit 1
				fi
			else
				if [ ! -d "$crrap/$1" ]; then
					echo "${me##*/}:$crrap/$1 not found."
					exit 1
				elif [ ! -d "${AUTOPILOT}/$1" ]; then
					echo "${me##*/}:${AUTOPILOT}/$1 not found."
					exit 1
				fi
			fi
			[ -z "$flds" ] && flds=$1 || flds="$flds $1"
			;;
	esac
	shift
done
[ -z "$flds" ] && flds="bin"

echo "### AP=$AUTOPILOT"
echo "### CC=$crrap"

for fld in $flds; do
	if [ "$fld" != "$flds" ]; then
		echo ""
		l=${#fld}; let l=l+8; s=
		while [ $l -ne 0 ]; do s="${s}#"; let l=l-1; done
		echo "$s"; echo "### $fld ###"; echo "$s"
	fi
	[ "$fld" = "bin" ] && f0=dev || f0=$fld
	cd $AUTOPILOT/$f0
	ls | while read one; do
		if [ -d "$one" ]; then
			echo "# $one is folder. Skip this."
		elif [ -f "${crrap}/$fld/$one" ]; then
			srcf=$HOME/.ck.srcf
			trgf=$HOME/.ck.trgf
			cat $one 2> /dev/null | tr -d '\r' > $srcf
			cat ${crrap}/$fld/$one 2> /dev/null | tr -d '\r' > $trgf
			ckdev=`cksum $srcf 2> /dev/null`
			ckbin=`cksum $trgf 2> /dev/null`
			szdev=`echo $ckdev | awk '{print $2}'`
			szbin=`echo $ckbin | awk '{print $2}'`
			ckdev=${ckdev%% *}
			ckbin=${ckbin%% *}
			dev="$szdev,$ckdev"
			bin="$szbin,$ckbin"
			if [ "$date" = "true" ]; then
				dtdev=`ls -l $one | awk '{print $6,$7,$8}'`
				dtbin=`ls -l ${crrap}/$fld/$one | awk '{print $6,$7,$8}'`
				dev="$dev,$dtdev"
				bin="$bin,$dtbin"
			fi
			if [ "$dev" != "$bin" ]; then
				echo "$one AP/$f0($dev) != CC/$fld($bin)"
				if [ "$verbose" = "true" ]; then
					(IFS=; diff $srcf $trgf 2>&1 | while read line; do echo "    $line"; done)
				fi
			fi
			rm -f $srcf 2> /dev/null
			rm -f $trgf 2> /dev/null
		else
			echo "# Missing $one in CC/$fld"
		fi
	done
done

