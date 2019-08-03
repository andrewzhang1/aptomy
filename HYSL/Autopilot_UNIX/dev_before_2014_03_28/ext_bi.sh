#!/usr/bin/ksh
###########################################################
# ext_bi.sh : Extract BISHIPHOME images
# Description:
#   This script extract the specific BISHIPHOME image
#   to specific folder.
# Syntax: ext_bi.sh [-h|-p <plat>|-o <opt>] <label>/<branch> <tar>
# Parameters:
#   <label>  : BI Label name.
#   <branch> : BI branch(build) name
#   <tar>    : Extract target folder name.
# Option:
#   -h        : Display help
#   -hs       : Display help with sample.
#   -p <plat> : Platform
#   -rcu      : Extract RCU also (default)
#   -norcu    : Not extract RCU
#   -dbg      : Debug print ON
#   -nodbg    : Debug print OFF (default)
#   -local    : Copy zip files to local($HOME/.${LOGNAME}.`hostname`.ext_bi.tmp)
#   -nolocal  : Don't copy zip files to local
#   -o <opt>  : Task option
# Exit code:
#   $? = 0 : Succeeded.
#        1 : Too many parameter
#        2 : Few parameter
#        3 : Need second parameter for -p
#        4 : Platform is not supported by BISHIPHOME
#        5 : Target BISHIPHOME folder not found
#        6 : Unzip command not found.
# Reference:
#   AP_BICACHE : Cache location for BISHIPHOME_XXXX.XXX.rdd.
#     When you define this variable and it contains target 
#     BISHIPHOME image, this program uses that zip files.
#   apinc.sh, biplat.sh, biloc.sh
# Sample:
#     i.e) If your platform is Win32 and want to extract
#          MAIN:111129.0900 brach. And you have cache image
#          under C:/bicache folder. You can define this var
#          to C:/bicache.
#            $ export AP_BICACHE=C:/bicache
#          Then run this program. This program uses zip files
#          under C:/bicache folder if target zip is saved 
#          there. Otherwise, this program get zip file from
#          ADE location.
#          The folder hirarchy is exact same as original
#          folder structure like below. (zip file only)
#     C:/bicache
#        +- BISHIPHOME_MAIN_NT.rdd
#           +- 111129.0900
#              +- bishiphome
#                 +- shiphome
#                    +-obi_installer_BISHIPHOMEMAINNT1111290900-Release1.zip
#                    +-obi_installer_BISHIPHOMEMAINNT1111290900-Release2.zip
#                    +-obi_installer_BISHIPHOMEMAINNT1111290900-Release3.zip
#                    +-obi_installer_BISHIPHOMEMAINNT1111290900-Release4.zip
#                    +-obi_installer_BISHIPHOMEMAINNT1111290900-Release5.zip
#
###########################################################
# History:
###########################################################
# 08/15/2011 YK First edition
# 10/06/2011 YK Add date/time information.
# 11/30/2011 YK Add -rcu support
# 12/01/2011 YK Support AP_BICACHE
# 05/09/2012 YK Support RCUzip() and BIZip() task option.
#               to zip file folder.
# 06/06/2012 YK Fix RCUZip(() option fail to unzip from wrong place.
# 05/20/2013 YK Support BIPATCHZIP for 
#                       BUG 16788577 - OPTION TO SPECIFY THE LOCATION OF BIFNDNEPM PATCH FILES

. apinc.sh

