#!/usr/bin/ksh

#######################################################################
# Compare string.
# Syntax:	ret=`cmstr <src> <dst>`
# In:	<src>	compare source string
#		<dst>	compare target string
# Out:	"<"	<src> is less than <dst>
#		"="	Equal
#		">"	<src> is greater than <dst>
cmpstr()
{
	perlcmd="\$a=\"${1}\";\$b=\"${2}\";if(\$a lt \$b){print \"<\"}elsif(\$a eq \$b){print \"=\"}else{print \">\"}"
	perl -e "$perlcmd"
}


if [ -z "$HIT_ROOT" ]; then
	echo "No \$HIT_ROOT defined."
	exit 1
fi

if [ $# -lt 1 ]; then
	echo "Please define the target date and time."
	echo "cptest.sh 2010/07/08_14:22:10"
	exit 2
fi

while [ $# -ne 0 ]; do
	rm -rf $HOME/cpwork
	mkdir $HOME/cpwork
	mkdir $HOME/cpwork/target

	crrdt=`date +"%Y/%m/%d_%T"`
	sts=`cmpstr $crrdt $1`
	echo "================"
	echo "Target: $1"
	echo "Crr   : $crrdt"
	while [ "$sts" = "<" ]; do
		crrdt=`date +"%Y/%m/%d_%T"`
		sts=`cmpstr $crrdt $1`
		sleep 1
	done
	echo "Current Time : $crrdt"
	echo "Copy nar200 to local."
	time cp -R $HIT_ROOT/prodpost/zola/build_3663_rtm/COMPRESSED $HOME/cpwork
	echo "Copy local to local."
	time cp -R $HOME/cpwork/COMPRESSED $HOME/cpwork/target
	
	rm -rf $HOME/cpwork
	shift
done
