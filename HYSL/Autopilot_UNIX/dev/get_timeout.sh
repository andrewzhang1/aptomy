#!/usr/bin/ksh

#########################################################################
# Filename:    get_timeout.sh
# Author:      Yukio Kono
# Description: Get timeout from essbase.cfg
#   This script check the NETDLAY and NETRETRYCOUNT in the essbase.cfg
# And return the calculated value of NETDLAY x NETRETRYCOUNT.
# If there is no target definition, the default will be used below:
#   NETDLAY=200
#   NETTRETRYCOUNT=600
# History ###############################################################
# 09/23/2010 YKono	First Edition from autopilot2.sh

if [ "$1" = "-l" ]; then
	long=true
else
	long=false
fi
netdlay=200
netretrycount=600
if [ -z "$ARBORPATH" ]; then
	echo "\$ARBORPATH not defined."
	exit 1
fi
if [ -f "$ARBORPATH/bin/essbase.cfg" ]; then
	_tmp=`cat $ARBORPATH/bin/essbase.cfg 2> /dev/null | egrep -i "^[ 	]*NetDelay"`
	if [ -n "$_tmp" ]; then
		_tmp=`echo $_tmp | awk '{print $2}'`
		netdlay=$_tmp
	fi
	_tmp=`cat $ARBORPATH/bin/essbase.cfg 2> /dev/null | egrep -i "^[ 	]*NetRetryCount"`
	if [ -n "$_tmp" ]; then
		_tmp=`echo $_tmp | awk '{print $2}'`
		netretrycount=$_tmp
	fi
fi
let timeout=netdlay\*netretrycount/1000
if [ "$long" = "true" ]; then
	echo "NETDLAY[$netdlay]"
	echo "NETRETRYCOUNT[$netretrycount]"
	echo "TIMEOUT[$timeout]"
else
	echo "$timeout"
fi
exit 0
