#!/usr/bin/ksh
#########################################################################
# Filename: 	chk_essinst.sh
# Author:	Yukio Kono
# Description:	Micro acceptance test
#########################################################################
# Usage:
# chk_essinst.sh <Ver#>
# 
# Retrun value:
#   0: run correctly
#   1:Failed to launch ESSBASE agent
#   2:Failed to launch ESSCMDQ
#   3:Failed to launch essmsh
#   4:Failed to launch ESSCMDG
#   5:Failed to launch ESSCMD
#   6:Execution error in ESSCMDQ
#   7:Execution error in essmsh
#   8:Execution error in ESSCMDG
#   9:Execution error in ESSCMD (Failed to stop server)
#  10:Environment value doesn't set correctly.
#  11:Missing directory in $PATH/$LD_LIBRARY_PATH
#  12:Failed to compare the directory structure
#  14:Failed to initialize Essbase by ap_essinit.sh
#  15:Failed to check version of each commands.
# NOTE: Before use this command, you should setup environment correctly
#       And install product correctly.
# 
#########################################################################
# History:
# 09/11/2007 YK First edition
# 09/17/2007 YK Add LD_LIBRARY_PATH check
# 11/19/2006 YK Add sizediff instead of dirstrct check.
# 12/13/2006 YK Remove sizediff part
# 07/29/2011 YK Remove output file.
# 06/07/2012 YK Add -force option against ap_essinit.sh
# 05/30/2013 YK BUG 16667156 - AUTOPILOT CHECKS SERVER BUILD NUMBER AND CLIENT BUILD NUMBER

. apinc.sh

#######################################################################
# Check Environment Variable (10)
#######################################################################
### ARBORPATH ###
if [ -z "$ARBORPATH" ]; then
	echo "ARBORPATH not defined"
	exit 10
fi
# Comment out because HSS mode and initial condition doesn't have it.
# if [ ! -d "$ARBORPATH" ]; then
# 	echo "ARBORPATH directory not exist"
# 	exit 10
# fi
### HYPERION_HOME ###
if [ -z "$HYPERION_HOME" ]; then
	echo "HYPERION_HOME not defined"
	exit 10
fi
if [ ! -d "$HYPERION_HOME" ]; then
	echo "HYPERION_HOME directory not exist"
	exit 10
fi

#######################################################################
# CHECK ENVIRINMENT VARIABLE (11)
#######################################################################
chk_path.sh
# ignore this result (just log missing path)

#######################################################################
# COMPARE FILE SIZE AND STRUCTURE (12)
#######################################################################
chk_filesize.sh
# ignore this result (just log it)

#######################################################################
# PREPARATION
#######################################################################
echo "### HYPEIRON_HOME    : $HYPERION_HOME"
echo "### ARBORPATH        : $ARBORPATH"
echo "### ESSBASEPATH      : $ESSBASEPATH"
echo "### AP_BISHIPHOME    : $AP_BISHIPHOME"
echo "### AP_SECMODE       : $AP_SECMODE"
echo "### SXR_CL_ARBOR     : $SXR_CLIENT_ARBORPATH"
echo "### SXR_ESSBASE_INST : $SXR_ESSBASE_INST"
echo "### SXR_USER         : $SXR_USER"
echo "### SXR_PASSWORD     : $SXR_PASSWORD"
echo "### SXR_DBHOST       : $SXR_DBHOST"
echo "# Initialize Essbase."
ap_essinit.sh -force # > /dev/null 2>&1
if [ $? -ne 0 ]; then
	echo "Failed to initialize Essbase using ap_essinit.sh."
	exit 14
fi

if [ `uname` = "Windows_NT" ]; then
	ESSCMD_CMD="ESSCMD.exe"
	ESSCMDQ_CMD="ESSCMDQ.exe"
	ESSCMDG_CMD="ESSCMDG.exe"
	ESSBASE_CMD="ESSBASE.exe"
	ESSMSH_CMD="essmsh.exe"
else
	ESSCMD_CMD="ESSCMD"
	ESSCMDQ_CMD="ESSCMDQ"
	ESSCMDG_CMD="ESSCMDG"
	ESSBASE_CMD="ESSBASE"
	ESSMSH_CMD="essmsh"
fi
[ -n "$SXR_DBHOST" ] && db_host="$SXR_DBHOST" || db_host="localhost"
[ -n "$SXR_USER" ] && ess_user="$SXR_USER" || ess_user="essexer"
[ -n "$SXR_PASSWORD" ] && ess_password="$SXR_PASSWORD" || ess_password="password"
ess_app="Microacc"
ess_db="Basic"
otlf="$AUTOPILOT/acc/Basic.otl"
dataf="$AUTOPILOT/acc/Calcdat.txt"
output_file="$VIEW_PATH/ma_err.out"
gridf="$AUTOPILOT/acc/griddata.txt"
gresf="gridout.txt"
crr_dir=`pwd`
ret=0
rm -f $output_file 2> /dev/null

