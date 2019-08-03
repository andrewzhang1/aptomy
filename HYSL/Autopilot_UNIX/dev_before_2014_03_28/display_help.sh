#!/usr/bin/ksh
############################################################################
# display_help.sh : Display help contens of the script v0.8
#
# Syntax:
#   display_help.sh [<script>|-s]
# 
# Parameter:
#   <script> : The target script to display help
#              When you skip this parameter, this script display the help
#              of this script (display_help.sh).
#
# Options:
#   -s   : Display sample section too.
# 
# Description:
#   This script display the help contens at head part of the <script> command.
#   This script start to display from the line following format:
#       # <script name>.sh : <description>
#   to "# History:" or "# Sample:" line
#   When the sample option is passed, this command display contents to the 
#   the "# History" section.
#   So, when there is no sample section and use "-s" option doesn't display
#   any samples.
#
############################################################################
# HISTORY:
############################################################################
# 2011/08/12	YKono	First Edition

# Read parameter
orgpara=$@
targ=`which display_help.sh`
sample=false
while [ $# -ne 0 ]; do
	case $1 in
		-s)
			sample=true
			;;
		*)
			targ=`which $1`
			;;
	esac
	shift
done

[ "$sample" = "true" ] && endline="^# HISTORY:" \
	|| endline="^# HISTORY:|^# SAMPLE:|^# Example:"
descloc=`egrep -ni "^# .+\.sh :" $targ | head -1`
histloc=`egrep -ni "$endline" $targ | head -1`
descloc=${descloc%%:*}
histloc=${histloc%%:*}
let lcnt=histloc-descloc
let tcnt=$histloc-1
lastline=`head -${tcnt} $targ | tail -1`
if [ "${lastline%${lastline#???}}" = "###" ]; then
	let tcnt=tcnt-1
	let lcnt=lcnt-1
fi
head -${tcnt} $targ | tail -${lcnt} | while read line; do
	[ "$line" = "#" ] && echo "" || echo "${line##??}"
done

