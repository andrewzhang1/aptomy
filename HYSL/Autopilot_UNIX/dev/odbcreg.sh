#!/usr/bin/ksh
# odbcreg.sh : Register ODBC registry
# Syntax1: odbcreg.sh > <output>
# Description1: Dump ODBC registry 
# Syntax2: odbcreg.sh -reg < <odbc-def-file>
# Description2: Register ODBC registry from standard input
# History:
# 2013/10/17 YKono   First edition

me=$0
orgpar=$@
if [ "`uname`" != "Windows_NT" ]; then
	echo "${me##*/}:This program only run on Windows platform."
	exit 1
fi

act=dmp
fnm=
while [ $# -ne 0 ]; do
	case $1 in
		-reg|reg)	act=reg ;;
		-dmp|dump|dmp)	act=dmp ;;
		*)
			;;
	esac
	shift
done

if [ "$act" = "dmp" ]; then
	H="HKEY_LOCAL_MACHINE\\SOFTWARE\\ODBC"
	registry -p -k $H | sed -e "s/\\\/\//g"
else
	if [ -z "$ODBC_HOME" ]; then
		echo "${me##*/}:Need \$ODBC_HOME definiton."
		exit 1
	fi
	while read line; do
		h=${line%%	*}
		line=${line#*	}
		k=${line%%	*}
		v=${line##*	}
		h=`echo $h | sed -e "s!/!\\\\\\!g"`
		v=${v%?}
		v=${v#?}
		if [ "$v" != "${v#*%ODBC_HOME%}" ]; then
			v="${v%\%ODBC_HOME\%*}${ODBC_HOME}${v#*%ODBC_HOME%}"
			v=`echo $v | sed -e "s!/!\\\\\\!g"`
		fi
		# registry -s -k "$h" -n "$k" -v "$v"
		reg add "$h" /v "$k" /d "$v" /f > /dev/null 2>&1
		# print -r  "($?)'$h' '$k' '$v'"
	done
fi

