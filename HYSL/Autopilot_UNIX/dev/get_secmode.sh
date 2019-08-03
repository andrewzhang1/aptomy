#/usr/bin/ksh
# get_secmode.sh : Get current security mode
# History:
# 2013/05/21 YK First edition.
# 2013/08/27 YK Add -ext option

disp=normal
[ "$1" = "-ext" ] && disp=ext

case $AP_SECMODE in
	hss)	secmode=HSS;;
	fa)	secmode=FA;;
	rep|bi)	secmode=BI;;
	*)
		if [ "${HYPERION_HOME%Oracle_BI1}" != "$HYPERION_HOME" ]; then
			hh=${HYPERION_HOME%/Oracle_BI1}
			hh=${hh#*/}
			if [ -n "`echo $hh | grep BI`" ]; then
				secmode="BI-Native"
			else
				secmode="FA-Native"
			fi
		else
			secmode="EPM-Native"
		fi
		;;
esac

if [ "$disp" = "ext" ]; then
	case $secmode in
		HSS|FA|BI)	echo "_`echo $secmode | tr A-Z a-z`";;
		*)	;;
	esac
else
	echo $secmode
fi