umask 000
me=$0
orgpar=$@
unset brnch plat tar opt bizip rcuzip
rcu=true
dbg=false
cplocal=false	# copy zip file before extract to $HOME/.${LOGNAME}@$(hostname).ext_bi.tmp folder
localfolder="$HOME/.${thisnode}.ext_bi.tmp"
# Read parameter.
while [ $# -ne 0 ]; do
	case $1 in
		`isplat $1`)
			plat=$1
			;;
		-hs)	display_help.sh -s $me
			exit 0
			;;
		-h)	display_help.sh $me
			exit 0
			;;
		-local)		cplocal=true ;;
		-nolocal)	cplocal=false ;;
		-norcu)	rcu=false ;;
		-rcu)	rcu=true ;;
		-o)
			if [ $# -lt 2 ]; then
				echo "${me##*/}:$1 need second parameter as a task option."
				exit 1
			fi
			shift
			[ -z "$_OPTION" ] && export _OPTION="$1" || export _OPTION="$_OPTION $1"
			;;
		-p)
			if [ $# -lt 2 ]; then
				echo "`basename $me`:$1 need second parameter as the platform."
				echo "  orgPar: $orgpar"
				exit 3
			fi
			shift
			plat=$1
			;;
		-nodbg)	dbg=false ;;
		-dbg) 	dbg=true ;;
		rcu:*|rcu=*)
			rcuzip=${1#rcu?}
			rcu=true
			;;
		bi:*|bi=*)
			bizip=${1#bi?}
			;;
		t=*|t:*)
			tar=${1#t?}
			;;
		-t|-d)
			if [ $# -lt 2 ]; then
				echo "${me##*/}:$1 need second parameter as the destination folder."
				exit 1
			fi
			shift
			tar=$1
			;;
		*)
			if [ -z "$brnch" ]; then
				brnch=$1
			elif [ -z "$tar" ]; then
				tar=$1
			else
				echo "${me##*/}:Too many parameter($1)"
				echo "  orgPar: $orgpar"
				exit 1
			fi
			;;
	esac
	shift
done

if [ -z "$tar" ]; then
	tar=`pwd`
else
	if [ ! -d "$tar" ]; then
		mkddir.sh $tar
		if [ $? -ne 0 ]; then
			echo "{$me##*/}:Failed to create target folder($tar)."
			exit 1
		fi
	fi
