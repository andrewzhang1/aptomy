#!/usr/bin/ksh
# make default of the privilege to rw to all
# 2011/02/15 YKono	Add isplat() function.

umask 000

export AP_DEFVAR=1
export thiskernel=`uname`
if [ "$thiskernel" != "${thiskernel#CYGWIN}" ]; then
	export thiskernel="Cygwin"
fi

me=`which apinc.sh`
myloc=${me%/*}

export AP_DEF_BINPATH="$myloc"

if [ "$thiskernel" = "Windows_NT" ]; then
	export pathsep=";"
	[ -z "$LOGNAME" ] && export LOGNAME=$USERNAME
	[ -z "$LOGNAME" ] && export LOGNAME=webadmin
elif [ "$thiskernel" = "Cygwin" ]; then
	export pathsep=":"
	[ -z "$LOGNAME" ] && export LOGNAME=$USERNAME
	[ -z "$LOGNAME" ] && export LOGNAME=$(whoami)
else
	export pathsep=":"
fi
# Snapshot base and Result RTF base locations
export AP_DEF_RESLOC=${AUTOPILOT%/*}
export AP_DEF_SNAPSHOT_BASEPATH=${AUTOPILOT%/*/*}

export thishost=`hostname`
export node="${LOGNAME}@${thishost}"
export svusr="${thishost}_${LOGNAME}"
export plat=`get_platform.sh -l`
export thisnode=$node
export thissvusr=$svusr
export thisplat=$plat

# PATH definition
# export AP_DEF_BASPATH="$AUTOPILOT/bas"
# export AP_DEF_DATPATH="$AUTOPILOT/data"
export AP_DEF_ACCPATH="$AUTOPILOT/acc"
export AP_DEF_STSPATH="$AUTOPILOT/sts"
export AP_DEF_FLGPATH="$AUTOPILOT/flg"
export AP_DEF_RESPATH="$AUTOPILOT/res"
export AP_DEF_TMPPATH="$AUTOPILOT/tmp"
export AP_DEF_ENVPATH="$AUTOPILOT/env"
export AP_DEF_ENVPATH_TEMPLATE="$AUTOPILOT/env/template"
export AP_DEF_RSPPATH="$AUTOPILOT/rsp"
export AP_DEF_MONPATH="$AUTOPILOT/mon"
export AP_DEF_LICPATH="$AUTOPILOT/lic"
export AP_DEF_LOGPATH="$AUTOPILOT/log"
export AP_DEF_SECPATH="$AUTOPILOT/sec"
# export AP_DEF_TSKPATH="$AUTOPILOT/tsk"
export AP_DEF_VIEWPATH="$AUTOPILOT/view"

# DATA File definitions
export AP_DEF_SHABBR="$AUTOPILOT/data/shabbr.txt"
export AP_DEF_EMAILLIST="$AUTOPILOT/data/email_list.txt"
export AP_DEF_SCRIPTLIST="$AUTOPILOT/data/script_list.txt"
export AP_DEF_DMAPP="$AUTOPILOT/data/DMAPP.tar"
export AP_DEF_AGENTPORTLIST="$AUTOPILOT/data/agentport_list.txt"
export AP_DEF_SXRAGENTPORTLIST="$AUTOPILOT/data/sxragentport_list.txt"
export AP_DEF_IGNORESH="$AUTOPILOT/data/ignoresh.txt"

export AP_DEFAULT_CCC="default"

# Some temporary file name
export AP_DEF_INSTERRSTS="$AP_DEF_TMPPATH/${svusr}.error.sts"
# export AP_DEF_QTSK="$AP_DEF_TSKPATH/${svusr}.qtsk"
export AP_DEF_DIFFOUT="$AP_DEF_TMPPATH/${svusr}_sizcmp.dif"

# Real time status file
export AP_RTFILE="$AP_DEF_MONPATH/${svusr}.crr"
export AP_RTENVFILE="$AP_DEF_MONPATH/${svusr}.rt.env"
export AP_RTSTAFILE="$AP_DEF_MONPATH/${svusr}.rt.sta"
export AP_RTSOGFILE="$AP_DEF_MONPATH/${svusr}.rt.sog"
export AP_RTDIFFILE="$AP_DEF_MONPATH/${svusr}.rt.dif"
unset me myloc

# For queued framework ad history related log - aka apdef

export apsal=$AUTOPILOT/mon/$node.ap
export amsal=$AUTOPILOT/mon/$node.am
export ampar=$AUTOPILOT/mon/$node.am.par

export aphis=$AUTOPILOT/mon/$node.aphis.log

# export alltsk="${AUTOPILOT}/tsk/all.tsk"
# export plattsk="${AUTOPILOT}/tsk/${plat}.tsk"
# export mytsk="${AUTOPILOT}/tsk/${LOGNAME}.tsk"

export tsklck="${AUTOPILOT}/tsk/${node}.tsk.lck"
export platlck="${AUTOPILOT}/tsk/${plat}.tsk.lck"
export platrlck="${AUTOPILOT}/tsk/${plat}.tsk.rlck"
export alllck="${AUTOPILOT}/tsk/all.tsk.lck"