#######################################################################
# Main test
#######################################################################
cd $VIEW_PATH

### START AGENT
if [ "$AP_SECMODE" = "rep" -o "$AP_SECMODE" = "fa" ]; then
	[ ! -d "$ARBORPATH/bin/wallet" ] && cp -R $ESSBASEPATH/bin/wallet $ARBORPATH/bin
	$ORACLE_INSTANCE/bin/opmnctl startall
elif [ "$AP_SECMODE" = "hss" ]; then
	start_service.sh
	# [ "`uname`" = "Windows_NT" ] && ext="bat" || ext="sh"
	# if [ -f "$ORACLE_INSTANCE/bin/startEPMServer.${ext}" ]; then
	# 	$ORACLE_INSTANCE/bin/startEPMServer.${ext}
	# elif [ -f "$ORACLE_INSTANCE/bin/startFoundationServices.${ext}" ]; then
	# 	$ORACLE_INSTANCE/bin/startFoundationServices.${ext}
	# fi
	$ORACLE_INSTANCE/bin/opmnctl startall
else
	${ESSBASE_CMD} password -b > /dev/null 2>&1 &
fi
if [ "$?" -ne 0 ]; then
	echo "Failed to start the ESSBASE agent."
	ret=1
fi

### CHECK CREATE APP/DB WITH ESSCMDQ
if [ "$ret" -eq 0 ]; then
	sed -e "s!%HOST!$db_host!g" -e "s!%USR!$ess_user!g" \
		-e "s!%PWD!$ess_password!g" -e "s!%OUTF!$output_file!g" \
		-e "s!%APP!$ess_app!g" -e "s!%DB!$ess_db!g" \
		-e "s!%OTLF!$otlf!g" \
		-e "s!%AUTOPILOT!$AUTOPILOT!g" \
		$AP_DEF_ACCPATH/microacceptance.scr > cmdq.scr
	$ESSCMDQ_CMD cmdq.scr
	if [ "$?" -ne 0 ]; then
		echo "Failed to launch ESSCMDQ."
		ret=2
	else
		if [ ! -f "$output_file" ]; then
			echo "Execution error during the ESSCMDQ test."
			ret=6
		else
			err=`cat $output_file | egrep -e "Error|Please Login first"`
			if [ -n "$err" ]; then
				echo "Execution error during the ESSCMDQ test."
				echo "### esscmdq script ###"
				cat cmdq.scr
				echo "### output ###"
				cat $output_file
				ret=6
			fi
		fi
	fi
	[ $ret -eq 0 ] && rm -f cmdq.scr
	[ $ret -eq 0 ] && rm -f $output_file
fi

### CHECK HSS MODE WITH ESSMSH
if [ "$ret" -eq 0 -a "$AP_SECMODE" = "hss" ]; then
	sed -e "s!%HOST!$db_host!g" -e "s!%USR!$ess_user!g" \
		-e "s!%PWD!$ess_password!g" -e "s!%OUTF!$output_file!g" \
		-e "s!%APP!$ess_app!g" -e "s!%DB!$ess_db!g" \
		-e "s!%DATAF!$dataf!g" \
		-e "s!%AUTOPILOT!$AUTOPILOT!g" \
		$AP_DEF_ACCPATH/microacceptancehss.msh > hssmaxl.msh
	$ESSMSH_CMD hssmaxl.msh
	sts=$?
	if [ "$sts" -eq 127 -o "$sts" -eq 128 ]; then
		echo "Failed to launch essmsh."
		ret=3
	else
		if [ ! -f "$output_file" ]; then
			echo "Execution error during the essmsh test."
			ret=7
		else
			err=`cat $output_file | egrep -e "ERROR|Not logged in to Essbase"`
			if [ -n "$err" ]; then
				echo "Execution error during the essmsh test."
				echo "### MaxL script ###"
				cat hssmaxl.msh
				echo "### output ###"
				cat $output_file
				ret=7
			fi
		fi
	fi
	[ $ret -eq 0 ] && rm -f hssmaxl.msh
	[ $ret -eq 0 ] && rm -f $output_file
fi

### CHECK LOAD DATA AND DEFAULT CALCULATION WITH ESSMSH
if [ "$ret" -eq 0 ]; then
	sed -e "s!%HOST!$db_host!g" -e "s!%USR!$ess_user!g" \
		-e "s!%PWD!$ess_password!g" -e "s!%OUTF!$output_file!g" \
		-e "s!%APP!$ess_app!g" -e "s!%DB!$ess_db!g" \
		-e "s!%DATAF!$dataf!g" \
		-e "s!%AUTOPILOT!$AUTOPILOT!g" \
		$AP_DEF_ACCPATH/microacceptance.msh > maxl.msh
	$ESSMSH_CMD maxl.msh
	sts=$?
	if [ "$sts" -eq 127 -o "$sts" -eq 128 ]; then
		echo "Failed to launch essmsh."
		ret=3
	else
		if [ ! -f "$output_file" ]; then
			echo "Execution error during the essmsh test."
			ret=7
		else
			err=`cat $output_file | egrep -e "ERROR|Not logged in to Essbase"`
			if [ -n "$err" ]; then
				echo "Execution error during the essmsh test."
				echo "### MaxL script ###"
				cat maxl.msh
				echo "### output ###"
				cat $output_file
				ret=7
			fi
		fi
	fi
	[ $ret -eq 0 ] && rm -f maxl.msh
	[ $ret -eq 0 ] && rm -f $output_file
