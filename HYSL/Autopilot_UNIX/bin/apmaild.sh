#!/usr/bin/ksh
#########################################################################
# Filename: 	apmaild.sh
# Author:	Yukio Kono
#
# This script search the email folder and if there is e-mail file, this
# script send that e-mail.
#
# Line 1  : Target e-mail address
# Line 2  : Subject
# Line 3~ : Mail body
#########################################################################
# History:
# 96/18/2010 YK	First Edition

lcktarg="$AUTOPILOT/lck/apmail"		# Lock target file
lckterm="${lcktarg}.terminate"		# Mail terminate command file
aplog="$AUTOPILOT/mon/apmail.log"	# Log file
debugf="$AUTOPILOT/mon/apmail.debug"	# Debug command file

trap 'echo "Got init."' 1 2 3 15

. apinc.sh

rm -rf "$aplog" > /dev/null 2>&1

if [ `uname` = "Windows_NT" ]; then
	echo "apmaild.sh doesn't work on Windows platform." >> "$aplog"
	echo "Please launch this script on Unix platform." >> "$aplog"
	exit 1
fi

lock.sh "$lcktarg" $$ > /dev/null 2>&1
sts=$?
if [ $sts -ne 0 ]; then
	echo "Failed to lock $lcktarg." >> "$aplog"
	echo "There is another apmaild.sh." >> "$aplog"
	[ -f "${lcktarg}.lck" ] && cat ${lcktarg}.lck >> "$aplog"
	exit 2
fi
rm -rf $1 > /dev/null 2>&1
trap 'echo "Got exit. Unloack lock file.";unlock.sh "$lcktarg";exit 3' 0
echo "`date +%D_%T`:Start apmaild.sh on $(hostname) using ${LOGNAME} account." >> $aplog
while [ 1 ]; do
	if [ -f "$lckterm" ]; then
		echo "`date +%D_%T`:Found terminate request." >> $aplog
		break
	fi
	mailcnt=`ls $AUTOPILOT/mail/* 2> /dev/null | wc -l`
	let mailcnt=mailcnt
	if [ $mailcnt -ne 0 ]; then
		one=`ls $AUTOPILOT/mail/* 2> /dev/null | head -1`
		addrs=`head -1 $one | tr -d '\r'`
		ttl=`cat $one | wc -l`
		let ttl=ttl-2
		sbj=`head -2 $one | tail -1 | tr -d '\r'`
		tail -${ttl} $one | mailx -s "${sbj}" ${addrs}
		if [ -f "$debugf" ]; then
			echo "`date +%D_%T`: SEND" >> $aplog
			echo "To:$addrs" >> $aplog
			echo "Subject:$sbj" >> $aplog
			tail -${ttl} $one | while read line; do
				echo ">> $line" >> $aplog
			done
		else
			echo "`date +%D_%T`:$addrs : $sbj" >> $aplog
		fi
		rm -f $one
	else
		sleep 5
	fi
done

unlock.sh "$lcktarg" > /dev/null 2>&1

exit 0
