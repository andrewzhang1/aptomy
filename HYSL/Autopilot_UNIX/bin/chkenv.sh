#!/usr/bin/ksh
# chkenv.sh

plat=`get_platform.sh` > /dev/null 
[ $? -ne 0 ] && plat="Failed to get_platform.sh."

echo "\$AUTOPILOT        : $AUTOPILOT"
echo "\$HOME             : $HOME"
echo "\$VIEW_PATH        : $VIEW_PATH"
echo "\$PROD_ROOT        : $PROD_ROOT"
echo "\$ESSLANG          : $ESSLANG"
case `uname` in
	Windows_NT|SunOS|Linux|AIX)
echo "\$ARCH             : $ARCH"
;;
esac
echo "hostname from     : `which hostname`"
echo "autopilot.sh from : `which autopilot.sh`"
echo "platform          : $plat"
echo "hostname          : `hostname`"
echo "\$LOGNAME          : $LOGNAME"
if [ ! -f "$AUTOPILOT/tsk/$LOGNAME.tsk" ]; then
	echo "No task definition file."
else
	echo "Your task definition file exists."
	echo " ($AUTOPILOT/tsk/$LOGNAME.tsk)"
fi
if [ ! -f "$AUTOPILOT/tsk/$plat.tsk" ]; then
	echo "No platform task definition file."
else
	echo "Platform task definition file exist."
	echo " ($AUTOPILOT/tsk/$plat.tsk)"
fi
if [ -d "$AUTOPILOT/env/$LOGNAME" ]; then
	echo "User folder for the environment setup scripts is exist."
	echo " ($AUTOPILOT/env/$LOGNAME)"
	cd $AUTOPILOT/env/$LOGNAME
	ls *`hostname`.env
else
	echo "No user envirnment folder."
fi
