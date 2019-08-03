#!/usr/bin/ksh
# biinst.sh : Install product using BISHIPHOME
#
# Description:
#   Install Essbase product using BISHIPHOME installer.
#
# Syntax:
# 1) biinst.sh [<Options>] <label> <branch> <constr> [<constr>] [<mwloc>]
# 2) biinst.sh [<Options>] -s <src> <constr> [<constr>] [<mwloc>]
# Parameter:
#   <label>:  BISHIPHOME label
#   <branch>: BIHIPHOME branch
#   -s <src>: Use <src> contents as the installer which is already extracted.
#   <constr>: DB Connection string for BIPLATFORM
#             If you only define one <constr> parameter, biinst.sh uses
#             that definition for both BIPLATFORM and MDS.
#             When you define <constr> twice, biinst.sh uses first one
#             for BIPLATFORM and second one for MDS.
#             The format of <constr> is below:
#             <dbtype>:<host>:<port>:<sid>
#                <dbtype>: Database type
#                          ora: Oralce Databse
#                          sql: MS SQL Server
#                          db2: IBM DB2
#                <host>:   Database hostname
#                <posrt>:  Database port number
#                <sid>:    Service name
#   <mwhome>: Define Middleware home locaiton.
#             biinst.sh install product into <mwhome> location.
# Options: [-h|-l <mwhome>|-s <instf>|-dbg|<var>=<val>]
#   -h:          Display help
#   -l <mwhome>: Define MIDDLEWARE_HOME (install target location)
#   -s <instf>:  Define installer source.
#   -dbg:        Display debug informations.
#   <var>=<val>: Define <var> variable using <val> value.
#                You can define following variables:
#                  mw_home=%MW_HOME%   # Middleware home(same as -l <mwloc>)
#                  adm=%ADMIN_USR%     # default=weblogic
#                  adm_pwd=%ADMIN_PWD% # default=Oracle123
#                  bi=%BI_USR%	       # default=DEV_BIPLATFORM
#                  bi_pwd=%BI_PWD%     # default=password
#                  mds=%MDS_USR%       # default=DEV_MDS
#                  mds_pwd=%MDS_PWD%   # default=password
#                  bi_db=<constr>      # Must defined
#                  mds_db=<constr>     # when skip this, use bi_db.
#                  src=<instf>         # Installer location(same as -s <src>)
# Sample:
#    $ biinst.sh MAIN LATEST C:/Oracle/Middleware ora:scl14152:1521:bi
#    $ biinst.sh -s ./bi /home/regrrk1/hyperion/11.1.2.2.000_bi ora:scl14152:1421:bitest
#    $ biinst.sh MAIN:110926.1000 ora:scl14152:1521:bitest
# 
# HISTORY: ########################################################
# 10/06/2011	YKono	First edition

me=$0
orgpar=$@
dbg=true

# default values
mw_home=`pwd`
adm="weblogic"
adm_pwd="Oracle123"
bi="DEV_BIPLATFORM"
bi_pwd="password"
mds="DEV_MDS"
mds_pwd="password"
bi_db=
mds_db=
src=
lbl=
brnch=

while [ $# -ne 0 ]; do
	case $1 in
		-h)
			display_help.sh $me
			exit 0
			;;
		-dbg)
			dbg=true
			;;
		src=*|adm=*|adm_pwd=*|mw_home=*|bi=*|bi_pwd=*|mds=*|mds_pwd=*|bi_db=*|mds_db=*)
			var=${1%%=*}
			val=${1#*=}
			eval $var=$val
			;;
		*:*:*:*)
			if [ -z "$bi_db" ]; then
				bi_db=$1
			else
				mds_db=$1
			fi
			;;
		*:*)
			lbl=${1%%:*}
			brnch=${1#*:}
			;;
		-l|-loc|-mw|-mwh|-dst|-tarloc)
			if [ $# -lt 2 ]; then
				echo "biinst.sh:\"-l\" option need 2nd parameter as the install destination."
				display_help.sh $me
				exit 1
			fi
			shift
			mw_home=$1
			;;
		-s|-src)
			if [ $# -lt 2 ]; then
				echo "biinst.sh:\"-s\" option need 2nd parameter as the source location of the extracted folder."
				display_help.sh $me
				exit 1
			fi
			shift
			src=$1
			;;
		*)
			if [ -n "$src" ]; then
				mw_home=$1
			else
				if [ -z "$lbl" ]; then
					lbl=$1
				elif [ -z "brnch" ]; then
					brnch=$1
				else
					mw_home=$1
				fi
			fi
			;;
	esac
	shift
done

# Make $mw_home to absolute path
[ ! -d "$mw_home" ] && mkddir.sh $mw_home
crrdir=`pwd`
cd $mw_home
mw_home=`pwd`
cd "$crrdir"

# If no $mds_db, set same value as $bi_db
[ -z "$mds_db" ] && mds_db=$bi_db