fi

### CHECK RETRIEVE WITH ESSCMDG
if [ "$ret" -eq 0 ]; then
	sed -e "s!%HOST!$db_host!g" -e "s!%USR!$ess_user!g" \
		-e "s!%PWD!$ess_password!g" -e "s!%GRID!$gridf!g" \
		-e "s!%APP!$ess_app!g" -e "s!%DB!$ess_db!g" \
		-e "s!%RESULT!$gresf!g" -e "s!%ROW!10!g" -e "s!%COL!4!g" \
		-e "s!%AUTOPILOT!$AUTOPILOT!g" \
		$AP_DEF_ACCPATH/microacceptance_g.scr > cmdg.scr
	$ESSCMDG_CMD cmdg.scr > $output_file 2>&1
	sts=$?
	if [ "$sts" -eq 127 ]; then
		echo "Failed to launch ESSCMDG."
		ret=4
	else
		if [ ! -f "$output_file" ]; then
			echo "Execution error during the ESSCMDG test."
			ret=8
		else
			err=`cat $output_file | egrep -e "Command Failed|Segmentation violation"`
			if [ -n "$err" ]; then
				echo "Execution error during the ESSCMDG test."
				echo "### ESSCMDG script ###"
				cat cmdg.scr
				echo "### output ###"
				cat $output_file
				ret=8
			fi
		fi
	fi
	[ $ret -eq 0 ] && rm -f cmdg.scr
	[ $ret -eq 0 ] && rm -f $gresf
	[ $ret -eq 0 ] && rm -f $output_file
fi

### SHUTDOWN SERVER WITH ESSCMD
if [ "$ret" -ne 1 -a -z "$AP_SECMODE" ]; then
	sed -e "s!%HOST!$db_host!g" -e "s!%USR!$ess_user!g" \
		-e "s!%PWD!$ess_password!g" -e "s!%OUTF!$output_file!g" \
		-e "s!%APP!$ess_app!g" -e "s!%DB!$ess_db!g" \
		-e "s!%AUTOPILOT!$AUTOPILOT!g" \
		$AP_DEF_ACCPATH/shutdown.scr > shutdown.scr
	$ESSCMD_CMD shutdown.scr
	sts=$?
	if [ "$sts" -ne 0 ]; then
		ret=5
		echo "Failed to launch ESSCMD."
	else
		if [ "$ret" -eq 0 ]; then
			if [ ! -f "$output_file" ]; then
				echo "Failed to execute shutdownserver command using $ESSCMD_CMD."
				ret=9
			else
				err=`cat $output_file | egrep -e "Error"`
				if [ -n "$err" ]; then
					echo "Failed to execute shutdownserver command using $ESSCMD_CMD."
					echo "### ESSCMD script ###"
					cat shutdown.scr
					echo "### output ###"
					cat $output_file
					ret=9
				fi
			fi
		fi
	fi
	[ $ret -eq 0 ] && rm -f $output_file
	[ $ret -eq 0 ] && rm -f shutdown.scr
fi

if [ "$AP_SECMODE" = "rep" -o "$AP_SECMODE" = "fa" -o "$AP_SECMODE" = "bi" ]; then
	$ORACLE_INSTANCE/bin/opmnctl stopall
elif [ "$AP_SECMODE" = "hss" ]; then
	$ORACLE_INSTANCE/bin/opmnctl stopall
	[ "`uname`" = "Windows_NT" ] \
		&& $ORACLE_INSTANCE/bin/stopEPMServer.bat \
		|| $ORACLE_INSTANCE/bin/stopEPMServer.sh
fi

# Move to start_regress.sh
# #######################################################################
# # CHECK MODULE VERSION NUMBERS
# #######################################################################
# if [ "$ret" -eq 0 ]; then
# 	echo "Check version number for each modules."
# 	get_ess_ver.sh -test all
# 	if [ $? -ne 0 ]; then
# 		echo "Check version failure ($?)."
# 	#	ret=14	# Ignore result. just tell it.
# 	fi
# fi

if [ -n "$AP_SECMODE" ]; then
	kill_essprocs.sh -biall > /dev/null 2>&1
else
	kill_essprocs.sh -all > /dev/null 2>&1
fi
exit $ret
