#!/usr/bin/ksh
########################################################################
# start_service.sh : Start EPM or BI services
########################################################################
# Syntax: start_service.sh [-h]
# Description:
#   This script start WebLogic service in HSS/FA/BI repository mode.
# Options:
#   -h       : Display help
# Exit status:
#   0 : Started fine.
#   1 : Syntax error
#   2 : Failed to start
########################################################################
# History:
# 12/12/2012 YKono	First edition.
# 01/29/2014 YKono	Add workaround for Bug 18019330 - LINUX32 EAS OPACK MAKE WEBLOGIC SERVER HANGS AT STATING SERVICE

. apinc.sh
me=$0
orgpar=$@
dbg=false
while [ $# -ne 0 ]; do
	case $1 in
		-d)	dbg=true;;
		-h)
			display_help.sh $me
			exit
			;;
	esac
	shift
done

ret=2
[ "$dbg" = "true" ] && echo "# AP_SECMODE=$AP_SECMODE" 
case $AP_SECMODE in
	hss)
		if [ -d "$ORACLE_INSTANCE" ]; then
			if [ `uname` = "Windows_NT" ]; then
				prg=startFoundationServices.bat
				prg1=startEPMServer.bat
				prg2=start.bat
			else
				prg=startFoundationServices.sh
				prg1=startEPMServer.sh
				prg2=start.sh
			fi
			if [ -f "$ORACLE_INSTANCE/bin/$prg" ]; then
				[ "$dbg" = "true" ] && echo "# Start $ORACLE_INSTANCE/bin/$prg"
				$ORACLE_INSTANCE/bin/$prg
				ret=$?
			elif [ -f "$ORACLE_INSTANCE/bin/$prg1" ]; then
				[ "$dbg" = "true" ] && echo "# Start $ORACLE_INSTANCE/bin/$prg1"
				$ORACLE_INSTANCE/bin/$prg1
				ret=$?
			elif [ -f "$ORACLE_INSTANCE/bin/$prg2" ]; then
				[ "$dbg" = "true" ] && echo "# Start $ORACLE_INSTANCE/bin/$prg2"
				$ORACLE_INSTANCE/bin/$prg2
				ret=$?
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
		arb=$ARBORPATH
		if [ "`uname`" = "Windows_NT" ]; then
			coreappf=$inst/bifoundation/OracleBIApplication/coreapplication
			if [ -d "$coreappf" ]; then
				cd $coreappf
				corexml="$coreappf/StartStopServices.xml"
				if [ ! -f "$corexml.org" ]; then
					mv $corexml $corexml.org
					echo "" >> $corexml.org
					cat $corexml.org | \
						sed -e "s/opmn.start, show_url/opmn.start/g" \
						> $corexml
				fi
				passf=pass.txt
				rm -rf $passf
				echo "$SXR_USER" > $passf
				echo "$SXR_PASSWORD" >> $passf
				domf="${HYPERION_HOME%/*}/user_projects/domains/bifoundation_domain"
				dompass="$domf/servers/AdminServer/security/boot.properties"
				echo "username=$SXR_USER" > $dompass
				echo "password=$SXR_PASSWORD" >> $dompass
				[ "$dbg" = "true" ] && echo "# Start `pwd`/StartStopService.cmd start_all"
				./StartStopServices.cmd start_all < $passf > /dev/null 2>&1
				rm -rf $passf
				$inst/bin/opmnctl.bat stopall > /dev/null 2>&1
				ret=0
			fi
		else
			domf="${HYPERION_HOME%/*}/user_projects/domains/bifoundation_domain"
			dompass="$domf/servers/AdminServer/security/boot.properties"
			echo "username=$SXR_USER" > $dompass
			echo "password=$SXR_PASSWORD" >> $dompass
			# echo "### ${dompass##*/}"
			# cat $dompass | while read line; do echo "# $line"; done
			wllog="${HOME}/${LOGNAME}@`hostname`_wl.log"
			rm -rf $wllog 2> /dev/null
			if [ -f "$domf/bin/startWebLogic.sh" ]; then
				echo "# Start WebLogic server."
				[ "$dbg" = "true" ] && echo "# Start $domf/bin/startWebLogic.sh"
				# unset ARBORPATH ESSBASEPATH ESSBASEEXE ESSBASE_CLUSTER_NAME ESSLANG ODBCINI ODBCINST ODBC_HOME
				unset ARBORPATH 
				$domf/bin/startWebLogic.sh | tee $wllog 2>&1 &
				wlpid=$!
				while [ 1 ]; do
					sts=`ps -p $wlpid 2> /dev/null | grep -v PID`
					[ -z "$sts" ] && break
					sts=`grep "<BEA-000360>" $wllog 2> /dev/null`
					[ -n "$sts" ] && break
					# sts=`grep "^FUSION mode detected" $wllog 2> /dev/null`
					# [ -n "$sts" ] && break
					sleep 5
				done
				if [ -n "$sts" ]; then
					$inst/bin/opmnctl stopall
					[ $? -eq 0 ] && ret=0
				else
					echo "# Failed to start WebLogic."
					ret=3
				fi
				# rm -rf $wllog 2> /dev/null
			fi
		fi
		if [ "$ret" -eq 0 ]; then
			# Edit opmn.xml
			if [ ! -f "$inst/config/OPMN/opmn/opmn.xml.org" ]; then
				mv $inst/config/OPMN/opmn/opmn.xml $inst/config/OPMN/opmn/opmn.xml.org
				echo "" >> $inst/config/OPMN/opmn/opmn.xml.org
			fi
			rm -f $inst/config/OPMN/opmn/opmn.xml 2> /dev/null
			cat $inst/config/OPMN/opmn/opmn.xml.org | \
		   		 sed -e "s!<variable id=\"ESSLANG\" value=\".*\"/>!<variable id=\"ESSLANG\" value=\"$ESSLANG\"/>!g" \
		         	 -e "s!<data id=\"agent-port\" value=\".*\"/>!<data id=\"agent-port\" value=\"$AP_AGENTPORT\"/>!g" \
		    	> $inst/config/OPMN/opmn/opmn.xml
			# Edit essbase.cfg in the $ARBORPATH
			if [ -d "$arb/bin" ]; then
				if [ -f "$arb/bin/essbase.cfg" ]; then
					_fnd=`egrep -i "^AgentPort[ 	]" "$arb/bin/essbase.cfg"`
					if [ -z "$_fnd" ]; then
						echo "AgentPort	$AP_AGENTPORT" >> $arb/bin/essbase.cfg
					else
						_fnd=${_fnd%%[ 	]*}
						rm -rf $arb/bin/essbase.cfg.org 2> /dev/null
						mv $arb/bin/essbase.cfg $arb/bin/essbase.cfg.org
						sed -e "s/^${_fnd}[ 	][ 	]*[^ 	][^ 	]*/${_fnd}    $AP_AGENTPORT/g" \
							"$arb/bin/essbase.cfg.org" > $arb/bin/essbase.cfg
					fi
				else
					echo "AgentPort	$AP_AGENTPORT" >> $arb/bin/essbase.cfg
				fi
			fi
		fi
		;;
	*)	ret=0;;
esac
exit $ret
