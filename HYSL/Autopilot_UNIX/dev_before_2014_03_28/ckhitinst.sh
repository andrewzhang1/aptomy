#!/usr/bin/ksh
# ckhitinst.sh : Check HIT installation status
# Description:
#   This script check the installTool-summaryXXX.log file and return
#   the installation is succeeded or not.
#   This script need HYPERION_HOME definition.
# Syntax: ckhitinst.sh
# Out:
#   0=Succeeded installation.
#   1=Invalid parameter.
#   2=No HYPERION_HOME defined.
#   3=No $HYPERION_HOME/diagnostics/logs/install folder.
#   4=Failed to change directory to HH/diagnostics/logs/install.
#   5=No installTool-summaryXXXXX.log found.
#   6=Failed to get the status section.
#   7=Failed to get the Total line from the status section.
#   8=Failed to get Pass condition for the Total status.
# History:
# 2012/02/08	YKono	First edition
# 2012/04/10	YKono	Add Zola file/folder structure
# 2012/04/11	YKono	Add 11.1.1.4.0 success check
# 2013/02/19	YKono	Support multiple installTool-summary-*.log files.

me=$0
orgpar=$@
while [ $# -ne 0 ]; do
	case $1 in
		-h)	display_help.sh $me;;
		*)	echo "ckinst.sh:Invalid parameter."
			exit 1;;
	esac
	shift
done
crrdir=`pwd`
[ -z "$HYPERION_HOME" ] && exit 2
if [ -f "$HYPERION_HOME/hit_version.txt" ]; then
	hitbldn=`cat $HYPERION_HOME/hit_version.txt | tr -d '\r' | tail -1`
	hitbldn=${hitbldn##*/}
	hitbldn=${hitbldn#*_}
	if [ "$hitbldn" = "7790" ]; then
		exit 0
	fi
else
	hitbldn=0
fi
if [ -d "$HYPERION_HOME/diagnostics/logs/install" ]; then
	# Talleyrand folder structure
	logf="$HYPERION_HOME/diagnostics/logs/install"
else
	# Zola folder structure
	logf="$HYPERION_HOME/logs/install"
fi
if [ -d "$logf" ]; then
	cd $logf 2> /dev/null
	if [ $? -ne 0 ]; then
		echo "Failed to change directory to $logf."
		exit 4
	fi
	fstr=new
	sumf=`ls installTool-summary* 2> /dev/null | tail -1`
	if [ -z "$sumf" ]; then
		if [ -f "installTool-install.log" ]; then
			sumf="installTool-install.log"
		else
			sumf=`ls installTool-install-*.log 2> /dev/null | grep -v std | tail -1`
		fi
		fstr=old
	fi
	if [ -z "$sumf" ]; then
		echo "Couldn't find the installTool-summary\*.log file."
		exit 5
	fi
	# echo "sumf=$sumf:$fstr"
	if [ "$fstr" = "new" ]; then
		ttl=`cat "$sumf" 2> /dev/null | wc -l`
		stsl=`cat "$sumf" 2> /dev/null | grep -n "^\[Install status" | tail -1` # For HIT PS2
		if [ -z "$stsl" ]; then
			stsl=`cat "$sumf" 2> /dev/null | grep -n "^---- Installation Summary" | head -1`	# For HIT PS1
			if [ -z "$stsl" ]; then
				echo "Failed to get the status section from $sumf."
				cat "$sumf" | while read line; do echo "> $line"; done
				exit 6
			fi
			ttlstr="^Summary:"
		else
			ttlstr="Total"
		fi
		stsl=${stsl%:*}
		let stsl=ttl-stsl
		ttlsts=`tail -${stsl} "$sumf" 2> /dev/null | grep "$ttlstr" | tail -1`
		if [ -z "$ttlsts" ]; then
			echo "Failed to get the Total line from the status section."
			tail -${stsl} "$sumf" | while read line; do echo "> $line"; done
			exit 7
		fi
		ttlsts=`echo $ttlsts | grep Pass`
		if [ -z "$ttlsts" ]; then
			echo "# Failed to get Pass condition for the Total status."
			tail -${stsl} "$sumf" | while read line; do echo "> $line"; done
			exit 8
		fi
	else # zola - talleyrand
		sts=`cat "$sumf" 2> /dev/null | grep "Oracle inventory created successfully"`	# For Zola
		if [ -z "$sts" ]; then
			sts=`cat "$sumf" 2> /dev/null | grep "Done with Oracle inventory creation"`	# For 11.1.2.4.0
			if [ -z "$sts" ]; then
				echo "Failed to get the inventory creation success status from $sumf."
				exit 6
			fi
		fi
	fi
else
	echo "# No $logf folder found."
	exit 3
fi
exit 0
