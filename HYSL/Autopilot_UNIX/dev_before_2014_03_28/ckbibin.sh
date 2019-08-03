#!/usr/bin/ksh
# ckbibin.sh : Check BI Essbase binaries between refresh bin.
# Description:
#   This script do following:
#   1) Install BISHIPHOME
#   2) Install refresh binaies
#   4) Make file size list from BI installation
#   5) Make file size list from refresh binaries
#   Current version target following contents:
#   BISHIPHOME)
#     <MiddlewareHome>/products/Essbase/EssbaseServer as ARBORPATH
#   Refresh)
#     <refreshHome>/ARBORPATH as ARBORPATH
# Syntax:
#   ckbibin.sh [<options>] [<bi-label> [<bi-branch>]]
#   <bi-label>  : BI label
#   <bi-branch> : BISHIPHOME branch
# Options:=[-h|+dbg|<constr1>|<constr2>]
#  <constr1>: Database connection string to create repository.
#             <dbind>:<host>:<port>:<sid>:<usr>:<pwd>:<roll>
#               <dbtyp>: RDBMS type. (ora/mssql/db2)
#               <host> : hostname for the RDBMS
#               <port> : Port number for the RDBMS
#               <sid>  : SID in oracle, DB name on SQL server and DB2.
#               <usr>  : User name who has SYSDBA roll.
#               <pwd>  : Password for <usr>
#               <roll> : Roll name. SYSDBA for oracle.
#  <constr2>: Database connection string which already has a repository.
#             <dbind>:<host>:<port>:<sid>:<admusr>/<admpwd>:<biusr>/<bipwd>:<mdsusr>:<mdspwd>
#               <dbtyp> : RDBMS type.
#               <host>  : hostname for the RDBMS
#               <port>  : Port number for the RDBMS
#               <sid>   : SID in oracle, DB name on SQL server and DB2.
#               <admusr>: User name for Weblogic administrator,
#               <admpwd>: Password for Weblogic administrator,
#               <biusr> : User name for BIPLATFORM user,
#               <bipwd> : Password for BIPLATFORM user,
#               <mdsusr>: User name for MDS user,
#               <mdspwd>: Password for MDS user,
#   -h      : Display help.
#   -hs     : Display help with samples.
#   +dbg    : Display debug information.
# Sample:
#   1) ckbibin.sh
#      # This sampe check the MAIN LATEST BISHIPHOME installer.
#   2) ckbibin.sh 11.1.1.6 LATEST
#   3) ckbibin.sh MAIN 111129.0900
#   4) ckbibin.sh MAIN:LATEST ora:scl14152:1521:bi:SYS:password:SYSDBA
#      # This smample connect to scl14152:1521:bi oracle when create 
#      # a repository during installation.
#   5) ckbibin.sh MAIN:LATEST \\
#        ora:scl14152:1521:bitest:weblogic/password:DEV_BIPLATFORM/password:DEV_MDS/password
#      # This sample connect to the predefined repository on
#      # scl14152:1521:bitest with weblogic/password for the administrator,
#      # DEV_BIPLATFORM/password for the BI repository and DEV_MDS/password for
#      # the Metadata repository.
# History:
# 2011/12/07 YKono	First edition.

. apinc.sh

# Functions --------------------------
msg()
{
	if [ $# -ne 0 ]; then
		echo "# `date +%D_%T`:$@"
	else
		while read _data_; do
			echo "# `date +%D_%T`:$_data_"
		done
	fi
}

dbg()
{
	if [ $# -ne 0 ]; then
		[ "$dbg" = "+dbg" ] && echo "# $@"
	else
		while read _data_; do
			[ "$dbg" = "+dbg" ] && echo "# $_data_"
		done
	fi
}

# Initialize each variables

me=$0
orgpar=$@
biL=
biB=
dbg="-dbg"
rcu=create		# RCU mode (predefined)
constr=			# Conenction string to the repository RDBMS
[ -n "$VIEW_PATH" ] && tmploc=$VIEW_PATH/ckbi || tmploc=`pwd`
src=			# Pre expanded BISHIPHOME installer location
stopps="+stop"

while [ $# -ne 0 ]; do
	case $1 in
		-h)	display_help.sh $me
			exit 0
			;;
		-hs)	display_help.sh -s $me
			exit 0
			;;
		-t|-tmp|-tar|-target|-loc)
			tmploc=$1
			;;
		-s|-src)	
			if [ $# -eq 1 ]; then
				echo "-s option 2nd parameter as a pre-extracted BISHIPHOME location."
				exit 1
			fi
			shift
			src="src=$1"
			;;
		-l)	
			shift
			srch_bi.sh -bi $@
			exit 0
			;;
		+stop|-stop)	stopps=$1;;
		+dbg|-dbg)	dbg=$1;;
		*:*:*:*:*/*:*/*)
			rcu=predefined
			constr=$1
			;;
		*:*:*:*:*:*:*|*:*:*:*:*:*:*:*)
			rcu=create
			constr=$1
			;;
		*:*)
			biL=${1%:*}
			biB=${1#*:}
			;;
		*)
			if [ -z "$biL" ]; then
				biL=$1
			elif [ -z "$biB" ]; then
				biB=$1
			else
				echo "${me##*/}:Too many parameter($@)."
				echo "  orgpar:<$orgpar>"
				exit 1
			fi
			;;
	esac
	shift