fi
str=`chk_para.sh RCUZip "$_OPTION"`
str=${str##* }
if [ -n "$str" ]; then
	ev=`echo $str | grep "\$"`
	[ -n "$ev" ] && str=`eval echo $str`
	rcuzip=$str
	rcu="true"
fi
str=`chk_para.sh BIZip "$_OPTION"`
str=${str##* }
if [ -n "$str" ]; then
	ev=`echo $str | grep "\$"`
	[ -n "$ev" ] && str=`eval echo $str`
	bizip=$str
	[ -z "$rcuzip" -a -f "$bizip/rcuHome.zip" ] && rcuzip="$bizip"
	[ -z "$rcuzip" ] && unset rcu
else
	if [ -z "$bizip" -a -z "$brnch" ]; then
		echo "`basename $me`:Not enough parameter."
		echo "OrgPar: $orgpar"
		exit 2
	fi
fi
[ -z "$plat" ] && plat=${thisplat}
biplat=`biplat.sh $plat 2> /dev/null`
if [ $? -ne 0 ]; then
	echo "`basename $me`:$plat is not supported by BISHIPHOME."
	exit 4
fi
biloc=`biloc.sh -p $plat 2> /dev/null`
if [ -z "$bizip" ]; then
	srch_bi.sh -w -bi $brnch > /dev/null 2>&1
	if [ $? -ne 0 ]; then
		echo "`basename $me`:$brnch not found."
		exit 5
	fi
	bifld=`srch_bi.sh -w -bi $brnch | tail -1`
	_bi=`echo ${bifld%%_*} | tr ABCDEFGHIJKLMNOPQRSTU abcdefghijklmnopqrstuvwxyz`
	bifld="${biloc}/${bifld%% *}"
	fld="${bifld}/${_bi}/shiphome"
	if [ "$dbg" = "true" ]; then
		echo "### `date +%D_%T` decide BI related variables ###"
		echo "# biplat=$biplat"
		echo "# biloc=$biloc"
		echo "# bifld=$bifld"
		echo "# fld=$fld"
	fi
else
	fld=$bizip
fi
if [ ! -d "$fld" ]; then
	echo "`basename $me`:$fld not found."
	exit 5
fi

if [ "$dbg" = "true" ]; then
	echo "### `date +%D_%T` Start ###"
	echo "# plat=$plat"
	echo "# brnch=$brnch"
	echo "# tar=$tar"
	echo "# rcu=$rcu"
	echo "# biloc=$biloc"
	echo "# bizip=$bizip"
	echo "# rcuzip=$rcuzip"
	echo "# cplocal=$cploacl"
	echo "# localfolder=$localfolder"
fi

if [ "$rcu" = "true" ]; then
	if [ -n "$rcuzip" ]; then
		if [ ! -f "$rcuzip/rcuHome.zip" ]; then
			echo "${me##*/}:rcuHome.zip not found under $rcuzip folder."
			echo "Skip unzip RCU."
			unset rcu
		else
			rcu="$rcuzip/rcuHome.zip"
		fi
	else
		rcu=
		if [ -n "$bizip" ]; then
			if [ -z "$brnch" ]; then
				if [ -f "$bizip/rcuHome.zip" ]; then
					echo "### - No branch/label for extRCU. But found $bizip/rcuHome.zip. Use it for RCU."
					rcu="$bizip/rcuHome.zip"
				else
					echo "${me##*/}:You define BiZip($bizip) option without RCUZip() and branch/label."
					echo "This process need to expand RCU zip file. But you do not define both RCUZip() and branch/label."
					echo "Without RCUZip() option, this program need to calculate requited RCU zip file from ADE."
					echo "But you didn't provide branch/label parameter and Couldn't calculate RCU without those."
					unset rcu
				fi
			fi
		fi
		if [ -z "$rcu" -a -n "$brnch" ]; then
			srch_bi.sh -w -bi $brnch > /dev/null 2>&1
			if [ $? -ne 0 ]; then
				echo "`basename $me`:$brnch not found."
				exit 5
			fi
			bifld=`srch_bi.sh -w -bi $brnch | tail -1`
			_bi=`echo ${bifld%%_*} | tr ABCDEFGHIJKLMNOPQRSTU abcdefghijklmnopqrstuvwxyz`
			bifld="${biloc}/${bifld%% *}"
			rcu=`ls ${bifld}/${_bi}/RCU* 2> /dev/null | head -1`
			echo "# RCU ptr=$rcu"
			if [ -n "$rcu" -a -f "$rcu" ]; then
				rcu=`cat $rcu | head -1`
				rcuorg=$rcu
				if [ ! -f "$rcu" ]; then
					rcu=`biloc.sh -p $plat $rcu`
					# rcu=${rcu#*RCUINTEGRATION_}
					# rcu="${biloc}/RCUINTEGRATION_${rcu}"
				fi
				if [ ! -f "$rcu" ]; then
					echo "`basename $me`:RCU pointer file found. But not found target zip."
					echo "  original=$rcuorg"
					echo "  target=$rcu"
					rcufld=${rcu%/*/rcuintegration/*}
					rcufile="rcuintegration${rcu##*/rcuintegration}"
					rcu=
					if [ -d "${rcufld}/LATEST" -a -f "${rcufld}/LATEST/$rcufile" ]; then
						rcu="$rcufld/LATEST/$rcufile"
					else
						ls ${rcufld} | grep -v LATEST | sort -r | while read one; do
							if [ -f "$rcufld/$one/$rcufilie" ]; then
								rcu="$rcufld/$one/$rcufile"
								break
							fi
						done
					fi
					if [ -z "$rcu" ]; then
						echo "Skip RCU extraction."
						unset rcu
					else
						echo "  Found alternate version of RCU."
						echo "  alt RCU=$rcu"
					fi
				else
					[ "$dbg" = "true" ] && echo "# rcu=$rcu"
				fi
			else
				echo "`basename $me`:RCU pointer file not found."
				unset rcu
			fi
		fi
	fi
else
	unset rcu
fi

unzipcmd=`which unzip`
if [ $? -ne 0 -o "x${unzipcmd#no}" != "x${unzipcmd}" ]; then
        case `uname` in
                HP-UX)  unzipcmd=`which unzip_hpx32`;;
                Linux)  unzipcmd=`which unzip_lnx`;;
                SunOS)  unzipcmd=`which unzip_sparc`;;
                AIX)    unzipcmd=`which unzip_aix`;;
        esac
