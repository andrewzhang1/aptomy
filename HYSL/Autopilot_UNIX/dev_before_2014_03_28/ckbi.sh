#!/usr/bin/ksh
# ckbi.sh : Check BISHIPHOME zip images.
# Description:
#   Check the BISHIPHOME related information from <loc>
# Syntax:
#   ckbi.sh [-h|-d|-s] <loc>
# Parameter:
#   <loc> : BISHIPHOME location.
# Option:
#   -h : Display help.
#   -d : Display detailed information.
#   -s : Display short display
#
############################################################################
# History:
############################################################################
# 2012/10/26	YKono	First Edition.

# FUNCTION
ver() {
	if [ $# -lt 2 ]; then
		prod=essbase
	else
		prod=$2
	fi
	xml="$1/${prod}_version.xml"
        if [ ! -f "${xml}" ]; then
                ev="NO VER XML"
        else
                est=`grep -n "\<Name\>${prod}\</Name\>" $xml`
                est=${est%%:*}
                ttl=`cat $xml | wc -l`
                let ttl=ttl-est
                ev=`tail -${ttl} $xml | grep "\<Release\>"`
                ev=${ev##\<Release\>}
                ev=${ev%%\</Release\>*}
                eb=${ev#*.*.*.*.*.}
                ev=${ev%.*}
                ev="${ev}:${eb}"
        fi
       echo $ev
}

me=$0
orgpar=$@
locs=
detail=true
while [ $# -ne 0 ]; do
	case $1 in
		-h)
			display_help.sh $me
			exit 0
			;;
		-d)
			detail=true
			;;
		-s)
			detail=false
			;;
		*)
			[ -z "$locs" ] && locs=$1 || locs="$locs $1"
			;;
	esac
	shift
done

display_one()
{
	one=$1
	[ "$detail" = "false" ] && dsp="$one"
	if [ ! -d "$one" ]; then
		[ "$detail" = "false" ] && dsp="$dsp|<not-fnd>" || echo "$one not found"
	else
		[ "$detail" = "true" ] && echo "$one:"
		verf=$one/bifndnepm/dist/stage/products/version-xml
		if [ -f "$verf/essbase_version.xml" ]; then
			ev=`ver $verf`
			[ "$detail" = "false" ] && dsp="$dsp|$ev" || echo "  Essbase version: $ev"
			
		else
			[ "$detail" = "false" ] && dsp="$dsp|<no-VerXML>" || echo "  !! essbase_version.xml file not found."
		fi
		if [ "$detail" = "true" ]; then
			for p in EAS APS EssbaseStudio SVC installer; do
				if [ -f "${verf}/${p}_version.xml" ]; then
					ev=`ver $verf $p`
					echo "  $p version: $ev"
				fi
			done
		fi

		ls -d ${one}/bishiphome/shiphome/*.zip > /dev/null 2>&1
		if [ $? -eq 0 ]; then
			[ "$detail" = "false" ] && dsp="$dsp|zips" || ls -d $one/bishiphome/shiphome/*.zip | \
				while read one; do echo "  $one"; done
		else
			[ "$detail" = "false" ] && dsp="$dsp|<no-zip>" || echo "  !! There is no zip files under bishiphome/shiphome"
		fi

		ls $one/bishiphome/RCUINTEGRATION_* > /dev/null 2>&1
		if [ $? -ne 0 ]; then
			[ "$detail" = "false" ] && dsp="$dsp|<no-RCUptr>" || echo "  !! There is no RCU pinter file."
		else
			ptr=`cat $one/bishiphome/RCUINTEGRATION_* 2> /dev/null | tail -1 | tr -d '\r'`
			[ "$detail" = "false" ] && dsp="$dsp|$ptr" || echo "  RCU Pointer:$ptr"
		fi
	fi
	[ "$detail" = "false" ] && echo $dsp
}

if [ -n "$locs" ]; then
	for one in $locs; do display_one $one; done
else
	while read one; do
		case $one in
			exit|quit|q) break;;
			*) display_one $one;;
		esac
	done
fi