done

[ -z "$biL" ] && biL=MAIN
[ -z "$biB" ] && biB=LATEST

msg "Start ${me##*/}."
dbg "bi-label =$biL"
dbg "bi-branch=$biB"
dbg "tmploc   =$tmploc"
dbg "src      =$src"
dbg "dbg      =$dbg"
dbg "rcu      =$rcu"
dbg "constr   =$constr"
dbg "BICONSTR =$AP_BICONSTR"
dbg "BIREPLIST=$AP_BIREPLIST"

dbg "- Check tmploc($tmploc)"
mkddir.sh $tmploc 2> /dev/null
if [ ! -d "$tmploc" ]; then
	echo "${me##*/}:No tmploc($tmploc) found."
	exit 1
fi

cd $tmploc
if [ $? -ne 0 ]; then
	echo "${me##*/}:Failed to access tmploc($tmploc)."
	exit 1
fi

dbg "- Create BI middleware home($tmploc/bimwh)."
rm -rf bimwh 2> /dev/null
mkdir bimwh
if [ $? -ne 0 ]; then
	echo "${me##*/}:Failed to create BI install folder."
	echo "  Please make sure that tmploc($tmploc) has a write permission."
	exit 1
fi

biloc=$tmploc/bimwh

dbg "- Create refresh extract fodler($tmploc/refresh)."
rm -rf refresh 2> /dev/null
mkdir refresh
if [ $? -ne 0 ]; then
	echo "${me##*/}:Failed to create refresh temporary folder."
	echo "  Please make sure that tmploc($tmploc) has a write permission."
	exit 1
fi

refloc=$tmploc/refresh

dbg "- Get Essbase ver/bld number for $biL:$biB."
ret=`srch_bi.sh -bi $biL/$biB`
sts=$?
if [ $sts -ne 0 ]; then
	echo "${me##*/}:srch_bi.sh returned error($sts)"
	echo $ret
	exit 1
fi

dbg "ret=$ret"
ev=`echo $ret | awk '{print $3}'`
essver=${ev%:*}
essbld=${ev#*:}

dbg "  essver=$essver"
dbg "  essbld=$essbld"

msg "Start BISHIPHOME($biL/$biB) installation."
dbg "biinst.sh $src $biL/$biB $constr $biloc $stopps"
biinst.sh $src $biL/$biB $constr $biloc $stopps
sts=$?

if [ $sts -ne 0 ]; then
	echo "${me##*/}:biinst.sh retuned $sts."
	exit 1
fi

msg "Extract refresh tar file of $essver:$essbld to $refloc."
dbg "ext_reftar.sh -server $essver $essbld $refloc"
ext_reftar.sh -server $essver $essbld $refloc
sts=$?
if [ $sts -ne 0 ]; then
	echo "${me##*/}:ext_reftar.sh retned $sts."
	exit 1
fi

msg "Making size file for <MH>/Oracle_BI1/products/Essbase/EssbaseServer."
export ARBORPATH=$biloc/Oracle_BI1/products/Essbase/EssbaseServer
export HYPERION_HOME=$biloc/Oracle_BI1
filesize.pl -igndir -attr -cksum -ign "ESSCMDQ|ESSCMDG" \$ARBORPATH > $tmploc/bi.siz 2>&1
filesize.pl -igndir -attr -cksum -ign "Merant/5.2|Merant/6.0SP1" \$HYPERION_HOME/common/ODBC \
	>> $tmploc/bi.siz 2>&1
filesize.pl -igndir -attr -cksum \$HYPERION_HOME/common/config >> $tmploc/bi.siz 2>&1


msg "Making size file for <refresh>/ARBORPATH."
export ARBORPATH=$refloc/ARBORPATH
export HYPERION_HOME=$refloc/HYPERION_HOME
filesize.pl -igndir -attr -cksum \$ARBORPATH > $tmploc/refresh.siz 2>&1
filesize.pl -igndir -attr -cksum \$HYPERION_HOME/common/ODBC >> $tmploc/refresh.siz 2>&1
filesize.pl -igndir -attr -cksum \$HYPERION_HOME/common/config >> $tmploc/refresh.siz 2>&1

msg "Comparing BI and refresh size file."
sizediff.pl $tmploc/bi.siz $tmploc/refresh.siz 2>&1 | tee $tmploc/bi_refresh.dif

exit 0

