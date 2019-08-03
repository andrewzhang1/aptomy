#!/usr/bin/ksh
########################################################################
# stop_service.sh : Start EPM or BI services
########################################################################
# Syntax: stop_service.sh [-h]
# Description:
#   This script top WebLogic service.
# Options:
#   -h       : Display help
# Exit status:
#   0 : Stop fine.
#   1 : Syntax error
#   2 : Failed to stop
########################################################################
# History:
# 12/12/2012 YKono	First edition.

. apinc.sh
me=$0
orgpar=$@
while [ $# -ne 0 ]; do
	case $1 in
		-h)
			display_help.sh $me
			exit
			;;
	esac
	shift
done
ret=0
case $AP_SECMODE in
	hss)
		if [ -d "$ORACLE_INSTANCE" ]; then
			if [ `uname` = "Windows_NT" ]; then
				prg=stopFoundationServices.bat
			else
				prg=stopFoundationServices.sh
			fi
			if [ -f "$ORACLE_INSTANCE/bin/$prg" ]; then
				$ORACLE_INSTANCE/bin/$prg
			fi
		fi
		;;
	fa|rep|bi)
		if [ -d "$ORACLE_INSTANCE" ]; then
			inst=$ORACLE_INSTANCE
		else
			crr=`pwd`
			cd $HYPERION_HOME/../instances 2> /dev/null
			inst=`ls -1r | grep ^instance 2> /dev/null | head -1`
			if [ -z "$inst" ]; then
				inst="${HYPERION_HOME%/*}/instances/instance1"
			else
				inst="${HYPERION_HOME%/*}/instances/$inst"
			fi
		fi
		if [ "`uname`" = "Windows_NT" ]; then
			$inst/bin/opmnctl.bat stopall
			coreappf=$inst/bifoundation/OracleBIApplication/coreapplication
			prg="StartStopServices.cmd"
			if [ -f "$coreappf/$prg" ]; then
				corexml="$coreappf/StartStopServices.xml"
				if [ ! -f "$corexml.org" ]; then
					mv $corexml $corexml.org
					cat $corexml.org | \
						sed -e "s/opmn.start, show_url/opmn.start/g" > $corexml
				fi
				if [ ! -f "$coreappf/pass" ]; then
					rm -rf $coreappf/pass
				fi
				echo "$SXR_USER" > $coreappf/pass
				echo "$SXR_PASSWORD" >> $coreappf/pass
				cd $coreappf
				./$prg stop_all < $coreappf/pass &
				echo "# wait for startWebLogic.sh shutdown..."
				sts="dmdmdm"
				cnt=12
				while [ -n "$sts" -a $cnt -ne 0 ]; do
					sts=`psu | grep startWebLogic.cmd | grep -v grep 2> /dev/null`
					sleep 5
					let cnt=cnt-1
				done
				[ -n "$sts" ] && kill_essprocs.sh -all
				ret=0
			fi
		else
			domf="${HYPERION_HOME%/*}/user_projects/domains/bifoundation_domain"
			dompass="$domf/servers/AdminServer/security/boot.properties"
			echo "username=$SXR_USER" > $dompass
			echo "password=$SXR_PASSWORD" >> $dompass
			$inst/bin/opmnctl stopall
			$domf/bin/stopWebLogic.sh
			echo "# wait for startWebLogic.sh shutdown..."
			sts="dmdmdm"
			cnt=60
			while [ -n "$sts" -a $cnt -ne 0 ]; do
				sts=`psu | grep startWebLogic.sh | grep -v grep 2> /dev/null`
				sleep 5
				let cnt=cnt-1
			done
			[ -n "$sts" ] && kill_essprocs.sh -all
			rm -rf $HOME/${LOGNAME}@$(hostname)_wl.log 2> /dev/null
			ret=0
		fi
		;;
	*)	ret=0;;
esac
exit $ret
