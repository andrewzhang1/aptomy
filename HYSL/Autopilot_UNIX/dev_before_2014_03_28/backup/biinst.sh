#!/usr/bin/ksh
# biinst.sh : Install product using BISHIPHOME
#
# Description:
#   Install Essbase product using BISHIPHOME installer.
#
# Syntax:
#    biinst.sh [<Options>] [<SRCDef>] [<DBconStr>...] [<MWHome>]
# Parameter:
#   <MWHome>: Middleware location.(Install destination)
#             biinst.sh install product into <mwhome> location.
#   <SRCDef>:=[-s <src>|<label>/<branch>]
#     <label>:  BISHIPHOME label
#     <branch>: BIHIPHOME branch
#               You can define label and bransh with "/" like MAIN/111129.0900.
#     -s <src>: Use <src> contents as the installer which is already extracted.
#               Note: If you skip <SRCDef> section, MAIN:LATEST will be used.
#   <DBconStr>:=[<conStr>[ <conStr>]|<RCUCstr>]
#     <conStr>: DB Connection string for the pre-defined repository (by RCU).
#               If you only define one <constr> parameter, biinst.sh uses
#               that definition for both BIPLATFORM and MDS.
#               When you define <constr> twice, biinst.sh uses first one
#               for BIPLATFORM and second one for MDS.
#               The format of <constr> is below:
#               <dbtype>:<host>:<port>:<sid>[:<prefix>]
#                  <dbtype>: Database type
#                            ora: Oralce Databse
#                            sql: MS SQL Server
#                            db2: IBM DB2
#                  <host>:   Database hostname
#                  <port>:   Database port number
#                  <sid>:    Service name
#                  <prefix>: The prefix for BI and MDS users.
#                            When you skip this, DEV will be used.
#                            i.e.) When you define D023 for <prefix>,
#                                  This program use D023_BIPLATFORM and D023_MDS users.
#               Note: When you skip <DBconStr> section, biinst.sh automatically
#                     create BI repository on the pre-defined RDBMS and use it.
#     <RCUCstr>:The conecction string for the repository creation.
#               The format of <RCUCstr> is below:
#               <dbtype>:<host>:<port>:<sid>:<usr>:<pwd>:<roll>
#                  <dbtype>: Database type
#                  <host>:   Database hostname
#                  <port>:   Database port number
#                  <sid>:    Service name
#                  <usr>:    User name who has SYSDBA roll
#                  <pwd>:    Password for <usr>
#                  <roll>:   The roll name for SYSDBA
# Options: [-h|-hs|-stop|+stop|-l <MWHome>|-s <src>|-dbg|<var>=<val>]
#   -h:          Display help
#   -hs:         Display help with samples.
#   -stop:       Stop started modules.(default)
#   -nostop:       Not stop started modules.
#   -dbg:        Display debug informations.
#   -nodbg:      Not display debug informations.
#   <var>=<val>: Define <var> variable using <val> value.
#                You can define following variables:
#                  mw_home=%MW_HOME%   # Middleware home(same as -l <mwloc>)
#                  adm=%ADMIN_USR%     # default=weblogic
#                  adm_pwd=%ADMIN_PWD% # default=welcome1
#                  bi=%BI_USR%	       # default=DEV_BIPLATFORM
#                  bi_pwd=%BI_PWD%     # default=password
#                  mds=%MDS_USR%       # default=DEV_MDS
#                  mds_pwd=%MDS_PWD%   # default=password
#                  bi_db=<constr>      # Must defined
#                  mds_db=<constr>     # when skip this, use bi_db.
#                  src=<instf>         # Installer location(same as -s <src>)
# Sample:
#    1) Install product with new repository creation on default RDBMS.
#       The product will be installed into current directory.
#       $ biinst.sh
#       note: with RCU creation, the prefix of the repository is D###.
#             ### is created from the line number of data/the birep_list.txt.
#    2) Install product into specific destination with pre-defined repository.
#       $ biinst.sh MAIN:LATEST C:/Oracle/Middleware ora:scl14152:1521:bi
#       note: In this case, a repository prefix is a default, DEV.
#    3) Install product using pre-extracted BISHIPHOME images.
#       $ biinst.sh -s ./bi /home/regrrk1/hyperion/11.1.2.2.000_bi ora:scl14152:1421:bitest
#    4) Install product with specific prefix repository.(below, KONO01 is prefix)
#       $ biinst.sh MAIN:111129.0900 ora:scl14152:1521:bitest:KONO01
#    6) Create repository on the specifix RDBMS and install product.
#       $ biinst.sh MAIN:LATEST ora:scl14155:1521:ora:SYS:password:SYSDBA
#       note: with RCU creation, the prefix of the repository is D###.
#             ### is created from the line number of data/the birep_list.txt.
#    7) Manuraly define all parameter and install.
#       $ biinst.sh MAIN:LATEST ora:scl14152:1521:bitest \\
#         adm=weblogic adm_pwd=Oracle123 \\
#         bi=DEV_BIPLATFORM bi_pwd=password123 \\
#         mds=DEV_MDS mds_pwd=password123
# 
# HISTORY: ########################################################
# 10/06/2011	YKono	First edition
# 12/29/2011	YKono	Add -stop|+stop option to control stop
#			pre-lauched processes.
# 05/09/2012	YKono	Add support BIRep() option for pre-defined repository
#                       rcuimg() for expanded RCU installer,
#                       biimg() for expanded BISHIPHOME installer.
#			rcuzip() and bizip() for ext_bi.sh
# 08/17/2012	YKono	Bug 14510052 - CHANGE USER/PASSWORD OF BI INSTALLATION TO DEFAULT ONE

