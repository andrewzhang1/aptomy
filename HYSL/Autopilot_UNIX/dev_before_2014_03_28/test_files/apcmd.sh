#!/usr/bin/ksh

# cmd.sh

# Command sender

# apcmd.cmd [<target>] [<cmd>|-f <cmd-file>]
# Ext:
#    ${LOGNAME}@`hostname`.ap2
#    ${LOGNAME}@`hostname`.ap2.lck

. apinc.sh

disp_help()
{
	echo "Usage : $0 <target> [<cmd> | -f <cmd-file>]"
	echo "  <target>   : Target machine node like <usr>@<machine>"
	echo "  <cmd>      : Command to execute."
	echo "  <cmd-file> : Command file."
}

unset cmdf
flg=cmd
targ="${LOGNAME}@$(hostname)"
while [ $# -ne 0 ]; do
	case $1 in
		-f)
			if [ $# -lt 2 ]; then
				echo "No target file."
				disp_help
				exit 2
			fi
			shift
			cmdf=$1
			flg=file
			;;
		*@*)
			targ=$1
			;;
		*)
			if [ -z "$cmdf" ]; then
				cmdf=$1
			else
				echo "Too many parameter."
				disp_help
				exit 3
			fi
			;;
	esac
	shift
done

if [ -z "$targ" ]; then
	echo "No <target> parameter."
	disp_help
	exit 1
fi

if [ -z "$cmdf" ]; then
	echo "No <cmd> or <cmdf> parameter."
	disp_help
	exit 1
fi
if [ "$flg" = "file" -a ! -f "$cmdf" ]; then
	echo "Couldn't find the command file($cmdf)."
	exit 5
fi

trap 'rm -f ${apcmd} > /dev/null 2>&1; \
	unlock.sh ${apcmd} > /dev/null 2>&1; \
	echo "Break"; exit 1' 1 2 3 15

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
fi

[ -f "$apcmd" ] && rm -f "$apcmd"
fold="tst"
node=${LOGNAME}@$(hostname)
mylck="${fold}/apcmd_${targ}_from_${node}.$$"
myout="${mylck}.out"
mysts="${mylck}.sts"
echo "#!/usr/bin/ksh" > $apcmd
echo "# Run command request" >> $apcmd
echo "#   To:   ${targ}" >> $apcmd
echo "#   From: ${LOGNAME}@$(hostname)" >> $apcmd
echo "#   At:   $(date +%D_%T)" >> $apcmd
echo "# LckF=\$AUTOPILOT/$mylck" >> $apcmd
echo "# LogF=\$AUTOPILOT/$myout" >> $apcmd
echo "# StsF=\$AUTOPILOT/$mysts" >> $apcmd
[ "$flg" = "file" ] && cat "$cmdf" >> $apcmd || echo "$cmdf" >> $apcmd
chmod 666 "$apcmd"
mylck="$AUTOPILOT/$mylck"
myout="$AUTOPILOT/$myout"
mysts="$AUTOPILOT/$mysts"
unlock.sh "$apcmd"
echo "# sent request."

######################################################################
# Wait request

while [ -f "$apcmd" ]; do
	sleep 1
done

echo "# waiting output"
while [ ! -f "$myout" ]; do
	sleep 1
done

######################################################################
# Dump output

prevlines=0
while [ -f "${mylck}.lck" ]; do
    lines=`cat ${myout} | wc -l`
    if [ "$lines" -ne "$prevlines" ]; then
        let displ="$lines - $prevlines"
        tail -$displ $myout
        prevlines=$lines
    fi
    sleep 1
done
lines=`cat ${myout} | wc -l`
if [ "$lines" -ne "$prevlines" ]; then
    let displ="$lines - $prevlines"
    tail -$displ $myout
fi

rm -f "$myout"

if [ -f "$mysts" ]; then
	sts=`cat $mysts`
	rm -f "$mysts"
	echo "# sts=$sts"
fi
exit $sts
