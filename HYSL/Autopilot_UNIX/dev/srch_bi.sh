#!/usr/bin/ksh
###############################################################################
# srch_bi.sh : Search BISHIPHOME by Essbase version and build number v1.1
#
# SYNTAX1: Search ssbase ver/bld from BISHIPHOME
#   srch_bi.sh [<options>] [<ver> [<bld>]]
# PARAMETERS:
#   <ver> : The Essbase version number for search.
#           When you skip <ver> parameter, then this command display BI branch.
#   <bld> : The Essbase build number for search.
#           Whne you skip <bld> but use <ver> parameter, then this command
#           search the BISHIPHOME with <ver>.
# OPTIONS:      <options>:=[-h|-p <plat>|-bi <bilbl>|-pref <pref>|-lp|-dp|-w]
#   -h          : Display help.
#   -p <plat>   : Platform to search.
#                 When you skip this option, this script uses current platform.
#   -bi <bilbl> : Search BISHIPHOME branch label.
#                 MAIN, 11.1.1.5.0, 11.1.1.5.1MLR, MAIN:LATEST...
#                 When you skip this option, this script attempt to search.
#                 every BISHIPHOME_*_<BISHIP.PLAT>.rdd folders.
#                 i.e.) MAIN:110801.2200, 11.1.1.5.0, MAIN:LATEST
#   -pref <pref>: Use <pref> instead of "BISHIPHOME".
#   -lp         : List prefixes
#   -dp         : Display prefix
#   -w          : Display wide for BI labels like BISHIPHOME_MAIN_LINUX.X64.rdd.
#
# EXIT CODE:
#   $? = 0 : Success to display.
#        1 : Too many parameters.
#        2 : The platform is not supported by ADE now.
#        3 : No specified label found on BISHIPHOME locaiton
#        4 : Target Essbase <ver>:<bld> not found.
#
# Sample:
# 1) Search BISHIPHOME which include Essbase 11.1.2.2.001 3009
#    $ srch_bi.sh 11.1.2.2.001 3009
# 2) Search BISHIPHOME which uses Essabse 11.1.2.2.001
#    $ srch_bi.sh 11.1.2.2.001
# 3) Search BISHIPHOME with uses Essbase 11.1.2.2.001 under 11.1.1.6.2 branch
#    $ srch_bi.sh 11.1.2.2.001 -bi 11.1.1.6.2
# 4) Search BISHIPHOME under MAIN branch and 120425.0900 label
#    $ srch_bi.sh -bi MAIN/120425.0900
# 5) List up branch names
#    $ srch_bi.sh
# 6) List up branch names under BIAPPS prefix
#    $ srch_bi.sh -pref BIAPPS
# 7) List prefixes
#    $ srch_bi.sh -lp
#
###############################################################################
# HISTORY:
###############################################################################
# 2011/08/12	YKono	First edition
# 2012/05/02	YKono	Support AP_BIPREFIX
# 2012/08/27	YKono	Add zip file check.

. apinc.sh

# FUNCTION
ess_ver() {
	if [ ! -f "${1}" ]; then
		ev="NO VER XML"
	else
		est=`grep -n "\<Name\>essbase\</Name\>" $1`
		est=${est%%:*}
		ttl=`cat $1 | wc -l`
		let ttl=ttl-est
		ev=`tail -${ttl} $1 | grep "\<Release\>"`
		ev=${ev##\<Release\>}
		ev=${ev%%\</Release\>*}
		eb=${ev#*.*.*.*.*.}
		ev=${ev%.*}
		ev="${ev}:${eb}"
	fi
	echo $ev
}

# MAIN
unset set_vardef; set_vardef AP_BIPREFIX

me=$0
orgpar=$@
plat=
ver=
bld=
biver=
wide=
dp=
lsprefix=false
dbg=false
while [ $# -ne 0 ]; do
	case $1 in
		`isplat $1`)
			plat=$1
			;;
		-w|wide)
			wide=true
			;;
		-dp|disppref)
			dp=true
			;;
		-p|-plat|-platform)
			if [ $# -lt 2 ]; then
				echo "-p need <plat> paramter."
				echo "params: $orgpar"
				exit 1
			fi
			shift
			plat=$1
			;;
		-pref|-prefix|at|@|with)
			if [ $# -lt 2 ]; then
				echo "-pref need second parameter."
				echo "parms: $orgpar"
				exit 1
			fi
			shift
			export AP_BIPREFIX=$1
			;;
		pref=*|PREF=*|prefix=*|PREFIX=*)
			export AP_BIPREFIX=${1#*=}
			;;
		-lp|-lsprefix|lspref|psrefix)
			lsprefix=true
			;;
		bi:*|BI:*|bi=*|BI=*|bi_*|BI_*)
			biver=${1#???}
			;;
		-bi|-biver|bi|in)
			if [ $# -lt 2 ]; then
				echo "$1 parameter need <bi-label> parameter."
				echo "params: $orgpar"
				display_help.sh $me
				exit 1
			fi
			shift
			biver=$1
			;;
		+dbg)	dbg=true;;
		-dbg)	dbg=false;;
		-h)
			display_help.sh $me
			exit 0
			;;
		-hs)
			display_help.sh -s $me
			exit 0
			;;
		*)
			if [ -z "$ver" ]; then
				ver=$1
			else
				if [ -z "$bld" ]; then
					bld=$1
				else
					echo "Too many parameter."
					echo "params: $orgpar"
					exit 1
				fi
			fi
			;;
	esac
	shift