. apinc.sh
umask 000
# AP_BICONSTR
# <DBknd>:<hostname>:<port>:<sid>:><sys-usr>:<pwd>:<role>[:<repf>[:<repmethd>]]
set_vardef AP_BICONSTR
case $AP_BICONSTR in
	*:*:*:*:*:*:*:*:*)
		birepmethod=${AP_BICONSTR##*:}
		AP_BICONSTR=${AP_BICONSTR%:*}
		bireplist=${AP_BICONSTR##*:}
		export AP_BICONSTR=${AP_BICONSTR%:*}
		[ "$birepmethod" != "line" ] && birepmethod=incr
		t=`echo $bireplist | grep "/"`
		[ -z "$t" ] && bireplist=$AUTOPILOT/data/$bireplist
		;;
	*:*:*:*:*:*:*:*)	# Skip <rep file> or <rep method>
		t=${AP_BICONSTR##*:}
		export AP_BICONSTR=${AP_BICONSTR%:*}
		if [ "$t" = "incr" -o "$t" = "line" ]; then
			birepmethod=$t
			bireplist=$AUTOPILOT/data/birep_list.txt
		else	
			t1=`echo $t | grep "/"`
			[ -z "$t1" ] && bireplist=$AUTOPILOT/data/$t \
				|| bireplist=$t
			birepmethod=incr
		fi
		;;
	*:*:*:*:*:*:*)	# Skip <rep file> and <rep method>
		bireplist=$AUTOPILOT/data/birep_list.txt
		birepmethod=incr
		;;
esac

# FUNCTIONS -----
msg()
{
	if [ $# -ne 0 ]; then
		[ "$dbg" = "true" ] && echo "$@"
	else
		while read _data_; do
			[ "$dbg" = "true" ] && echo "$_data_"
		done
	fi
}

me=$0
orgpar=$@
dbg=true
# default values
[ -n "$VIEW_PATH" ] && mywork=$VIEW_PATH || mywork=`pwd`
mw_home=`pwd`
adm="weblogic"
adm_pwd="welcome1"
bi="DEV_BIPLATFORM"
bi_pwd=
mds="DEV_MDS"
mds_pwd=
bi_db=
mds_db=
lbl=
brnch=
rcu=true
prf=
opt=
# Read parameter.
while [ $# -ne 0 ]; do
	case $1 in
		-h)
			display_help.sh $me
			exit 0
			;;
		-dbg)	dbg=true;;
		-nodbg)	dbg=false;;
		lbl=*|brnch=*|src=*|prf=*|adm=*|adm_pwd=*|mw_home=*|bi=*|bi_pwd=*|mds=*|mds_pwd=*|bi_db=*|mds_db=*)
			var=${1%%=*}
			val=${1#*=}
			eval $var=$val
			;;
		*:*:*:*:*/*:*/*)	# Predefined-Repository: Repository constr with usrs
			# <dbtyp>:<host>:<port>:<sid>:<adm>/<pwd>:<bi>/<pwd>:<mds>/<pwd>
			# bi_db=mds_db=<dbtyp>:<host>:<port>:<sid>
			# adm=<adm>, adm_pwd=<pwd>
			# bi=<bi>, bi_pwd=<pwd>
			# mds=<mds>, mds_pwd=<pwd>
			# rcu=<undef>
			bi_db=${1%:*/*:*/*:*/*}
			mds_db=$bi_db
			t=${1#*:*:*:*:}
			bi=${t%%/*}
			t=${t#*/}
			bi_pwd=${t%%:*}
			t=${t#*:}
			mds=${t%%/*}
			t=${t#*/}
			mds_pwd=$t
			rcu=
			;;
		*:*:*:*:*:*:*:*)	# BICONSTR for repository creation with prefix
			# <dbtyp>:<host>:<port>:<sid>:<adm>:<pwd>:<roll>:<prf>
			export AP_BICONSTR=${1%:*}
			prf=${1##*:}
			rcu=true
			;;
		*:*:*:*:*:*:*)	# BICONSTR for repository creation
			# <dbtyp>:<host>:<port>:<sid>:<adm>:<pwd>:<roll>
			export AP_BICONSTR=$1
			rcu=true
			;;
		*:*:*:*:*)	# Predefined-Repository: Repository constr with prefix
			dbcstr=${1%:*}
			pref=${1##*:}
			if [ -z "$bi_db" ]; then
				bi="${pref}_BIPLATFORM"
				mds="${pref}_MDS"
				bi_db=$dbcstr
			else
				mds="${pref}_MDS"
				mds_db=$dbctr
			fi
			rcu=
			;;
		*:*:*:*)	# Predefined-Repository: Repository constr Default prefix
			if [ -z "$bi_db" ]; then
				bi_db=$1
			else
				mds_db=$1
			fi
			rcu=
			;;
		-mw|-mwh)
			if [ $# -lt 2 ]; then
				echo "biinst.sh:\"$1\" option need 2nd parameter as the install destination."
				display_help.sh $me
				exit 1
			fi
			shift
			mw_home=$1
			;;
		-s|-src)
			if [ $# -lt 2 ]; then
				echo "biinst.sh:\"$1\" option need 2nd parameter as the source location of the extracted folder."
				display_help.sh $me
				exit 1
			fi
			shift
			src=$1
			;;
		-o|-opt)
			if [ $# -lt 2 ]; then
				echo "${me##*/}:\"$1\" option need 2nd parameter as a option string."
				exit 1
			fi
			shift
			[ -z "$_OPTION" ] && export _OPTION="$1" || export _OPTION="$_OPTION $1"
			;;
		latest)
			brnch=LATEST
			;;
		*)
			if [ -z "$src" ]; then
				src=$1
			else
				mw_home=$1
			fi
			;;
	esac
	shift