fi
if [ $? -ne 0 -o -z "${unzipcmd}" ]; then
        echo "Couldn't find the unzip command."
        exit 6
fi

zips=`ls $fld/*.zip | grep -v rcuHome.zip 2> /dev/null`
[ -n "$rcu" ] && zips="$zips $rcu"

# BUG 16788577 - OPTION TO SPECIFY THE LOCATION OF BIFNDNEPM PATCH FILES
# Add patch zip files.
bipatches=`chk_para.sh bipatchzip "$_OPTION"`
[ -z "$bipatches" ] && bipatches=`chk_para.sh bipzip "$_OPTION"`
if [ -n "$bipatches" ]; then
	for one in $bipatches; do
		ls $one/*.zip 2> /dev/null | while read zipf; do
			fnm=${zipf##*/}
			n=`echo "$zips" | grep $fnm"`
			if [ -z "$n" ]; then
				[ -z "$zips" ] && zips=$zipf || zips="$zips $zipf"
			fi
		done
	done
fi
unset bipatches zipf one fnm

rmdir -rf $tar 2> /dev/null
mkddir.sh $tar

if [ -n "$AP_BICACHE" -a -d "$AP_BICACHE" ]; then
	echo "### Found \$AP_BICACHE definition."
	echo "### \$AP_BICACHE=$AP_BICACHE"
fi

if [ "$cplocal" = "true" ]; then
	newzips=
	rm -rf $localfolder > /dev/null 2>&1
	mkdir $localfolder 2> /dev/null
	for one in $zips; do
		[ "$dbg" = "true" ] && echo "### cp $one to $localfolder."
		cp $one $localfolder 2> /dev/null
		[ -z "$newzips" ] && newzips="$localfolder/${one##*/}" || newzips="$newzips ${localfolder}/${one##*/}"
	done
	zips=$newzips
fi

echo "### `date +%D_%T` Start extracting ###"

for one in $zips; do
	echo "### `date +%D_%T` ${one##*/} ###"
	echo "###   from $one"
	isrcu=`echo ${one##*/} | grep rcu 2> /dev/null`
	# if [ "${thisplat#win}" = "$thisplat" -a -n "$isrcu" ]; then
	if [ -n "$isrcu" ]; then
		echo "### RCU: Create $tar/rcuHome folder and use it for extract target."
		mkddir.sh $tar/rcuHome 2> /dev/null
		tartmp=$tar/rcuHome
	else
		tartmp=$tar
	fi
	echo "### TARTMP:$tartmp"
	if [ -n "$AP_BICACHE" -a -d "$AP_BICACHE" ]; then
		fnm=${one#${biloc}}
		if [ -f "${AP_BICACHE}${fnm}" ]; then
			one=${AP_BICACHE}${fnm}
		fi
	fi
	if [ "$dbg" = "true" ]; then
		 ${unzipcmd} -o ${one} -d $tartmp
		sts=$?
	else
		${unzipcmd} -o ${one} -d $tartmp > /dev/null 2>&1
		sts=$?
	fi
	if [ $sts -ne 0 ]; then
		echo "--> $one caused none zero status($sts)."
	fi
	if [ "${tartmp%/rcuHome}" != "$tartmp" ]; then	# RCU
		echo "### RCU: Check nested rcuHome folder."
		if [ -d "$tartmp/rcuHome" ]; then
			echo "### RCU: Found nested rcuHome folder."
			echo "### RCU: $tartmp/rcuHome"
			echo "### RCU: Move all contents under $tartmp/rcuHome to $tartmp."
			mv $tartmp/rcuHome/* $tartmp
		fi
	fi
done
[ "$cplocal" = "true" ] && rm -rf $localfolder 2> /dev/null
echo "### `date +%D_%T` Done ###"
exit 0