export AP_TSKQUE="$AUTOPILOT/que"
export AP_TSKDONE="$AUTOPILOT/que/done"
export AP_CRRTSK="$AUTOPILOT/que/crr"

#######################################################################
# library
#######################################################################

#######################################################################
# crr_sec : Get current data and time in second
cygp()
{
	[ "$thiskernel" = "Cygwin" ] \
		&& echo $(cygpath -up $1) \
		|| echo $1
}

#######################################################################
# crr_sec : Get current data and time in second
crr_sec()
{
# date +%s
perl -e 'print time;'
#	crr=`date "+%Y 1%j 1%H 1%M 1%S"`
#	y=`echo $crr | awk '{print$1}'`
#	d=`echo $crr | awk '{print$2}'`
#	h=`echo $crr | awk '{print$3}'`
#	m=`echo $crr | awk '{print$4}'`
#	s=`echo $crr | awk '{print$5}'`
#	yy=`expr $y - 1970`
#	expr $yy \* 31536000 + $d \* 86400 \
#		+ $h \* 3600 + $m \* 60 + $s - 86766100
}


#######################################################################
# set_flag : Set flag file in flg folder
this_flag_file=$AUTOPILOT/flg/${svusr}.flg
set_flag ()
{
	echo "$1" > $this_flag_file
	chmod 666 $this_flag_file
}


#######################################################################
# set_sts : Set status file in sts folder
this_status_file=$AUTOPILOT/sts/${svusr}.sts
set_sts ()
{
	echo "$1" > $this_status_file
	chmod 666 $this_status_file
}

#######################################################################
# get_flag : Get flag value from the flg foler.
get_flag ()
{
	[ ! -f "$this_flag_file" ] && set_flag STOP
	cat $this_flag_file 2> /dev/null | tr "a-z" "A-Z" | tr -d '\r'
}

#######################################################################
# get_sts : Get status value from the sts folder.
get_sts ()
{
	[ ! -f "$this_status_file" ] && set_sts RUNNING
	cat $this_status_file 2> /dev/null | tr -d '\r'
}

#######################################################################
# flock : file lock
flock()
{
	if [ -f "$1.lck" ]; then
		echo "$1 is locked by `cat $1.lck`."
	else
		echo "${LOGNAME} on ${thishost} at `date +%D_%T`" > $1.lck
		chmod 666 $1.lck
	fi
}

#######################################################################
# funlock : delete lock file
funlock()
{
	[ -f "$1.lck" ] && rm -rf $1.lck > /dev/null 2>&1
}

#######################################################################
# make_dir : mkdir with lock
make_dir()
{
	lck=`flock $1`
	if [ -z "$lck" ]; then
		flock $1
		mkdir $1
		funlock $1
	else
		echo $lck
	fi
}

#######################################################################
# remove_lock_file : remove lock file which is locked by me
remove_lock_file()
{
	if [ -f "$1" ]; then
		tmp=`cat $1 2> /dev/null | grep "${node}"`
		if [ -n "$tmp" ]; then
			rm -f "$1" 2> /dev/null
		fi
	fi
}

#######################################################################
# Remove all task read/write lock files.
remove_locks()
{
	remove_lock_file $platlck
	remove_lock_file $platrlck
	remove_lock_file $tsklck
}