done

str=`chk_para.sh birep "$_OPTION"`
str=${str##* }
if [ -n "$str" ]; then
	# Following are same as parameter parsing phase
	case $str in
		*:*:*:*:*/*:*/*)	# Predefined-Repository: Repository constr with usrs
			# <dbtyp>:<host>:<port>:<sid>:<adm>/<pwd>:<bi>/<pwd>:<mds>/<pwd>
			# bi_db=mds_db=<dbtyp>:<host>:<port>:<sid>
			# adm=<adm>(admin), adm_pwd=<pwd>(Oracle123)
			# bi=<bi>, bi_pwd=<pwd>
			# mds=<mds>, mds_pwd=<pwd>
			# rcu=<undef>
			bi_db=${str%:*/*:*/*:*/*}
			mds_db=$bi_db
			t=${str#*:*:*:*:}
			bi=${t%%/*}
			t=${t#*/}
			bi_pwd=${t%%:*}
			t=${t#*:}
			mds=${t%%/*}
			t=${t#*/}
			mds_pwd=$t
			rcu=
			;;
		*:*:*:*:*:*:*:*)	# BICONSTR for repository creation with prefix
			# <dbtyp>:<host>:<port>:<sid>:<adm>:<pwd>:<roll>:<prf>
			export AP_BICONSTR=${str%:*}
			prf=${str##*:}
			rcu=true
			;;
		*:*:*:*:*:*:*)	# BICONSTR for repository creation
			# <dbtyp>:<host>:<port>:<sid>:<adm>:<pwd>:<roll>
			export AP_BICONSTR=$str
			rcu=true
			;;
		*:*:*:*:*)	# Predefined-Repository: Repository constr with prefix
			dbcstr=${str%:*}
			pref=${str##*:}
			bi="${pref}_BIPLATFORM"
			mds="${pref}_MDS"
			bi_db=$dbcstr
			mds_db=
			rcu=
			;;
		*:*:*:*)	# Predefined-Repository: Repository constr Default prefix
			bi_db=$str
			rcu=
			;;
		*)
			echo "${me##*/}:Invalid BIRep($str) parameter."
			exit 1
			;;
	esac
