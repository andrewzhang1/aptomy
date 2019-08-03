#!/usr/bin/ksh

# Set test environment variable

#######################################################################
# Get installation related variable from se.sh
#######################################################################
if [ $# -gt 1 ]; then
	envdef="$AUTOPILOT/tmp/${LOGNAME}@`hostname`.settestenv.$$.tmp"
	[ -f "$envdef" ] && rm -f "$envdef" > /dev/null 2>&1
	(. se.sh -nomkdir $1 > /dev/null 2>&1; set > "$envdef")
	shift
	while [ $# -ne 0 ]; do
		_tmp_=`grep "^${1}=" "$envdef" 2> /dev/null`
		_tmp_=${_tmp_#${1}=}
		if [ "${_tmp_#\"}" != "${_tmp_}" ]; then
			_tmp_=${_tmp_#?}; _tmp_=${_tmp_%?}
		fi
		export $1="$_tmp_"
		shift
	done
	rm -f "$envdef" > /dev/null 2>&1
	unset var _tmp_ envdef
fi