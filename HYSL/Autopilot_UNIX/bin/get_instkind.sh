#!/usr/bin/ksh
# get_instkind.sh : Get installer kind.
# Description:
#    This command display the installer informaiton of current product installation.
# Syntax:
#    get_instkind.sh [-h|-l|-s|-n]
# Options:
#    -h : Display help.
#    -l : Display installer information in long format.
#    -n : Display installer information in normal format.(default)
#    -s : Display installer information in short format.
#
# Hisotry:
# 2012/03/02	YKono	First edition
. apinc.sh
me=$0
orgpar=$@
disp=normal
while [ $# -ne 0 ]; do
	case $1 in
		-h)	display_help.sh $me
			exit 0 ;;
		-l)	disp=long ;;
		-s)	disp=short ;;
		-n)	disp=normal ;;
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
if [ -f "$HYPERION_HOME/refresh_version.txt" ]; then
	# from hyslinst.sh
	# 11.1.2.2.100:2141
	if [ -f "$HYPERION_HOME/opack_version.txt" ]; then
		# from hyslinst.sh
		# 11.1.2.2.100:2141(base:11.1.2.2.100 hit[7767])
		detail=`cat $HYPERION_HOME/opack_version.txt | tr -d '\r'`
		add=${detail%%\(*}
		detail=${detail#*hit[}
		detail=${detail%]*}
		add="(OP_${add}:hit[$detail])"
		detail="OPACK `cat $HYPERION_HOME/opack_version.txt | tr -d '\r'`"
	elif [ -f "$HYPERION_HOME/hit_version.txt" ]; then
		# from hitinst.sh
		# prodpost/11.1.2.2.0/build_7767
		detail="HIT `cat $HYPERION_HOME/hit_version.txt | tr -d '\r'`"
		add="(hit[${detail#*build_}])"
	elif [ -f "$HYPERION_HOME/bi_version.txt" ]; then
		# bi_version.txt BI(BISHIPHOME_11.1.1.6.0_LINUX.X64_120105.0840/120105.0840)
		# bi_label.txt BISHIPHOME_11.1.1.6.0_LINUX.X64_120105.0840
		detail=`cat $HYPERION_HOME/bi_label.txt | tr -d '\r'`
		add=$detail
		add=${add#BISHIPHOME_}
		add="BI ${add%%_*}/${add##*_}"
		add="(${add})"
	elif [ -f "$HYPERION_HOME/cd_version.txt" ]; then
		# from cdinst.sh
		# CD <ver>/<bld>/cd|installer/<plat> -> location from BUILD_ROOT
		detail=`cat $HYPERION_HOME/cd_version.txt | tr -d '\r'`
		add="(CD)"
	else
		add=""
	fi
	detail="REFRESH `cat $HYPERION_HOME/refresh_version.txt | tr -d '\r'`($detail)"
	inst="refresh${add}"
	short="refresh"
elif [ -f "$HYPERION_HOME/opack_version.txt" ]; then
	# from hyslinst.sh
	# 11.1.2.2.100:2141(base:11.1.2.2.100 hit[7767])
	detail=`cat $HYPERION_HOME/opack_version.txt | tr -d '\r'`
	inst=`echo $detail | sed -e "s/base://g" -e "s/ hit\[/:/g"  -e "s/ bi\[/:/g" -e "s/\]//g"`
	inst=${inst#*:}
	inst="OP_$inst"
	[ -f "$HYPERION_HOME/hit_version.txt" ] \
		&& hit=" from `cat $HYPERION_HOME/hit_version.txt | tr -d '\r'`" \
		|| hit=
	detail="OPACK ${detail}${hit}"
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


