#!/usr/bin/ksh
######################################################################
# ver_vernum.sh : Return the inner format version number v1.0
######################################################################
# SYNTAX:
#   ver_vernum.sh [-h|-org|<ver>]
# PARAMETER:
#   <ver> : The version number to convert.
#           When you skip <ver> parmeter, this script read versions
#           from stdin. So, you can use this script as filter.
#           i.e.) Display vernum in the prodpost.
#             $ cd $HIT_ROOT/prodpost
#             $ ls | grep -v prodpost | ver_vernum.sh -org
#             011001001004000 11.1.1.4.0
#             011001002002000 11.1.2.2.0
#             011001001002000 dickens
#             011001001000000 kennedy
#             011001001001000 kennedy2
#             011001002000000 talleyrand
#             011001002001000 talleyrand_sp1
#             011001001003000 zola
# OPTIONS:
#   -h   : Display help.
#   -org : Display inner formatted version number with original
#          input.
#          i.e.) convert talleyrand_sp1
#            $ ver_vernum.sh -org talleyrand_sp1
#            011001002001000 talleyrand_sp1
# DESCRIPTION:
#   This script convert the version number into the inner formatted
#   version number which uses 3 digits for each block.
#   Convert sample:
#     talleyrand_sp1 -> 011001002001000
#     11.1.2.2.000   -> 011001002002000
#     11.1.2.2.0     -> 011001002002000
#     11.1.2.1.2     -> 011001002001002
#     9.3.1          -> 009003001000000
#     abcdef         -> def000000000000 # Wrong version is passed.
#
######################################################################
# HISTORY:
######################################################################
# 07/02/2009 YK - First Edition.

me=$0

d3()
{
	read pri
	pri="000$pri"
	echo ${pri#${pri%???}}
}

ver_num()
{
	unset dsp
	case $1 in
		11xmain)			dsp=011001002003000;;
		11.1.2.1.0|talleyrand_sp1|talleyrand_ps1|talleyrand_sp1_*)
						dsp=011001002001000;;
		11.1.2.0.0|talleyrand)		dsp=011001002000000;;
		11.1.1.3.1|zola_staging)	dsp=011001001003001;;
		11.1.1.3.0|zola)		dsp=011001001003000;;
		11.1.1.2.0|dickens)		dsp=011001001002000;;
		11.1.1.1.0|kennedy2)		dsp=011001001001000;;
		11.1.1.0.0|kennedy)		dsp=011001001000000;;
		9.3.1|barnes)			dsp=009003001000000;;
		9.3|beckett)			dsp=009003000000000;;
		9.0.1.0|london)			dsp=009000001000000;;
		9.0|joyce)			dsp=009000000000000;;
		6.1|tide)			dsp=006001000000000;;
		6.2|tsunami)			dsp=006002000000000;;
		7.0|zephy)			dsp=007000000000000;;
		6.5|woodstock)			dsp=006005000000000;;
		*)
			ver=${1##*/}
			v1=`echo $ver | awk -F. '{print $1}' | d3`
			v2=`echo $ver | awk -F. '{print $2}' | d3`
			v3=`echo $ver | awk -F. '{print $3}' | d3`
			v4=`echo $ver | awk -F. '{print $4}' | d3`
			v5=`echo $ver | awk -F. '{print $5}' | d3`
			dsp=${v1}${v2}${v3}${v4}${v5}
			;;
	esac
	[ -z "$dsporg" ] && echo $dsp || echo $dsp $1
}

# Parse parameter
unset vers dsporg
while [ $# -ne 0 ]; do
	case $1 in
		-h)
			display_help.sh $me
			exit 0
			;;
		-org)
			dsporg=true
			;;
		*)
			[ -z "$vers" ] && vers=$1 || vers="$vers $1"
			;;
	esac
	shift
done

if [ -n "$vers" ]; then
	for i in $vers; do
		ver_num $i
	done
else
	while read ver; do
		ver_num $ver
	done
fi

