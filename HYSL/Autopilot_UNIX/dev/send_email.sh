#!/usr/bin/ksh
# send_email.sh : Send e-mail
# Description:
#     This script send an e-mail based on autopilot format.
#       line 1  : e-mail addresses
#       line 2  : Subject
#       line 3- : Mail body.
# Syntax: send_email.sh [-h] <msgdef> [<msgdef>...]
# Options:
#   -h: Display help.
# Message definition: <msgdef>
#   noap:        : No autopilot mode(no addr/sbj lines).
#   to:<addr>    : Add <addr> to the e-mail address
#   sbj:<sbj>    : Define subject string.
#   sep:         : Add line separater to mail body.
#   msg:<msg>    : Add <msg> to the mail body
#   ind:<indstr> : Define indent string.
#                  When you define this definition, the leading part
#                  will be added with <indstr> a head of line to the
#                  mail body.
#   ne:<file>    : Add <file> without eval process.
#   ev:<file>    : Add <file> with eval process.
#                  So, when the file contains "$LOGNAME", it will be
#                  replaced with a real login name.
#   <content>    : If the ap mode is autopilot mode, add <content> as
#                  a ev:<content> file. If no autopilot mode, add <con
#                  tents> as msg:<content>
# Note: The variables used in <file> need to export or in same sh level.
#       So, if <file> has $VERSION
#       1) And define it using "export", you can do:
#             $ export VERSION=1.2.3
#             $ send_email.sh ./form.txt
#       2) Or define only current sh, you need do:
#             $ VERSION=1.2.3
#             $ . send_email.sh ./form.txt
#       3) Or defined only current sh and you don't want to change any
#          current variables, you need do:
#             $ VERSION=1.2.3; _me="abc" # this tool set _me to own name
#             $ (. send_email.sh ./form.txt; echo "_me=$_me")
#             $ echo "_me=$_me"
# Sample:
# $ send_email.sh $AUTOPILOT/form/01_diff_notification.txt
# $ send_email.sh "noap:" "to:yukio.kono@oracle.com" "sbj:Test email" 
#                 "msg:This is test e-mail" "sep:" "txt:sent by send_email.sh"
#  
#########################################################################
# History:
# 2012/02/20	YKono	First edition from start_regress.sh
# 2012/10/18    YKono   Implement Bug 14780983 - SUPPORT AIME* USER IN THE E-MAIL TARGET.

_ai=`which apinc.sh 2> /dev/null`
if [ -n "$_ai" -a "${_ai#no }" = "$_ai" ]; then
	sm_lst=$(
		. apinc.sh
		set_vardef=
		set_vardef AP_EMAILLIST > /dev/null 2>&1
		echo $AP_EMAILLIST
	)
fi
sm_me=$0
sm_op=$@
unset sm_ea sm_i sm_sbj sm_org sm_yp
sm_wsmtp=internal-mail-router.oracle.com
sm_ap=true
sm_bf=false
sm_tf="$HOME/${LOGNAME}@$(hostname)_send_email.tmp"
rm -rf ${sm_tf} > /dev/null 2>&1
while [ $# -ne 0 -a "$sm_bf" = "false" ]; do
	case $1 in
		-h)
			sm_hp=`grep -n "# History:" $sm_me 2> /dev/null`
			sm_hp=${sm_hp%%:*}
			let sm_hp=sm_hp-2
			( IFS=; skip_flag=
			  head -${sm_hp} $sm_me | while read l; do
				[ -z "$skip_flag" ] && skip_flag=skipped || echo ${l#??}
			  done)
			sm_bf=true
			;;
		sbj:*)
			sm_sbj=${1#sbj:}
			;;
		noap:*|noap|-noap)
			sm_ap=false
			;;
		ind:*)
			sm_i=${1#ind:}
			;;
		ne:*)
			if [ -f "${1#ne:}" ]; then
				(IFS=
				cat "${1#ne:}" | while read -r l; do
					print -r "${sm_i}${l}" >> "${sm_tf}"
				done)
			fi
			;;
		ev:*)
			if [ -f "${1#ev:}" ]; then
				(IFS=
				cat "${1#ev:}" | egrep -v ^# | while read -r l; do
					[ "$l" != "${l#*\$}" ] && l=`eval echo \"$l\"`
					print -r "${sm_i}${l}" >> "${sm_tf}"
				done)
			fi
			;;
		msg:*|Msg:*|Txt:*|txt:*|TXT:*|MSG:*)
			(IFS=; echo "${sm_i}${1#????}" >> "${sm_tf}")
			;;
		sep:*|line:*)
			(IFS=; echo "${sm_i}========================================" >> "${sm_tf}")
			;;
		to:*|To:*|TO:*)
			[ -z "$sm_ea" ] && sm_ea=${1#???} || sm_ea="$sm_ea ${1#???}"
			;;
		*)
			if [ "$sm_ap" = "false" ]; then
				(IFS=; echo "${sm_i}${1}" >> "${sm_tf}")
			else
				if [ -f "$1" ]; then
					(IFS=
					cat "$1" | egrep -v ^# | while read -r l; do
						[ "$l" != "${l#*\$}" ] && l=`eval echo \"$l\"`
						echo "${sm_i}$l" >> "${sm_tf}"
					done)
				fi
			fi
			;;
	esac
	shift