# Check $bi_db empty
if [ -z "$bi_db" ]; then
	echo "biinst.sh: Need to define <constr>."
	echo "  bi_constr:<$bi_db>"
	echo " mds_constr:<$mds_db>"
	echo "     OrgPar:<$orgpar>"
	exit 1
fi

# Make Database type and connection string
bi_dbtyp=${bi_db%%:*}
mds_dbtyp=${mds_db%%:*}
bi_db=${bi_db#*:}
mds_db=${mds_db#*:}
for one in bi_dbtyp mds_dbtyp; do
	val=`eval echo \\$$one`
	val=`echo $val | tr [A-Z] [a-z]`
	case $val in
		ora|oracle)
			nval="Oracle Database";;
		mssql|sql)
			nval="Microsoft SQL Server";;
		ibm|db2)
			nval="IBM DB2";;
		*)	
			nval="error";;
	esac
	if [ "$nval" = "error" ]; then
		echo "biinst.sh:`date +%D_%T` The database value($val) for $one is invalid."
		echo "  This should be one of 'ora', 'oracle', 'mssql', 'sql', 'ibm'  or 'db2'."
		exit 2
	fi
	eval "$one=\"$nval\""
done

# Check source or label:branch definition
if [ -z "$src" ]; then
	if [ -z "$lbl" -o -z "brnch" ]; then
		echo "biinst.sh: Need define <label> and <branch> or <src>."
		echo "  lebel:<$lbl>"
		echo " branch:<$brnch>"
		echo "    src:<$src>"
		echo " OrgPar:<$orgpar>"
		exit 3
	fi
fi

# If the source is BISHIPHOME, extract zip files
if [ -z "$src" ]; then
	mkddir.sh $VIEW_PATH/bitmp 2>&1
	ext_bi.sh "$lbl:$brnch" $VIEW_PATH/bitmp
	sts=$?
	if [ $sts -ne 0 ]; then
		echo "biinst.sh:`date +%D_%T` Failed to extract $lbl:$brnch to the \$VIEW_PATH/bitmp."
		echo "  ext_bi.sh returned $sts."
		exit 4
	fi
	src=$VIEW_PATH/bitmp
fi

# Check the installer program exist
if [ "`uname`" = "Windows_NT" ]; then
	prg=setup.exe
else
	prg=runInstaller
fi
if [ ! -f "$src/bishiphome/Disk1/$prg" ]; then
	echo "biinst.sh:`date +%D_%T` $src/bishiphome/Disk1/$prg not found."
	exit 5
fi

# Debug print
if [ "$dbg" = "true" ]; then
	echo "biinst.sh:`date +%D_%T` Variabls list:"
	echo "# me=$me"
	echo "# orgpar=$orgpar"
	echo "# dbg=$dbg"
	echo "# lbl=$lbl"
	echo "# brnch=$brnch"
	echo "# src=$src"
	echo "# mw_home=$mw_home"
	echo "# adm=$adm"
	echo "# adm_pwd=$adm_pwd"
	echo "# bi=$bi"
	echo "# bi_pwd=$bi_pwd"
	echo "# mds=$mds"
	echo "# mds_pwd=$mds_pwd"
	echo "# bi_dbtyp=$bi_dbtyp"
	echo "# bi_db=$bi_db"
	echo "# mds_dbtyp=$mds_dbtyp"
	echo "# mds_db=$mds_db"
fi

# Make silent response file
rsp=$HOME/bi.rsp
[ -f "$rsp" ] && rm -rf $rsp 2>&1 > /dev/null
cat $AUTOPILOT/rsp/bi.rsp | sed \
	-e "s!%MW_HOME%!$mw_home!g" \
	-e "s!%ADMIN_USR%!$adm!g" \
	-e "s!%ADMIN_PWD%!$adm_pwd!g" \
	-e "s!%BI_CONSTR%!$bi_db!g" \
	-e "s!%BI_DBTYP%!$bi_dbtyp!g" \
	-e "s!%BI_USR%!$bi!g" \
	-e "s!%BI_PWD%!$bi_pwd!g" \
	-e "s!%MDS_CONSTR%!$mds_db!g" \
	-e "s!%MDS_DBTYP%!$mds_dbtyp!g" \
	-e "s!%MDS_USR%!$mds!g" \
	-e "s!%MDS_PWD%!$mds_pwd!g" > $rsp

ret=0
rm -rf $HOME/Inventory
rm -rf $HOME/oraInst.loc
echo "inventory_loc=$HOME/Inventory" > $HOME/oraInst.loc
echo "inst_group=`id -g -n`" >> $HOME/oraInst.loc
$src/bishiphome/Disk1/$prg -silent -response $rsp -waitforcompletion -invPtrLoc $HOME/oraInst.loc
sts=$?
if [ $sts -ne 0 ]; then
	echo "biinst.sh:`date +%D_%T` Installer retuned $sts."
	ret=10
fi
exit $ret