#######################################################################
# Check the platform string
# syntax1: isplat
#    Display platform list
# syntax2: isplat <plat>
#    If the <plat> is in the list, echo <plat>
#    otherwise, not echo.
# Note: We only have a platform list in this place.
#       If we will get new or modify plat name, change this list.
# i.e.)
# case $1 in
#     ...
#     `isplat $1`)
#          plat=$1;;
#     ...
# esac
isplat()
{
# PLATFORM LIST
_pl="win32 winamd64 aix aix64 hpux64 solaris solaris64 solaris.x64 linux linuxamd64 linuxx64exa solaris64exa"
	if [ $# -ne 0 ]; then
		_pl=" $_pl "
        	[ "${_pl##* $1 }" != "$_pl" ]  && echo $1
	else
		echo $_pl
	fi
}

#######################################################################
# Set default value for the variable.
# if you define set_vardef, this put the warning to it.
set_vardef()
{
	while [ $# -ne 0 ]; do
		for vdf in $HOME/.${thisnode}.txt $HOME/.${thishost}.txt \
			   $HOME/vardef.txt $HOME/.vardef.txt $AUTOPILOT/data/vardef.txt; do
			[ -f "$vdf" ] && _tmp=`cat $vdf 2> /dev/null | grep -v "^$" | grep -v "^#" | grep "^${1}=" | tr -d '\r'` || _tmp=
			[ -n "$_tmp" ] && break	
		done
		_val=${_tmp#${1}=}
		if [ -n "$_val" ]; then
			_crrval=`eval "echo \\\$$1"`
			if [ -n "$_crrval" ]; then
				if [ "$_crrval" != "${_crrval#*\$}" ]; then
					eval "export ${1}=\"$_crrval\""
					_crrval=`eval "echo \\\$$1"`
				fi
				echo "set_vardef:$1 is already set to \"$_crrval(def:$_val)\"."
				[ -n "$set_vardef" ] && \
					echo "`date +%D_%T` ${LOGNAME}@$(hostname): \$$1=$_crrval(def:$_val@${vdf##*/})" \
					>> "$set_vardef"
			else
				[ "$_val" != "${_val#*\$}" ] \
					&& eval "export ${1}=\"$_val\"" \
					|| export ${1}="$_val"
			fi
		fi
		shift
	done
}

# export vardef_data=$AUTOPILOT/data/vardef.txt
# set_vardef()
# {
# 	if [ -f "$vardef_data" ]; then
# 		while [ $# -ne 0 ]; do
# 			_tmp=`cat $vardef_data 2> /dev/null | grep -v "^$" | grep -v "^#" | grep "^${1}=" | tr -d '\r'`
# 			_val=${_tmp#${1}=}
# 			if [ -n "$_val" ]; then
# 				_crrval=`eval "echo \\\$$1"`
# 				if [ -n "$_crrval" ]; then
# 					echo "set_vardef:$1 is already set to \"$_crrval(def:$_val)\"."
# 					[ -n "$set_vardef" ] && \
# 						echo "`date +%D_%T` ${LOGNAME}@$(hostname): \$$1=$_crrval(def:$_val)" \
# 							>> "$set_vardef"
# 					[ "$_crrval" != "${_crrval#*\$}" ] \
# 						&& eval "export ${1}=\"$_crrval\""
# 				else
# 					[ "$_val" != "${_val#*\$}" ] \
# 						&& eval "export ${1}=\"$_val\"" \
# 						|| export ${1}="$_val"
# 				fi
# 			fi
# 			shift
# 		done
# 	fi
# }

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
	perl -e "$perlcmd" 2> /dev/null
}

#######################################################################
# Write to stage file.
export stgfile="$AUTOPILOT/mon/${node}.stg"
wrtstg()
{
	echo "`date +%D_%T` $@" >> $stgfile
	chmod 755 $stgfile > /dev/null 2>&1
}


#######################################################################
# Real time status file format:
#      1    2   3    4        5    6       7     8      9    10   11     12
# org :host~usr~plat~viewpath~TEST~ver:bld~st_dt~subscr~suc#~dif#~crr_dt~sub_st_dt
#                                                status
# crr0:---- --- ---- 1        2    3       4     5      6    7    -----  [ 8 ]
# crr :---- --- ---- -------- ---- ------- ----- 1      ---- ---- -----  [ 2 ]

#######################################################################
# Write to RTF file
# 
# base=$(hostname)~${LOGNAME}~`get_platform.sh`~
#	$1 = viewpath
#	$2 = main test
#	$3 = ver:bld
#	$4 = start time stamp for main
#	$5 = sub-script name or current status
#	$6 = suc count
#	$7 = dif count
#	$8 = [ sub-script start time stamp ]
# This sub is called from autopilot.sh and start_regress.sh(wrtcrr).
#  - regmon.sh?
export wrtcrr=$AUTOPILOT/mon/${svusr}.crr
export my_crr_base="${thishost}~${LOGNAME}"
wrtcrr0()
{
	unset rtftmp
	# This function need to call get_platform.sh on each time because there is a posibility to has ARCH(64/32) task option.
	rtftmp="${my_crr_base}~`get_platform.sh`~${1}~${2}~${3}~${4}~${5}~${6}~${7}~`date '+%m_%d_%y %H:%M:%S'`"
	[ $# -eq 8 ] && rtftmp="${rtftmp}~${8}"
	echo "$rtftmp" > ${wrtcrr} 2> /dev/null
}

#######################################################################
# Write to RTF file
# 
#	$1 = $status/subscr
#	[ $2 = $sub-st_datetime ]
# This sub is called from start_regress.sh(wrtcrr), regmon.sh?
# When called from start_regress.sh, TEST, VERSION and BUILD variables
# should be defined and there is $st_datetime which keep start date and
# time of start_regress.sh.
# When this routine is called after regression test, the $succnt and 
# $difcnt should be defined. Before test execution, it shouldn't be
# defined.
wrtcrr()
{
	# Check this function is called from start_regress.sh.
	# In case of hyslinst.sh is called by start_regress.sh or not.
	if [ -n "$TEST" -a -n "$VERSION" -a -n "$BUILD" ]; then
		[ $# -lt 2 ] \
			&& wrtcrr0 "" "${TEST}" "${VERSION}:${BUILD}" "${st_datetime}" \
				"${1}" "${succnt}" "${difcnt}" "`date '+%m_%d_%y %H:%M:%S'`" \
			|| wrtcrr0 "" "${TEST}" "${VERSION}:${BUILD}" "${st_datetime}" \
				"${1}" "${succnt}" "${succnt}" "${2}"
	fi
}


