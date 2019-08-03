#!/usr/bin/ksh
# get_instkind.sh : Get installer kind.
# Description:
#    This command display the installer informaiton of current product installation.
# Syntax:
#    get_instkind.sh [-h|-l|-s|-n|-i]
# Options:
#    -h : Display help.
#    -l : Display installer information in long format.
#    -n : Display installer information in normal format.(default)
#    -s : Display installer information in short format.
#    -i : Ignore refres_version.txt
#
# History:
# 2012/03/02	YKono	First edition
# 2013/07/19	YKono	Support mutiple line of bipatch_version.txt
# 2013/07/29	YKono	Bug 17236360 - BI PATCH SUPPORT MULTIPLE ZIP INSTALLATION.

. apinc.sh

me=$0
orgpar=$@
disp=normal
ignrefresh=false
while [ $# -ne 0 ]; do
	case $1 in
		-h)	display_help.sh $me
			exit 0 ;;
		-l)	disp=long ;;
		-s)	disp=short ;;
		-n)	disp=normal ;;
		-i)	ignrefresh=true;;
		*)	echo "${me##*/}:Too many parameter."
			echo "params:$orgpar"
			exit 1
			;;
	esac
	shift
done

if [ -z "$HYPERION_HOME" ]; then
	echo "${me##*/}:No HYPERION_HOME defined."
	exit 1
fi

# Get installer information 02/17/2009
if [ -f "$HYPERION_HOME/refresh_version.txt" -a "$ignrefresh" = "false" ]; then
	case $disp in
		long)	dsppara="-l";;
		short)	dsppar="-s";;
		*)	dsppar="-n";;
	esac
	refver=`cat $HYPERION_HOME/refresh_version.txt | tr -d '\r'`
	baseinst=`get_instkind.sh $dsppara -i`
	[ "$baseinst" = "Unknown" -o "$baseinst" = "unknown" ] \
		&& unset baseinst \
		|| baseinst="($baseinst)"
	detail="REFRESH ${refver}${baseinst}"
	inst="refresh${baseinst}"
	short="refresh${baseinst}"
elif [ -f "$HYPERION_HOME/bipatch_version.txt" ]; then
	bip=`cat $HYPERION_HOME/bipatch_version.txt | grep BIFNDNEPM | tr -d '\r'`
	[ -z "$bip" ] && bip=`cat $HYPERION_HOME/bipatch_version.txt | head -1 | tr -d '\r'`
	bip=${bip%% *}
	bip=${bip##*/}
	bi=`cat $HYPERION_HOME/bi_label.txt 2> /dev/null | tr -d '\r'`
	sbi=${bi#*_}
	sbiv=${sbi%%_*}
	sbi=${sbi##*_}
	inst="BIP_$bip($sbiv/$sbi)"
	detail="BIPATCH $bip(base:$bi)"
	short="bipatch"
elif [ -f "$HYPERION_HOME/opack_version.txt" ]; then
	# from hyslinst.sh
	# 11.1.2.2.100:2141(base:11.1.2.2.100 hit[7767])
	# 11.1.2.3.000:4412(base:bi[BISHIPHOME_11.1.1.7.0_WINDOWS.X64_130306.1901])
	detail=`cat $HYPERION_HOME/opack_version.txt | tr -d '\r'`
	inst=${detail#*base:}
	inst=${inst%]*}
	if [ "${inst#bi}" != "$inst" ]; then
		biv=${inst#*_}
		biv=${biv%%_*}
		bid=${inst##*_}
		bid=${bid%?}
		basestr="bi:$biv/$bid"
	else
		hitb=${inst##*hit\[}
		hitv=${inst% *}
		basestr="${hitv}:${hitb}"
	fi
	bldn=${detail%%\(*}
	bldn=${bldn#*:}
	inst="OP_$bldn($basestr)"
	detail="OPACK ${detail}"
	short="opack"
elif [ -f "$HYPERION_HOME/hit_version.txt" ]; then
	# from hitinst.sh
	# prodpost/11.1.2.2.0/build_7767
	detail=`cat $HYPERION_HOME/hit_version.txt | tr -d '\r'`
	inst="hit_${detail##*_}"
	short="hit"
	detail="HIT $detail"
elif [ -f "$HYPERION_HOME/bi_version.txt" ]; then
	# bi_version.txt BI(BISHIPHOME_11.1.1.6.0_LINUX.X64_120105.0840/120105.0840)
	# bi_label.txt BISHIPHOME_11.1.1.6.0_LINUX.X64_120105.0840
	detail=`cat $HYPERION_HOME/bi_label.txt | tr -d '\r'`
	inst=${detail#*_}	# Remove BISHIPHOME_
	inst=${inst%%_*}	# Pick out the version/label number like 11.1.1.7.0
	inst="bi_${inst}/${detail##*_}"	# Add time stamp, branch, part.
	inst="bi_${detail}"
	short="bi"
elif [ -f "$HYPERION_HOME/cd_version.txt" ]; then
	# from cdinst.sh
	# CD <ver>/<bld>/cd|installer/<plat> -> location from BUILD_ROOT
	detail=`cat $HYPERION_HOME/cd_version.txt | tr -d '\r'`
	inst="CD"
	short="cd"
else
	detail="Unknown"
	inst="Unknown"
	short="unknown"
fi

case $disp in
	normal)	echo "$inst";;
	short)	echo "$short";;
	long)	echo "$detail";;
esac


