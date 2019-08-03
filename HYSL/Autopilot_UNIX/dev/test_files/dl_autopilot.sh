#!/usr/bin/ksh

# cmd.sh

# Command sender

# cmd <target> [<cmd>|-f <cmd-file>]
# Ext:
#    ${LOGNAME}@`hostname`.ap2
#    ${LOGNAME}@`hostname`.ap2.lck

. apinc.sh

disp_help()
{
	echo "Start autopilot.sh on specific target."
	echo "Usage : $0 <target>"
}

unset cmdf
flg=cmd
targ="${LOGNAME}@$(hostname)"
while [ $# -ne 0 ]; do
	case $1 in
		*@*)
			targ=$1
			;;
		*)
				echo "Too many parameter."
				disp_help
				exit 3
			;;
	esac
	shift
done

if [ -z "$targ" ]; then
	echo "No <target> parameter."
	disp_help
	exit 1
fi

trap 'rm -f ${apcmd} > /dev/null 2>&1; \
	unlock.sh ${apcmd} > /dev/null 2>&1; \
	echo "Break"; exit 10' 1 2 3 15

######################################################################
# Start main
######################################################################
apfile="${AUTOPILOT}/lck/${targ}"
apcmd="${AUTOPILOT}/mon/${targ}.cmd"

lock_ping.sh ${apfile}
if [ $? != 0 ]; then
	echo "There is no delegate.sh running($targ)."
	exit 4
fi

######################################################################
# Make request file

cmdl=`lock.sh ${apcmd} $$`
if [ $? != 0 ]; then
	echo "Failed to lock the command file for $targ."
	[ -f "${apcmd}.lck" ] && cat "${apcmd}.lck" | while read one; do
		echo "> $one"
	done
	exit 5
fi

[ -f "$apcmd" ] && rm -f "$apcmd"
node=${LOGNAME}@$(hostname)
mylck="lck/${targ}.ap"
myout="mon/${targ}.ap.log"
echo "#!/usr/bin/ksh" > $apcmd
echo "# Start autopilot.sh:" >> $apcmd
echo "#   To:   ${targ}" >> $apcmd
echo "#   From: ${node}" >> $apcmd
echo "#   At:   $(date +%D_%M)" >> $apcmd
echo "# LckF=\$AUTOPILOT/$mylck" >> $apcmd
echo "# LogF=\$AUTOPILOT/$myout" >> $apcmd
echo ". autopilot.sh start" >> $apcmd
mylck="$AUTOPILOT/$mylck"
myout="$AUTOPILOT/$myout"
chmod 666 "$apcmd"
unlock.sh "$apcmd"
echo "# sent request."

######################################################################
# Wait request

while [ -f "$apcmd" ]; do
	sleep 1
done

echo "# waiting for output file."
while [ ! -f "$myout" ]; do
	sleep 1
done

echo "# Started."
cat $myout