done

[ -z "$plat" ] && plat=`get_platform.sh`
[ "$dbg" = "true" ] && echo "# Error check by BI platform."
biplat=`biplat.sh $plat`
if [ $? -ne 0 ]; then
	echo "$plat is not supported by ADE now."
	exit 2
fi
[ "$dbg" = "true" ] && echo "#   ap:$plat -> bi:$biplat"

[ "$dbg" = "true" ] && echo "# BILOC check by BI platform."
biloc=`biloc.sh -p $plat`
if [ $? -ne 0 ]; then
	echo "$plat is not supported by ADE now."
	exit 2
fi
[ "$dbg" = "true" ] && echo "#   biloc:$biloc"

if [ ! -d "$biloc" ]; then
	echo "Cannot access $biloc."
	echo "Please check supported platform and ADE location."
	exit 2
fi

[ "$dbg" = "true" ] && echo "# Check biPrefix in '$_OPTION' ($AP_BIPREFIX)."
# Check biPrefix in _OPTION
if [ -n "$_OPTION" ]; then
	bip=`chk_para.sh biPrefix "$_OPTION"`
	bip=${bip#* }
	[ -n "$bip" ] && AP_BIPREFIX=$bip
fi

[ "$dbg" = "true" ] && echo "# Define BI branch and laval from $biver."
if [ -n "$biver" ]; then
	if [ "${biver}" = "${biver#*/}" ]; then
		bibld=
	else
		bibld=${biver#*/}
		biver=${biver%/*}
	fi
	_bipref=
	if [ "$biver" != "${biver#*@}" ]; then
		_bipref=${biver#*@}
		biver=${biver%%@*}
	fi
	if [ "$bibld" != "${bibld#*@}" ]; then
		_bipref=${bibld#*@}
		bibld=${bibld%%@*}
	fi
	[ -n "$_bipref" ] && export AP_BIPREFIX=$_bipref
else
	unset biver bibld
fi

_bipref=`ls "${biloc}" 2> /dev/null | grep "$AP_BIPREFIX"`
if [ -z "$_bipref" ]; then
	echo "Cannot find $AP_BIPREFIX under $biloc."
	echo "Please check the prefix($AP_BIPREFIX) string and $biloc contents."
	exit 2
fi

[ -n "$dp" ] && dp="@$AP_BIPREFIX"

if [ "$dbg" = "true" ]; then
	echo "# plat  =$plat"
	echo "# BIplat=$biplat"
	echo "# BIloc =$biloc"
	echo "# ver   =$ver"
	echo "# bld   =$bld"
	echo "# BIver =$biver"
	echo "# BIbld =$bibld"
	echo "# dp    =$dp"
	echo "# prefix=$AP_BIPREFIX"
fi

[ "$dbg" = "true" ] && echo "# Check LsPrefix command and execute it."
if [ "$lsprefix" = "true" ]; then
	[ "$wide" = "true" ] && echo "Prefix list from $biloc:"
	prev=
	ls $biloc | grep .rdd$ | while read one; do
		a=${one%%_*}
		if [ "$a" != "$prev" ]; then
			[ "$wide" = "true" ] && echo "  $a" || echo "$a"
			prev=$a
		fi
	done
	exit 0
fi

lwr_biprefix=`echo $AP_BIPREFIX | tr A-Z a-z`
if [ -z "$ver" -a -z "$bld" ]; then
	if [ -n "$biver" ]; then	# List every labels for this platform
		lbl="${AP_BIPREFIX}_${biver}_${biplat}.rdd"
		if [ ! -d "${biloc}/${lbl}" ]; then
			echo "Couldn't find ${biloc}/${lbl} folder."
			exit 3
		fi
		if [ -n "$bibld" ]; then
			if [ ! -d "${biloc}/${lbl}/${bibld}" ]; then
				echo "Couldn't find ${biloc}/${lbl}/${bibld}"
				exit 3
			fi
			blds=$bibld
		else
			blds=`ls ${biloc}/${lbl} 2> /dev/null`
		fi
		for one in $blds; do
			vxml="${biloc}/${lbl}/${one}/bifndnepm/dist/stage/products/version-xml/essbase_version.xml"
			ev=`ess_ver $vxml`
			ls -d ${biloc}/${lbl}/${one}/${lwr_biprefix}/shiphome/*.zip > /dev/null 2>&1
			if [ $? -eq 0 ]; then
				[ "$wide" = "true" ] && echo "${lbl}/$one # $ev" || echo "${biver}${dp}/$one # $ev"
			else
				[ "$wide" = "true" ] && echo "${lbl}/$one-# $ev" || echo "${biver}${dp}/$one-# $ev"
			fi
		done | sort
	else	# List every build for this platfrom and label
		if [ ! -d "${biloc}" ]; then
			echo "Couldn't find ${biloc} folder."
			exit 3
		fi
		ls ${biloc} 2> /dev/null | grep ${AP_BIPREFIX}_ | grep ${biplat}.rdd | while read one; do
			if [ "$wide" = "true" ]; then
				echo "$one"
			else
				label=`echo $one | awk -F_ '{print $2}'`
				echo "$label${dp}"
			fi
		done | sort
	fi
else
	blds=
	if [ -n "$biver" ]; then
		labels="${AP_BIPREFIX}_${biver}_${biplat}.rdd"
		if [ ! -d "${biloc}/${labels}" ]; then
			echo "Couldn't find ${biloc}/${labels} folder."
			exit 3
		fi
		if [ -n "$bibld" ]; then
			if [ -d "${biloc}/${labels}/${bibld}" ]; then
				blds=$bibld
			else
				echo "Coudn't find ${biloc}/${labels}/${bibld} folder."
				exit 3
			fi
		fi
	else
		labels=`ls ${biloc} 2> /dev/null | grep ${AP_BIPREFIX} | grep "${biplat}.rdd"`
	fi
	fcnt=0
	for one in $labels; do
		[ -z "$blds" ] && blds=`ls "${biloc}/${one}" 2> /dev/null`
		for onebld in $blds; do
			vxml="${biloc}/${one}/${onebld}/bifndnepm/dist/stage/products/version-xml/essbase_version.xml"
			ev=`ess_ver $vxml`
			[ "$dbg" = "true" ] && echo "# ess_ver='$ev'($ver:$bld)"
			if [ "$ev" != "NO VER XML" ]; then
				fnd=true
				if [ -n "$bld" ]; then
					[ "$ver" != "${ev%:*}" -o "$bld" != "${ev#*:}" ] && fnd=false
				else
					[ "$ver" != "${ev%:*}" ] && fnd=false
				fi
				[ "$dbg" = "true" ] && ls -d ${biloc}/${one}/${onebld}/${lwr_biprefix}/shiphome/*.zip
				ls -d ${biloc}/${one}/${onebld}/${lwr_biprefix}/shiphome/*.zip > /dev/null 2>&1
				[ $? -ne 0 ] && fnd=false
				if [ "${fnd}" = "true" ]; then
					if [ "$wide" = "true" ]; then
						echo "$one/${onebld} # $ev"
					else
						lbl=${one#${AP_BIPREFIX}_}
						lbl=${lbl%%_*}
						echo "$lbl${dp}/${onebld} # $ev"
					fi
					let fcnt=fcnt+1
				fi
			fi
		done
		blds=
	done
	if [ "$fcnt" -eq 0 ]; then
		echo "# NO ${AP_BIPREFIX} FOUND for Essbase $ver:$bld"
		exit 4
	fi
fi

exit 0
