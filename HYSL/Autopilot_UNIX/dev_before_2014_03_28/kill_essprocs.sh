#!/usr/bin/ksh
# History:
# 2010/09/24 YKono	First edition
# 2012/06/11 YKono	Support forced kill BI related processes
# 2012/07/20 YKono	Support forced kill HSS related process
# 2012/12/27 YKono	Kill processes which has $PROD_ROOT string in command line

. apinc.sh

# kill_essprocs.sh <app>	Kill application
# kill_essprocs.sh -agent|-a	Kill Agent
# kill_essprocs.sh -client|-c 	Kill Client
# kill_essproces.sh -all	Kill Agent/Svr/Client
# -cmdq -cmd -cmds -cmdg -maxl -msh
display_help()
{
	echo "Kill Essbase related processes."
	echo "Syntax: kill_essprocs.sh [<opt>] <app>"
	echo "<app> : Application name to kill."
	echo "<opt> : -app|-h|-a|-c|-all|-cmdq|-cmdg|-cmd|-cmds|-msh"
	echo "        -agtsvr|-agent|-client|-bi"
	echo "  -h  : Display this"
}

orgargs=$@
unset targ
while [ $# -ne 0 ]; do
	case $1 in 
		-hss|hss)
			targ=hssall
			export AP_SECMODE=hss
			;;
		-biall|biall)
			targ=biall
			export AP_BISHIPHOME=true
			;;
		-bi)
			export AP_BISHIPHOME=true
			;;
		-apps)
			targ=apps
			;;
		agtsvr|-agtsvr|-svragt|svragt)
			targ=agtsvr
			;;
		agent|-agent|-a)
			targ=agent
			;;
		client|-client|-c)
			targ=client
			;;
		all|-all)
			targ=all
			;;
		-cmdq|-cmd|-cmds|-cmdg|-maxl)
			targ=${1#-}
			;;
		cmdq|cmd|cmds|cmdg|maxl)
			targ=${1}
			;;
		-msh|msh)
			targ=maxl
			;;
		-app)
			shift
			targ=$1
			;;
		-h|-help)
			display_help
			exit 1
			;;
		*)
			targ=$1
			;;
	esac
	shift
done

[ -z "$targ" ] && exit 0

dokill()
{
	psu -ess | egrep -i "$1" | while read pid kind; do
		trg=`psu | grep ^$pid`
		echo "kill_essprocs.sh:`date +%D_%T`:$trg"
		kill -9 $pid > /dev/null 2>&1
	done
}

killhssbi()
{
	if [ "`uname`" = "Windows_NT" ]; then
		if [ $# -ne 0  ]; then
			pstree.pl -all | sed -e "s!\\\!/!g" | egrep -v egrep | \
				egrep "opmn.exe" | while read pid rest
			do
				echo "kill $pid $rest"
				pstree.sh -kill $pid 
			done
		else
			pstree.pl -all | sed -e "s!\\\!/!g" | egrep -v egrep | \
				egrep "nmz.exe|opmn.exe|startEPMServer|weblogic_patch|startNodeManager|startWebLogic|nqsclustercontroller|nsqserver|nsqscheduler|sawserver|startFoundationServices.bat|stopFoundationServices.bat|startFoundationServices0.bat|stopFoundationServices0.bat" \
			| while read pid rest; do
				echo "kill $pid $rest"
				pstree.sh -all -kill $pid 
			done
			pstree.pl -all | sed -e "s!\\\!/!g" | egrep -v egrep | grep "${LOGNAME}" | \
				egrep "startWebLogic|nmz.exe|opmn|beasvc.exe" \
			| while read pid rest; do
				echo "kill $pid $rest"
				pstree.sh -all -kill $pid 
			done
			psu all | sed -e "s!\\\!/!g" | grep nmz.exe | grep -v grep | while read usr pid rest; do
				echo "kill $pid:$usr:$rest"
				kill -9 $pid > /dev/null 2>&1
			done
			psu all | sed -e "s!\\\!/!g" | grep $PROD_ROOT | grep -v grep | grep -v kill_essprocs.sh | grep -v "biinst.sh" | grep -v "hitinst.sh" | grep -v "rmfld.sh" | while read usr pid rest; do
				echo "kill $pid:$usr:$rest"
				kill -9 $pid > /dev/null 2>&1
			done
		fi
	else
		if [ $# -ne 0 ]; then
			pstree.pl | grep "<none>" \
				| egrep "opmn" | while read pid rest
			do
			echo "kill $pid $rest"
				pstree.sh -kill $pid 
			done
		else
			pstree.pl | grep "<none>" \
				| egrep "nmz|opmn|startEPMServer|startNodeManager|startWebLogic|nqsclustercontroller|nsqserver|nsqscheduler|sawserver" \
			| while read pid rest; do
				echo "kill $pid $rest"
				pstree.sh -kill $pid 
			done
			pstree.pl | egrep -v egrep | grep "$LOGNAME" | \
				egrep "startWebLogic|nmz|opmn|weblogic.Server" \
			| while read pid rest; do
				echo "kill $pid $rest"
				pstree.sh -kill $pid 
			done
			psu all | grep $PROD_ROOT | grep -v "biinst.sh" | grep -v "hitinst.sh" |  while read usr pid rest; do
				echo "kill $pid:$usr:$rest"
				kill -9 $pid
			done
		fi
	fi
}

case ${targ} in
	hssall|biall)
		killhssbi opmn
		;;
	all)
		killhssbi
		dokill "essbase|esssvr|esscmd|essmsh"
		;;
	agtsvr)
		killhssbi opmn
		dokill "essbase|esssvr"
		;;
	agent)
		killhssbi opmn
		dokill essbase
		;;
	client)
		dokill "esscmd|essmsh"
		;;
	cmdq)
		dokill "esscmdq"
		;;
	cmd)
		dokill "esscmd\$"
		;;
	cmdg)
		dokill "esscmdg"
		;;
	cmds)
		dokill "esscmd"
		;;
	maxl)
		dokill "essmsh"
		;;
	apps)
		psu -essa | while read pid dmy app; do
			trg=`psu | grep ^$pid`
			echo "kill_essprocs.sh:`date +%D_%T`:$trg"
			kill -9 $pid > /dev/null 2>&1
		done
		;;		
	*)
		psu -essa | grep $targ | while read pid dmy app; do
			trg=`psu | grep ^$pid`
			echo "kill_essprocs.sh:`date +%D_%T`:$trg"
			kill -9 $pid > /dev/null 2>&1
		done
esac

exit 0

