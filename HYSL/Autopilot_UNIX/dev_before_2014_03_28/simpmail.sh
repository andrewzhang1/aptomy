#!/usr/bin/ksh
# simpmail.sh : Simple mail sender
# Desciption:
#     This script send a e-mail to the specific user's e-mail address.
#     This script also work beside AUTOPILOT framework and you can use
#     User aliases in $AUTOPILOT/data/email_list.txt.
# Syntax: simpmail.sh [-s <subject>|-m <message>|-f <file>] <to-addr> [<to-addr>...]
# Parameter:
#   <to-addr>    : e-mail address to send. You can define multiple e-mail addresses
#   -s <subject> : Define subject text. When you skip this parameter, 
#                  this script uses "(empty subject by simpmail.sh)".
#   -m <message> : Define message text.
#                  When you skip -m <message> and -f <file> parameter, this script
#                  script read mail body from stdin. The "." or EOF finish entry.
#   -f <file>    : Send <file> as mail body.
#   -h           : Display help.
# Sample:
# 1) Send message.
# $ simpmail.sh yukio.kono@oracle.com -s "Test mail" -m "ASAP!"
# 2) Send command output.
# $ cat test.err | simpmail.sh yukio.kono@oracle.com -s "TEST ALEART !!"
# 3) Send file.
# $ simpmail.sh yukio.kono@oracle.com -s "File mail" -f $HOME/test.out -m "Following is test output\n\n"
# History:
# 2012/02/16	YKono	First edition
# 2012/10/18    YKono   Implement Bug 14780983 - SUPPORT AIME* USER IN THE E-MAIL TARGET.

. apinc.sh

me=$0
orgpar=$@
unset addrs sbj msg fl
while [ $# -ne 0 ]; do
	case $1 in
		-h)	display_help.sh $me
			exit 0
			;;
		-m)	if [ $# -lt 2 ]; then
				echo "${me##*/}:$1 need second parameter."
				exit 1
			fi
			shift
			msg=$1
			;;
		-f)	if [ $# -lt 2 ]; then
				echo "${me##*/}:$1 need second parameter."
				exit 1
			fi
			shift
			if [ ! -f "$1" ]; then
				echo "${me##*/}:$1 not found."
				exit 2
			fi
			[ -z "$fl" ] && fl=$1 || fl="$fl $1"
			;;
		-s)	if [ $# -lt 2 ]; then
				echo "${me##*/}:$1 need second parameter."
				exit 1
			fi
			shift
			sbj=$1
			;;
		*)	[ -z "$addrs" ] && addrs=$1 || addrs="$addrs $1"
			;;
	esac
	shift
done

if [ -z "$addrs" ]; then
	echo "${me##*/}: mail need at least one to-address."
	exit 3
fi
if [ -n "$AUTOPILOT" -a -f "$AUTOPILOT/data/email_list.txt" ]; then
	tmplist=$addrs
	addrs=
	for one in $tmplist; do
		_post=${one#*@}
		if [ "$_post" = "$one" ]; then
			[ "${one#aime}" != "$one" ] && one="${one}@`get_platform.sh`"
			_targline=`cat "$AUTOPILOT/data/email_list.txt" | grep -v "^#" \
				| grep "^${one}[	 ]" | tail -1`
			if [ -n "$_targline" ]; then
				addr=$(
					echo "$_targline" | \
					sed -e s/^${one}//g -e s/#.*$//g \
						-e "s/^[ 	]*//g" \
						-e "s/[ 	]*$//g" \
						-e "s/[ 	][ 	]*/ /g"
				)
			else
				echo "${me##*/}:Failed to convert $one."
				exit 4
			fi
		else
			addr=$one
		fi
		if [ -n "$addr" ]; then
			[ -z "$addrs" ] && addrs=$addr || addrs="$addrs $addr"
		fi
	done
fi
tmpf=$HOME/simpmail.$$.tmp
rm -rf $tmpf > /dev/null 2>&1
winsmtp=internal-mail-router.oracle.com
if [ -z "$msg" -a -z "$fl" ]; then
	while read line; do
		[ "$line" = "." ] && break
		echo $line >> $tmpf
	done
else
	echo "$msg" >> $tmpf
fi
if [ -n "$fl" ]; then
	for one in $fl; do
		cat $one >> $tmpf
	done
fi
[ -z "$sbj" ] && sbj="(empty subject by simpmail.txt)"
if [ "`uname`" = "Windows_NT" ]; then
	cat $tmpf | smtpmail -s "$sbj" -h ${winsmtp} -f notreply_autopilot@oracle.com ${addrs}
else
	cat $tmpf | mailx -s "$sbj" ${addrs}
fi
sts=$?
rm -rf $tmpf > /dev/null 2>&1
exit $sts
