#!/usr/bin/ksh
# depends.sh : Run depends program v1.0
# Description:
#     This script run the Dependancy Walker from command line.
#     Dependancy Walker only support windows platfomrs.
#     If you run this command from Unix platform, it doesn't
#     work well.
# Syntax:
#     depends.sh [-h|-hs] <target-modules>
# Parameters:
#    <target-modules> : Target exe/dll file.
# Options:
#     -h  : Display help.
#     -hs : Display help with sample.
# Sample:
#   $ depends.sh ESSBASE.EXE ESSCMD.EXE
#
# History:
# 2011/07/27	YKono	First edition

# display_help [-s] : Display help contents from script header.
#   -s : display sample section.
me=$0
display_help()
{
        [ "$1" = "-s" ] && endline="^# HISTORY:" \
                || endline="^# HISTORY:|^# SAMPLE:|^# Excample:"
        descloc=`egrep -ni "^# .+\.sh :" $me | head -1`
        histloc=`egrep -ni "$endline" $me | head -1`
        descloc=${descloc%%:*}
        histloc=${histloc%%:*}
        let lcnt="$histloc - $descloc"
        let tcnt="$histloc - 1"
        lastline=`head -${tcnt} $me | tail -1`
        if [ "${lastline%${lastline#???}}" = "###" ]; then
                let tcnt=tcnt-1
                let lcnt=lcnt-1
        fi
        head -${tcnt} $me | tail -${lcnt} | while read line; do
                [ "$line" = "#" ] && echo "" || echo "${line##??}"
        done
}


# -------------------------------------------------------------------------
# Read parameters
orgparam=$@
pars=
while [ $# -ne 0 ]; do
        case $1 in
                -h)
                        display_help
                        exit 0
                        ;;
		-hs)
			display_help -s
			exit 0
			;;
		*)
			[ -z "$pars" ] && pars=$1 || pars="$pars $1"
			;;
	esac
	shift
done

# ==========================================================================
# Main
me=`which depends.sh`
if [ $? -ne 0 -o "x${me#no}" != "x${me}" ]; then
        echo "depends.sh : Couldn't find the execution path for me."
        exit 2
fi

myplat=`get_platform.sh`
if [ "${myplat#win}" != "${myplat}" ]; then
	if [ "$myplat" = "winamd64" ]; then
		mypath="${me%/*}/depends_x64"
	elif [ "$myplat" = "win64" ]; then
		mypath="${me%/*}/depends_ia64"
	else
		mypath="${me%/*}/depends_x86"
	fi
	export PATH="${mypath};$PATH"
	echo "depends.exe /c /ot:$HOME/depends.out $pars"
	depends.exe /c /ot:$HOME/depends.out $pars
	sts=$?
	cat $HOME/depends.out
	rm -f $HOME/depends.out > /dev/null 2>&1
else
	echo "This program only run on Windows platform."
fi
exit 0
