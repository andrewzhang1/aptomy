#!/usr/bin/ksh
# ckrcdate.sh : Check RC date for the version
# Syntax1: ckrcdate.sh $ver
#   Check the RC date for the $ver.
#   If there is no $ver in rcdate.txt, it just return 0.
#   When Today is over the RC date, this return 1
# Syntax2: ckrcdate.sh $ver $bld
#   Check the RC date for the $ver and if today is over
#   the RC date, this check the build string. And if build
#   is not started with "hit", this retunr 1 and error message.
# This program check the version number in the $AUTOPILOT/data/rcdate.txt
# or <current-snapshot>/essexer/autopilot/data/rcdate.txt and copare with
# today's date. If it is over, this return 1.
# History:
# 2013/06/28	YKono	First edition.

. apinc.sh
set_vardef	AP_RCDATEFLD
ver=
bld=
msg=
dbg=false
while [ $# -ne 0 ]; do
	case $1 in
		+d|-dbg)	dbg=true;;
		-d|-nodbg)	dbg=false;;
		*)	
			if [ -z "$ver" ]; then
				ver=$1
			elif [ -z "$bld" ]; then
				bld=$1
			else
				[ -z "$msg" ] && msg=$1 || msg="$msg $1"
			fi
			;;
	esac
	shift
done
if [ -z "$ver" ]; then
	[ "$dbg" = "true" ] && echo "### NEED VERSION NUMBER for CHECK ###"
	exit 0
fi

rcdt=`cat $AP_RCDATEFLD/rcdate.txt | grep "^${ver}:" | tail -1 | tr -d '\r'`
if [ -n "$rcdt" ]; then
	rcdt=${rcdt#*:}
	crrdt=`date +%Y/%m/%d`
	sts=`cmpstr $crrdt $rcdt`
	if [ "$sts" != "<" ]; then
		err="Over"
		if [ -n "$bld" ]; then
			[ "$bld" != "${bld#hit}" ] && err=false || err="None HIT build used after"
		fi
		if [ "$err" != "false" ]; then
			if [ "$err" != "Over" ]; then
				sendmail=true
				rcrec=$AUTOPILOT/mon/rcdate.rec
				crrdy=`date +%Y/%m/%d`
				if [ -f "$rcrec" ]; then
					ret=`cat $rcrec 2> /dev/null | grep "^${crrdy}:" | tail -1`
					[ -n "$ret" ] && sendmail=false
				fi
				if [ "$sendmail" = "true" ]; then
					# rm -f $rcrec
					echo "$crrdy:${LOGNAME}@`hostname` $ver $bld $msg(`date +%T`)" \
						>> $rcrec
					( 
						export VERSION=$ver
						export BUILD=$bld
						export MSG=$msg
						export RCDATE=$rcdt
						send_email.sh ev:$AUTOPILOT/form/29_RC_notifiation.txt
					)
				fi
			fi
			echo "### $err RC date ($crrdt $sts $rcdt) ###"
			exit 1
		fi
	else
		[ "$dbg" = "true" ] && echo "# Before RC date ($crrdt $sts $rcdt)."
	fi
else
	[ "$dbg" = "true" ] && echo "# No $ver definition in $AP_RCDATEFLD/rcdate.txt."
fi
exit 0