fi
unset rcuptr biptr
# Check source or label/branch definition
if [ "`uname`" = "Windows_NT" ]; then
	rcuprg="rcuHome/BIN/rcu.bat"
	prg="bishiphome/Disk1/setup.exe"
else
	rcuprg="rcuHome/bin/rcu"
	prg="bishiphome/Disk1/runInstaller"
fi
if [ -n "$src" ]; then
	if [ -f "$src/$prg" ]; then
		biptr=$src
		if [ -n "$rcu" -a -f "$src/$rcuprg" ]; then
			rcuptr=$src
		fi
	elif [ -d "$src" ]; then
		mw_home=$src
	else
		lbl=${src%%/*}
		brnch=${src#*/}
		if [ "${brnch#/}" != "$brnch" ]; then
			mw_home=$src
			unset lbl brnch
		fi
	fi
fi

str=`chk_para.sh rcuimg "$_OPTION"`
str=${str##* }
if [ -n "$str" ]; then
	ve=`echo $str | grep "\$"`
	[ -n "$ve" ] && str=`eval echo "$str"`
	if [ ! -f "$str/$rcuprg" -a -n "$rcu" ]; then
		echo "${me##*/}:'$str' not contains '$rcuprg'."
		exit 1
	fi
	rcuptr=$str
fi
str=`chk_para.sh biimg "$_OPTION"`
str=${str##* }
if [ -n "$str" ]; then
	ve=`echo $str | grep "\$"`
	[ -n "$ve" ] && str=`eval echo "$str"`
	if [ ! -f "$str/$prg" ]; then
		echo "${me##*/}:'$str' not contains '$prg'."
		exit 1
	fi
	biptr=$str
	if [ -n "$rcu" -a -z "$rcuptr" -a ! -f "$biptr/$rcuprg" ]; then
		echo "${me##*/}:'$biptr' not contains '$rcuprg'."
		echo "You define biImg() option. And this process need to run RCU."
		echo "Please extract RCU image at above location."
		exit 1
	else
		rcuptr=$biptr
	fi
fi

# [ -z "$lbl" ] && lbl=MAIN
# [ -z "$brnch" ] && brnch=LATEST

secmode=rep
sec=`chk_para.sh secmode "$_OPTION"`; sec=${sec##* }; sec=`echo $sec | tr A-Z a-z`
[ -z "$sec" ] && sec=`echo $AP_SECMODE | tr A-Z a-z`
[ "$sec" = "fa" ] && secmode=fa

# Make $mw_home to absolute path
org_mwhome=$mw_home
str=`echo $mw_home | grep "\$"`
[ -n "$str" ] && export mw_home=`eval echo $mw_home 2>/dev/null`
[ ! -d "$mw_home" ] && mkddir.sh $mw_home 2> /dev/null
crrdir=`pwd`
cd $mw_home
mw_home=`pwd`
cd "$crrdir"
if [ "$HOME" = "$mw_home" ]; then
	echo "${me##*/}: Middleware home($org_mwhome) set to \$HOME($HOME) folder."
	echo "This script delete whole contents of the middleware home."
	echo "And $HOME contents will be deleted in this execution."
	echo "Please make sure the target location is correct."
	exit 1
fi
if [ "`pwd`" = "$mw_home" ]; then
	echo "${me##*/}: Middleware home($org_mwhome) set to current directory(`pwd`)."
	echo "This script delete whole contents of the middleware home."
	echo "And `pwd` contents will be deleted in this execution."
	echo "Please make sure the target location is correct."
	exit 1
fi

[ -z "$mds_db" ] && mds_db=$bi_db

# If bi_pwd and mds_pwd are not set, set it "password"
[ -z "$bi_pwd" ] && bi_pwd="password"
[ -z "$mds_pwd" ] && mds_pwd="password"
# Create Repository to the AP_BICONSTR(user defined).
[ "$rcu" = "true" ] && unset bi_db mds_db
# Check $bi_db empty
if [ -z "$bi_db" ]; then
	rcu=true
	if [ -z "$prf" ]; then
		cnt=30
		sts=0
		while [ $cnt -ne 0 ]; do
			lock.sh $bireplist $$ > /dev/null 2>&1
			sts=$?
			[ $sts -eq 0 ] && break
			let cnt=cnt-1
			sleep 1
		done
		if [ $sts -ne 0 ]; then
			echo "biinst.sh:Failed to lock $bireplist and no <conStr> parameter."
			echo "Plase unloack $bireplist or define <conStr>."
			exit 1
		fi
		if [ "$birepmethod" = "line" ]; then
			prf=`grep -n "$thisnode" $bireplist | tail -1`
			if [ -z "$prf" ]; then
				echo "$thisnode" >> $bireplist 2> /dev/null
				prf=`grep -n "$thisnode" $bireplist | tail -1`
			fi
			prf=${prf%%:*}
		else
			prf=`wc -l $bireplist 2> /dev/null | awk '{print $1}'`
			let prf=prf+1
			echo "$thisnode" >> $bireplist 2> /dev/null
		fi
		prf="0000${prf}"
		prf="D${prf#${prf%???}}"
		unlock.sh $bireplist
	fi
	bi_db=${AP_BICONSTR%:*:*:*}
	mds_db=$bi_db
	bi="${prf}_BIPLATFORM"
	mds="${prf}_MDS"
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
		echo "biinst.sh:The database value($val) for $one is invalid."
		echo "  This should be one of 'ora', 'oracle', 'mssql', 'sql', 'ibm'  or 'db2'."
		exit 2
	fi
	eval "$one=\"$nval\""
done

# Cleanup
echo "# Cleanup Inventory and mw_home, etc..."

echo "# - Re-create $HOME/oraInst.loc."
rm -rf $HOME/oraInst.loc 2> /dev/null
echo "inventory_loc=$HOME/Inventory" > $HOME/oraInst.loc
echo "inst_group=`id -g -n`" >> $HOME/oraInst.loc

echo "# - Delete $HOME/Inventory."
# rm -rf $HOME/Inventory 2> /dev/null
rmfld.sh $HOME/Inventory

echo "# - Delete $HOME/oradiag_${LOGNAME}."
# rm -rf $HOME/oradiag_${LOGNAME} 2> /dev/null
rmfld.sh $HOME/oradiag_${LOGNAME}

echo "# - Delete $HOME/bi.rsp. # Created by biinst.sh"
rm -rf $HOME/bi.rsp 2> /dev/null

echo "# - Delete $mw_home. # - Installation destination should be empty."
rmfld.sh $mw_home
# rm -rf $mw_home 2> /dev/null

[ `uname` = "Windows_NT" ] && win_cleanup.sh
# Debug print
if [ "$dbg" = "true" ]; then
	echo "biinst.sh:`date +%D_%T` Variabls list:"
	echo "# me=$me"
	echo "# orgpar=$orgpar"
	echo "# dbg=$dbg"
	echo "# lbl=$lbl"
	echo "# brnch=$brnch"
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
	echo "# rcu=$rcu"
	echo "# prf=$prf"
	echo "# AP_BICONSTR=$AP_BICONSTR"
	echo "# bireplist=$bireplist"
	echo "# birepmethod=$birepmethod"
	echo "# biptr=$biptr"
	echo "# biprg=$prg"
	echo "# rcuptr=$rcuptr"
	echo "# rcuprg=$rcuprg"
	echo "# src=$src"
fi

# If the source is BISHIPHOME, extract zip files
if [ -z "$biptr" ]; then
	bitmp=bitmp
	while [ -d "$mywork/$bitmp" ]; do
		echo "# - Delete $mywork/$bitmp. # - created by biinst.sh"
		rm -rf $mywork/bitmp 2> /dev/null
		if [ -d "$mywork/$bitmp" ]; then
			echo "### Couldn't delete $mywork/$bitmp folder."
			echo "### Please delete $bitmp folder by root user."
			if [ "$bitmp" = "bitmp" ]; then
				bitmp="bitmp1"
			else
				n=${bitmp#bitmp}
				let n=n+1
				bitmp="bitmp${n}"
			fi
			echo "### This program will try $bitmp next."
		fi
	done
	mkddir.sh $mywork/$bitmp 2> /dev/null
	echo "### Extract $lbl:$brnch to $mywork/$bitmp"
	[ "$rcu" = "true" ] \
		&& ext_bi.sh -rcu "$lbl/$brnch" $mywork/$bitmp \
		|| ext_bi.sh -norcu "$lbl/$brnch" $mywork/$bitmp
	sts=$?
	if [ $sts -ne 0 ]; then
		echo "biinst.sh:Failed to extract $lbl/$brnch to the $mywork/$bitmp."
		echo "  ext_bi.sh returned $sts."
		exit 4
	fi
	biptr=$mywork/$bitmp
	[ -n "$rcu" -a -z "$rcuptr" ] && rcuptr=$biptr
fi

# Make silent response file
rsp=$HOME/bi_${secmode}.rsp
[ -f "$rsp" ] && rm -rf $rsp 2>&1 > /dev/null
[ "$secmode" = "fa" ] && _rsp=bi_fa.rsp || _rsp=bi_rep.rsp
echo "# Make response file from $_rsp."
cat $AUTOPILOT/rsp/$_rsp | sed \
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
if [ "$rcu" = "true" ]; then
	echo "### biinst.sh:`date +%D_%T` Start RCU utility."
	constr=${AP_BICONSTR#*:}
	conusr=${constr#*:*:*:}
	conpwd=${conusr#*:}
	conroll=${conpwd#*:}
	conpwd=${conpwd%:*}
	conusr=${conusr%:*:*}
	constr=${constr%:*:*:*}
	if [ "$dbg" = "true" ]; then
		echo "# prf=$prf"
		echo "# constr=$constr"
		echo "# conusr=$conusr"
		echo "# conpwd=$conpwd"
		echo "# conroll=$conroll"
	fi

	echo "$conpwd" \
		| $rcuptr/$rcuprg -silent -dropRepository\
			-connectString $constr \
			-dbRole $conroll \
			-dbUser $conusr \
			-schemaPrefix $prf \
			-component BIPLATFORM \
			-component MDS > /dev/null 2>&1
	(echo "$conpwd";echo "$bi_pwd"; echo "$mds_pwd") \
		| $rcuptr/$rcuprg -silent -createRepository\
			-connectString $constr \
			-dbRole $conroll \
			-dbUser $conusr \
			-schemaPrefix $prf \
			-component BIPLATFORM \
			-component MDS
	sts=$?
fi
if [ $sts -eq 0 ]; then
	echo "### biinst.sh:`date +%D_%T` Start BISHIPHOME installer"
	echo "### - Kill BI releated processes."
	kill_essprocs.sh all # -biall
	hitcleanup.sh
	[ -n "$ORACLE_HOME" ] && unset ORACLE_HOME
	if [ "${thisplat#win}" != "$thisplat" ]; then
		H="HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion"
		prgdir=`registry -p -r -k "$H" -n "ProgramFilesDir" 2> /dev/null`
		print -r "# prgdir=$prgdir"
		# Delete inventry
		# Delete log files
		rm -rf "$prgdir/Oracle/Inventory/logs" 2> /dev/null
		$biptr/$prg -silent -response $rsp -waitforcompletion &
		bipid=$!
		echo "# BI pid=$bipid"
		cl=0
		logf=
		while [ -n "`ps -p $bipid 2> /dev/null | grep -v PID`" ]; do
			if [ -z "$logf" ]; then
				if [ -d "$prgdir/Oracle/Inventory/logs" ]; then
					crr=`pwd`
					cd "$prgdir/Oracle/Inventory/logs" 2> /dev/null
					logf=`ls -r install*.out 2> /dev/null | head -1`
					[ ! -f "$logf" ] && logf= || logf=`pwd`/$logf
					cd $crr
				fi
			fi
			if [ -f "$logf" ]; then
				ttl=`cat "$logf" 2> /dev/null | wc -l`
				let ttl=ttl
				let nl=ttl-cl
				tail -$nl "$logf"
				let cl=ttl
			fi
		done
		sts=0
		opmnprg="opmnctl.bat"
	else
		echo "# $biptr/$prg -silent -response $rsp -waitforcompletion -invPtrLoc $HOME/oraInst.loc"
		$biptr/$prg -silent -response $rsp -waitforcompletion -invPtrLoc $HOME/oraInst.loc
		sts=$?
		opmnprg="opmnctl"
	fi
else
	echo "### biinst.sh:`date +%D_%T` RCU retuned $sts."
	exit $sts
fi

if [ $sts -ne 0 ]; then
	echo "### biinst.sh:`date +%D_%T` BISHIPHOME installer retuned $sts."
	exit $sts
else
	export HYPERION_HOME=$mw_home/Oracle_BI1
	export SXR_USER=weblogic
	export SXR_PASSWORD=welcome1
	# Stop ESSBASE and OPMN
	echo "### - Stop opmn and Essbase related process"
	stop_service.sh
	# Make bi_version.txt
	lbl=`head -1 $biptr/bishiphome/Labels.txt`
	lbl=${lbl##* }
	rm -f $mw_home/Oracle_BI1/bi_version.txt 2> /dev/null
	rm -f $mw_home/Oracle_BI1/bi_label.txt 2> /dev/null
	rm -f $mw_home/Oracle_BI1/bi_source.txt 2> /dev/null
	echo "BI($lbl/$brnch)" > $mw_home/Oracle_BI1/bi_version.txt 2> /dev/null
	echo "$lbl" > $mw_home/Oracle_BI1/bi_label.txt 2> /dev/null
	echo "$biptr" > $mw_home/Oracle_BI1/bi_source.txt 2> /dev/null
	echo "$secmode" > $mw_home/Oracle_BI1/bi_mode.txt 2> /dev/null
	# Make initial instans into instances.tar
	echo "# Make initial instance backup(HH:$HYPERION_HOME)"
	cd ${HYPERION_HOME%/*}
	rm -rf instances.tar 2> /dev/null
	tar -cf instances.tar instances/* 2> /dev/null
	echo "### - Start WebLogic service."
	start_service.sh
	echo "### biinst.sh:`date +%D_%T` Done."
	exit 0
fi