done

if [ "$sm_bf" = "false" -a -f "$sm_tf" ]; then
	if [ "$sm_ap" = "true" ]; then
		sm_adr=`head -1 "$sm_tf" | tr -d '\r'`
		if [ -z "$sm_sbj" ]; then
			sm_sbj=`head -2 "$sm_tf" | tail -1 | tr -d '\r'`
		fi
	fi
	if [ -n "$sm_ea" ]; then
		[ -z "$sm_adr" ] && sm_adr=$sm_ea || sm_adr="$sm_ea $sm_adr"
	fi
	if [ "$AP_NOEMAIL" = "true" ]; then
		[ -n "$AP_NOEMAIL_REASON" ] \
			&& sm_org="No email by $AP_NOEMAIL_REASON\nOrg To:$sm_adr" \
			|| sm_org="Org To:$sm_adr"
		sm_adr="NoMail"
	elif [ "$AP_NOEMAIL" != "false" -a -n "$AP_NOEMAIL" ]; then
		sm_org="Org To:$sm_adr"
		sm_adr="$AP_NOEMAIL"
	fi
	if [ -n "$sm_lst" -a -f "$sm_lst" ]; then
		sm_yp=$sm_lst
	elif [ -f "$AUTOPILOT/data/email_list.txt" ]; then
		sm_yp=$AUTOPILOT/data/email_list.txt
	fi
	sm_lst=
	for sm_one in $sm_adr; do
		sm_at=${sm_one%@*}
		if [ "$sm_at" = "$sm_one" ]; then
			[ "${sm_one#aime}" != "$sm_one" ] && sm_one="${sm_one}@`get_platform.sh`"
			if [ -f "$sm_yp" ]; then
				_targ=`cat "$sm_yp" | grep "^${sm_one}[ 	]" \
					| grep -v "^#" | tail -1 | tr -d '\r'`
			else
				_targ=
			fi
			if [ -n "$_targ" ]; then
				sm_one=`echo "$_targ" | sed -e s/^${sm_one}//g \
					-e s/#.*$//g \
					-e "s/^[ 	]*//g" -e "s/[ 	]*$//g" \
					-e "s/[ 	][ 	]*/ /g"`
			else
				sm_one=
			fi
		fi
		if [ -n "$sm_one" ]; then
			[ -z "$sm_lst" ] \
				&& sm_lst=$sm_one \
				|| sm_lst="$sm_lst $sm_one"
		fi
	done
	if [ -n "$sm_lst" ]; then
		sm_ln=`cat "$sm_tf" | wc -l`
		[ "$sm_ap" = "true" ] && let sm_ln=sm_ln-2 || let sm_ln=sm_ln
		if [ "`uname`" = "Windows_NT" ]; then
			( [ -n "$sm_org" ] && echo "$sm_org\n"
			  [ "$sm_ap" = "true" ] && echo "Recipient: $sm_lst"
			  tail -${sm_ln} $sm_tf 
			) | smtpmail -s "$sm_sbj" -h ${sm_wsmtp} \
				-f "not-reply@autopilot.oracle.com" ${sm_lst}
		else
			( [ -n "$sm_org" ] && echo "$sm_org\n"
			  [ "$sm_ap" = "true" ] && echo "Recipient: $sm_lst"
			  tail -${sm_ln} $sm_tf 
			) | mailx -s "$sm_sbj" ${sm_lst}
		fi
		if [ -d "$AUTOPILOT/mail_sent" ]; then
			sm_fname="$AUTOPILOT/mail_sent/${LOGNAME}@`hostname`_`date +%m%d%y_%H%M%S`.txt"
			cp "$sm_tf" $sm_fname 2> /dev/null
			echo "sm_lst:$sm_lst" >> $sm_fname
			echo "sm_sbj:$sm_sbj" >> $sm_fname
		fi
	else
		echo "${sm_me##*/}:No target address."
	fi
fi

rm -rf ${sm_tf} > /dev/null 2>&1

