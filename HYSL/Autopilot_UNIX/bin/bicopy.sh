#!/usr/bin/ksh
# bicopy.sh : Copy BI zip images
# Description:
#   This program copy/synchronize the BI zip imagnes.
# Syntax:
#   bicopy.sh [-h|-hs|-norcu|-p <plat>|-b <brnch>|-s <src>|-t <trg>] <lbl> [<lbl>...]
# Parameter:
#   -p <plat>  : Sync target platform in the autopilot format.
#             Default value is a current platform.
#   -b <brnch> : The target branch label for synchronize like MAIN, 11.1.1.7.0...
#             Default value is 11.1.1.7.0.
#   -s <src>   : Source location like /ade_autofs/ade_generic3.
#             Default value is /ade_autofs/ade_generic3.
#   -t <trg>   : Target destination location.
#             Default is current folder.
#   <lbl>      : Target label to synchronize like 121226.1010...
# Options:
#   -h|-hs: Display help.
#   -norcu: Do not syncronize the RCU zip.
# Sample:
# History:
# 2012/12/27	YKono	First edition


. apinc.sh
unset set_vardef; set_vardef BISYNC_BRANCH BISYNC_SOURCE
umask 000
me=$0
orgpar=$@
plat=`get_platform.sh`
brnch=$BISYNC_BRANCH
src=$BISYNC_SOURCE
trg=`pwd`
rcu=true
while [ $# -ne 0 ]; do
	case $1 in
		-h)
			display_help.sh $me
			exit 0
			;;
		-hs)
			display_help.sh -s $me
			exit 0
			;;
		`isplat $1`)
			plat=$1
			;;
		-rcu)
			rcu=true
			;;
		-norcu)
			rcu=false
			;;
		-p)
			shift
			if [ $# -eq 0 ]; then
				echo "${me##*/}:\"$1\" need second parameter as platform."
				exit 1
			fi
			plat=$1
			;;
		-t)
			shift
			if [ $# -eq 0 ]; then
				echo "${me##*/}:\"$1\" need second parameter as target location."
				exit 1
			fi
			trg=$1
			;;
		-s)
			shift
			if [ $# -eq 0 ]; then
				echo "${me##*/}:\"$1\" need second parameter as source location."
				exit 1
			fi
			src=$1
			;;
		-b)
			shift
			if [ $# -eq 0 ]; then
				echo "${me##*/}:\"$1\" need second parameter as branch."
				exit 1
			fi
			brnch=$1
			;;
		*)
			if [ -z "$lbl" ]; then
				lbl=$1
			else
				lbl="$lbl $1"
			fi
			;;
	esac
	shift
done
biplat=`biplat.sh $plat`
srcloc="`biloc.sh $src`/BISHIPHOME_${brnch}_${biplat}.rdd"
if [ -z "$lbl" ]; then
	echo "BISYNC_SOURCE=$src"
	echo "BISYNC_BRANCH=$brnch"
	echo "BIPLATFORM   =$biplat"
	ls -l $srcloc
	exit 0
fi

if [ ! -d "${trg}/BISHIPHOME_${brnch}_${biplat}.rdd" ]; then
	mkdir ${trg}/BISHIPHOME_${brnch}_${biplat}.rdd
	if [ ! -d "${trg}/BISHIPHOME_${brnch}_${biplat}.rdd" ]; then
		echo "${me##*/}:Failed to create the BISHIPHOME_${brnch}_${biplat}.rdd folder."
		exit 2
	fi
fi

cp_one()
{
	one=$1
	if [ ! -d "$srcloc/$one" ]; then
		echo "${me##*/}:$one:Couldn't find $one folder under the $srcloc. Skip $one."
	elif [ -f "$trg/BISHIPHOME_${brnch}_${biplat}.rdd/$one" ]; then
		echo "${me##*/}:$one:$one already exists. Skip $one."
	else
		bishipf="bishiphome/shiphome"
		srczipf="$srcloc/$one/$bishipf"
		trgzipf="$trg/BISHIPHOME_${brnch}_${biplat}.rdd/$one/$bishipf"
		verf="bifndnepm/dist/stage/products/version-xml"
		srcverf="$srcloc/$one/$verf"
		trgverf="$trg/BISHIPHOME_${brnch}_${biplat}.rdd/$one/$verf"
		ls $srczipf/*.zip > /dev/null 2>&1
		if [ $? -ne 0 ]; then
			echo "${me##*/}:$one:There is no zip file under the $srczipf. Skip $one"
		else
			mkddir.sh "$trgzipf"
			if [ ! -d "$trgzipf" ]; then
				echo "${me##*/}:$one:Failed to create $trgzipf folder. Skip $one"
			else
				echo "${me##*/}:$one:Copy zip files from $srczipf."
				ls $srczipf/*.zip 2> /dev/null | while read zip; do
					zip=${zip##*/}
					echo "  Copy $zip file."
					cp -p $srczipf/$zip $trgzipf
				done
				if [ -d "$srcverf" ]; then
					echo "${me##*/}:$one:Found $srcverf folder."
					mkddir.sh ${trgverf}
					if [ -d "${trgverf}" ]; then
						ls ${srcverf} 2> /dev/null | \
						while read xml; do
							xml=${xml##*/}
							echo "  Copy $xml file."
							cp -p $srcverf/$xml $trgverf
						done
					fi
				fi
				if [ "$rcu" = "true" ]; then
					fn=`ls $srcloc/$one/bishiphome/RCUINTEGRATION* 2> /dev/null | head -1`
					if [ -z "$fn" ]; then
						echo "${me##*/}:$one:Couldn't find RCU pointer file."
					else
						fn=${fn##*/}
						echo "${me##*/}:$one:Found RCU pointer file($fn)."
						cp $srcloc/$one/bishiphome/$fn \
							$trg/BISHIPHOME_${brnch}_${biplat}.rdd/$one/bishiphome
						rcuptr=`cat $srcloc/$one/bishiphome/$fn | head -1`
						echo "  $rcuptr."
						rcufld=${rcuptr#/*/*/}
						rcufld=${rcufld%/*}
						mkddir.sh $trg/$rcufld
						if [ ! -d "$trg/$rcufld" ]; then
							echo "${me##*/}:$one:Failed to create $trg/$rcufld folder."
						else
							echo "  Copy ${rcuptr##*/} file."
							cp -p `biloc.sh $rcuptr` $trg/$rcufld
						fi
					fi
				fi
			fi
		fi
	fi
}

if [ -n "$lbl" ]; then
	for one in $lbl; do
		cp_one $one
	done
else
	while read one; do
		case $one in
			exit|quit|q)
				break;;
			*)
				cp_one $one;;
		esac
	done
fi

exit 0
