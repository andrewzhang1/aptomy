#!/usr/bin/env bash

# dmccmiblock.sh: Erase the empty line for the output
awk '($0 !~ /^ *$/) {print $0}' dmccmiblock1.out  > dmccmiblock1.out1

# Remove dup line
awk '!a[$0]++' dup1 > no_dup


# 1) $?, $#, $@
## 1-1) Check if the command successful (C, python, etc language is the opposite):
type openssl >/dev/null 2>&1
if (($?==0)); then
    echo "openssl is found, proceed ..."
else
    echo "openssl is NOT found, use default keys files"
fi

## 1-2) Check if the total number of the parameters on the command line:

if [ $# != 2 ]
then
    echo "You need two parameters (and ONLY two): output file and baseline"
    exit 1
fi


https://stackoverflow.com/questions/9994295/what-does-mean-in-a-shell-script
$@ = stores all the arguments in a list of string
$* = stores all the arguments as a single string
$# = stores the number of arguments
$? = stores the number of arguments

# Command Line:
# test2.sh 1  2 3 a b
for a in "$@"
do
    echo "Run  $a"
done

(azhang@vmlxu1)\>test2.sh 1  2 3 a b
Run  1
Run  2
Run  3
Run  a
Run  b


# Check suc and dif files:

ls $QA_HOME/work/*.suc 2> /dev/null
if (($?==0)); then
    echo "No suc file is found; tests might be wrong! " 2>&1 | tee -a $logf
else
    echo "Total suc files: `ls $QA_HOME/work/*.suc`" 2>&1 | tee -a $logf
fi

ls $QA_HOME/work/*.dif 2> /dev/null
if (($?==0)); then
        echo " Greate, no dif was found!! " 2>&1 | tee -a $logf
    else
        echo "Dif if files found: `ls $QA_HOME/work/*.dif`"  2>&1 | tee -a $logf
fi


# Tuan’s running infinitive loop: dctp02_aso_loop.sh until fine *.diff file in the work folder
keeplooping=1;

while [ $keeplooping -eq 1 ] ; do

if [ -a $VIEW_PATH/$SXR_INVIEW/work/*.dif ] ; then
        echo "There are difs in work folder..."
        keeplooping=0
else
        sxr sh dctp02_aso.sh
fi
done


# IP scan

# Concurrent test

script1 &
script2 &



05/03/25 essbase.func	1
esscmd.func	2
Maxl.func	24
Css.func	32
Aug. 19 Create concurrent login from stsun8 to azhang1:	36
1. to change localhost to azhang1	36
2. split one text file into 1000 scr files	36
Aug. 18	36
Mar. 6, 2003 truncate the unwanted info from getdbstats	37
Jan.24, 2003 Run script at backgroung – Christina	38
loop	38
Example 1:	38
Example 2:	39
Example 3:	39
Example 4:	40
Chose different platforms Different server	40
Kevin’s dmccrmcc.sh	41
Maxl variable substitution and loop (for essexer 2_20a)	43
Create_app-mxl.sh	43
create_app_loop.mxl	44
Bao’s if-else control	44
agtptsumain-1.sh	44
Run Result	46
1) sxr  sh agtptsumain-1.sh	46
2) sxr  sh agtptsumain-1.sh 1	46
3) sxr  sh agtptsumain-1.sh 2	46
4) sxr  sh agtptsumain-1.sh serial buffer	46
5) sxr  sh agtptsumain-1.sh serial direct	46
6) sxr  sh agtptsumain-1.sh serial direct 1	46


05/03/25 essbase.func

############################################################################
#
# File: essbase.func
# Purpose: logic for loading different modules depending on the value of
#	       ${SXR_SCR_TYPE} environment variable.
#
#    1) Always include the 'esscmd.func' module for all tests
#    2) if ${SXR_SCR_TYPE} = "MaxL" or "" (undefined, by default)
#          include 'maxl.func' module
#
# Modifications:
#
#

# Module name
ESSCMDMOD=`sxr which -sh esscmd.func`
MAXLMOD=`sxr which -sh maxl.func`

# Set ${SXR_SCR_TYPE} = 'MaxL' and
#     ${SXR_MODE} = 'ASO' by default for Essbase 7.1
if [ -z "${SXR_SCR_TYPE}" ]; then
    SXR_SCR_TYPE="maxl"; export SXR_SCR_TYPE
fi

# Use lower case value to compare
# typeset -l SXR_SCR_TYPE SXR_MODE # does not work on Linux
SXR_SCR_TYPE=`echo $SXR_SCR_TYPE | tr [A-Z] [a-z]`
SXR_MODE=`echo $SXR_MODE | tr [A-Z] [a-z]`

# Include ${ESSCMDMOD} for all tests
. ${ESSCMDMOD}

# Include ${MAXLMOD} only if ${SXR_SCR_TYPE} = 'MaxL'
if [ "${SXR_SCR_TYPE}" = "maxl" ]; then
    . ${MAXLMOD}
    if [ -z "${SXR_MODE}" ]; then
	SXR_MODE="aso"; export SXR_MODE
    fi
else
    SXR_MODE="dso"; export SXR_MODE
fi

esscmd.func

############################################################################
#
# File: esscmd.func
# Purpose: create a collection of common used functions using ESSCMD scripts.
#          These functions will be made available to all tests.
#
# Date created: 12/4/2003
#
# Modifications:
#
# 08/23/04 by nnguyen - reimplemented exiting tests based on returned error code
# 10/15/04 by nnguyen - added set member formula from file function (addformulafromfile)
#
############################################################################

FUNCMOD=`sxr which -sh esscmd.func`
echo "Loading ${FUNCMOD} module..."

# Default error code
export errcode=0


############################################################################
# Copy a File

# Copy File to database directory from essexer data directory
copy_file_to_db ()
{
# [From] FileName AppName DBName
if [ $# -eq 3 ]; then
    sxr fcopy -in -data $1 -out !$2!$3!
else
    sxr fcopy -in $1 $2 -out !$3!$4!
fi
}


# Copy file to work directory from essexer data directory
copy_file_to_work ()
{
# [From] FileName
if [ $# -eq 1 ]; then
    sxr fcopy -in -data $1
else
    sxr fcopy -in $1 $2
fi
}


############################################################################
# Server Essbase.cfg Manipulation

# Copy a file in Server $ARBOR/Bin dir to another name in Server $ARBOR/Bin dir
copy_cfg ()
{
# OldFileName, NewFileName
export SXR_ESSCMD='ESSCMD'
sxr esscmd -q msxxcopycfgfile.scr %HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD \
                                %OLDFILE=$1 %NEWFILE=$2
export SXR_ESSCMD='ESSCMD'
}


# Delete file from Server $ARBOR/Bin dir
delete_cfg ()
{
# File to delete
export SXR_ESSCMD='ESSCMD'
sxr esscmd -q msxxremovecfgfile.scr %HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD %CFGFILE=$1
export SXR_ESSCMD='ESSCMD'
}


# Rename a file in Server $ARBOR/Bin dir
rename_cfg ()
{
# OldFileName, NewFileName
export SXR_ESSCMD='ESSCMD'
sxr esscmd -q msxxrenamecfgfile.scr %HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD \
                                    %OLDFILE=$1 %NEWFILE=$2
export SXR_ESSCMD='ESSCMD'
}


# Append file contents to Essbase.cfg file on server
send_to_cfg ()
{
# File containing new settings to Append
export SXR_ESSCMD='ESSCMD'
sxr esscmd -q msxxsendcfgfile.scr %HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD %CFGFILE=$1
export SXR_ESSCMD='ESSCMD'
}

############################################################################
# Application and Database Manipulation

# Create a new app
create_app ()
{
# AppName
sxr newapp -force $1
if [ $? -ne 0 ]; then
    errcode=$?
    echo "!!!FAILURE!!! Failed to create app [$1]!" | tee -a "Failure.$$.dif"
    exit $errcode
fi
}


# Create a new db
create_db ()
{
# [OutlineName] AppName DBName
if [ $# -eq 2 ]; then
    echo "Just create an empty db"
    sxr newdb $1 $2
else
    echo "Create new db from a saved outline file $1"
    sxr newdb -otl $1 $2 $3
fi
if [ $? -ne 0 ]; then
    errcode=$?
    if [ $# -eq 2 ]; then
	echo "!!!FAILURE!!! Failed to create db [$1.$2]!" | tee -a "Failure.$$.dif"
    else
	echo "!!!FAILURE!!! Failed to create app [$2.$3]!" | tee -a "Failure.$$.dif"
    fi
    exit $errcode
fi
}


# Delete application
delete_app ()
{
# AppName
sxr esscmd msxxrmap.scr %HOST=$SXR_DBHOST %USER=$SXR_USER %PASSWD=$SXR_PASSWORD %APP=$1
}


# Delete Database
delete_db ()
{
# AppName DBName
sxr esscmd msxxrmdb.scr %HOST=$SXR_DBHOST %USER=$SXR_USER %PASSWD=$SXR_PASSWORD %APP=$1 %DB=$2
}


# Copy application
copy_app()
{
# SourceAppName DestAppName
sxr esscmd msxxcopyapp.scr %HOST=${SXR_DBHOST} %UID=${SXR_USER} %PWD=${SXR_PASSWORD} \
			    %SRCAPP=$1 %DESTAPP=$2
}


# Copy database
copy_db()
{
# SourceAppName SourceDBName DestAppName DestDBName
sxr esscmd msxxcopydb.scr %HOST=${SXR_DBHOST} %UID=${SXR_USER} %PWD=${SXR_PASSWORD} \
			  %SRCAPP=$1 %SRCDB=$2 %DESTAPP=$3 %DESTDB=$4
}


# Rename application
rename_app()
{
# OldAppName NewAppName
sxr esscmd msxxrenapp.scr %HOST=${SXR_DBHOST} %UID=${SXR_USER} %PWD=${SXR_PASSWORD} \
			    %OLDAPP=$1 %NEWAPP=$2
}


# Rename database
rename_db()
{
# AppName DBName NewDBName
sxr esscmd msxxrendb.scr %HOST=${SXR_DBHOST} %UID=${SXR_USER} %PWD=${SXR_PASSWORD} \
			    %APP=$1 %OLDDB=$2 %NEWDB=$3
}


# Load application
load_app ()
{
# AppName
sxr esscmd msxxldap.scr %HOST=$SXR_DBHOST %USER=$SXR_USER %PASSWD=$SXR_PASSWORD %APP=$1
}


# Reload Application
reload_app ()
{
    unload_app $1
    load_app $1
}


# Unload Application
unload_app ()
{
# AppName
sxr esscmd msxxunloadapp.scr %HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD %APP=$1
}


# Unload Database
unload_db ()
{
# AppName DBName
sxr esscmd msxxunloaddb.scr %HOST=$SXR_DBHOST %USER=$SXR_USER %PASSWD=$SXR_PASSWORD \
				%APPNAME=$1 %DBNAME=$2
}


# Set Database State
dbstate_set ()
{
# AppName DBName Item Argument1 Argument2
sxr esscmd msxxsetdbstitem.scr 	%HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD \
				%APP=$1 %DB=$2 %ITEM=$3 %ARG1=$4 %ARG1=$5 %ARG2=$6
}


# Get Database State
dbstate_get ()
{
# AppName DBName OutputFileName
sxr esscmd msxxgetdbstate.scr	%HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD \
				%APP=$1 %DB=$2 %OFILE=$3
}


# Get Database Statistics
dbstat_get ()
{
# AppName DBName OutputFileName
sxr esscmd msxxgetdbstats.scr	%HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD \
				%APP=$1 %DB=$2 %OFILE=$3
}


# Get limit
get_limit()
{
# AppName DBName OutFile
sxr esscmd -q smalgetlimit.scr %HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD \
				%APP=$1 %DB=$2 %OUT=$3
}


# Get the app log
applog_copy ()
{
# AppName OutputFileName
sxr esscmd -q msxxgetlog.scr 	%HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD \
				%APP=$1 %LOG=$2
}


# Delete the app log
delete_log ()
{
# AppName
sxr esscmd -q msxxdellog.scr 	%HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD %APP=$1
}


# Export data - column format
export_data ()
{
# AppName DBName OutputFile ExportOption
sxr esscmd msxxcolexport.scr	%HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD \
				%APP=$1 %DB=$2 %EXPORTPATH=$SXR_WORK %FILENAME=$3 %NUM=$4
}


# Reset/clear data
reset_db ()
{
# AppName DBName
sxr esscmd msxxresetdb.scr	%HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD \
				%APP=$1 %DB=$2
}


# Create Substitution Variable
create_sub_var ()
{
# AppName DBName SubstitutionVariable SubstitutionValue
sxr esscmd msxxcreatesubvar.scr	%HOST=$SXR_DBHOST %USER=$SXR_USER %PASSWD=$SXR_PASSWORD \
				%APPNAME=$1 %DBNAME=$2 %SUBVAR=$3 %SUBVAL=$4
}



############################################################################
# Load Data

# Load Data
load_data ()
{
# AppName DBName DataFile [LoadOpt]
# Where LoadOpt = 3 (local - default) | 2 (server)
if [ "$4" = "2" ]; then
    sxr esscmd msxxloaddataserver.scr  %HOST=$SXR_DBHOST %USER=$SXR_USER %PASSWD=$SXR_PASSWORD \
					%APPNAME=$1 %DBNAME=$2 %LOADDATA=$3
else
    sxr esscmd msxxloaddata.scr  %HOST=$SXR_DBHOST %USER=$SXR_USER %PASSWD=$SXR_PASSWORD \
					%APPNAME=$1 %DBNAME=$2 %LOADDATA=`sxr which -data $3`
fi
if [ $? -ne 0 ]; then
    errcode=$?
    echo "!!!FAILURE!!! Failed to load data [$3]!" | tee -a "Failure.$$.dif"
    exit $errcode
fi
}



# Import_data
import_data ()
{
# AppName DBName DataFileLocation DataLoadFileName DataLoadFileType RuleFileLocation RuleFileName

sxr esscmd msxximport.scr 	%HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD \
				%APP=$1 %DB=$2 %DLOC=$3 %DFILE=`sxr which -data $4` \
				%TYPE=$5 %RLOC=$6 %RFILE=`sxr which -data $7`
}



############################################################################
# Run Calc

# Run Default Calc
runcalc_default ()
{
# AppName DBName
sxr esscmd msxxrundefaultcalc.scr	%HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD \
					%APP=$1 %DB=$2
}


# Run Custom Calc Script
runcalc_custom ()
{
# AppName DBName CalcScriptNAme
sxr esscmd msxxcsc.scr		%HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD \
				%APP=$1 %DB=$2 %CSC=`sxr which -csc $3`
}


# Run Calc Script
run_calc ()
{
# AppName DBName [CalcScriptNAme]
if [ $# -eq 2 ]; then
    runcalc_default $1 $2
else
    runcalc_custom $1 $2 $3
fi
}



############################################################################
# Partition Manipulation

# Create transparent partition with mapping
trans_part ()
{
# OutputFileName SourceAppName SourceDBName SourceArea TargetAppName TargetDBName TargetArea SourceMapping TargetMapping
export SXR_ESSCMD='essmsh'
sxr esscmd msxxtransparentpart.msh   %1=$1 %2=$2 %3=$3 %4=$4 %5=$5 %6=$6 %7=$7 %8=$8 %9=$9
export SXR_ESSCMD='ESSCMD'
}


# Create replicated partition with mapping
replic_part ()
{
# OutputFileName SourceAppName SourceDBName SourceArea TargetAppName TargetDBName TargetArea SourceMapping TargetMapping
export SXR_ESSCMD='essmsh'
sxr esscmd msxxreplicatedpart.msh   %1=$1 %2=$2 %3=$3 %4=$4 %5=$5 %6=$6 %7=$7 %8=$8 %9=$9
export SXR_ESSCMD='ESSCMD'
}


# Create linked partition with mapping
link_part ()
{
# OutputFileName SourceAppName SourceDBName SourceArea TargetAppName TargetDBName TargetArea SourceMapping TargetMapping
export SXR_ESSCMD='essmsh'
sxr esscmd msxxlinkedpart.msh   %1=$1 %2=$2 %3=$3 %4=$4 %5=$5 %6=$6 %7=$7 %8=$8 %9=$9
export SXR_ESSCMD='ESSCMD'
}


# Drop partition
drop_partition ()
{
# PartitionType SourceAppName SourceDBName TargetAppName TargetDBName
sxr msh msxxdroppartition.msh $SXR_USER $SXR_PASSWORD $SXR_DBHOST $1 $2 $3 $4 $5
}


# Refresh replicated partition
refresh_repl_part ()
{
# SourceAppName SourceDBName TargetAppName TargetDBName [all | updated]
sxr msh msxxrefreshreplpart.msh $SXR_USER $SXR_PASSWORD $SXR_DBHOST "$1" "$2" "$3" "$4" "$5"
}


# Refresh outlien
refresh_outline ()
{
# [replicated | transparent | linked ] SourceAppName SourceDBName TargetAppName TargetDBName
#	[purge outline change_file | apply all | apply nothing ]
sxr msh msxxrefreshoutline.msh $SXR_USER $SXR_PASSWORD $SXR_DBHOST "$1" "$2" "$3" "$4" "$5" "$6"
}


############################################################################
# Spreadsheet Requests

# Retrieve data
ret_data()
{
export SXR_ESSCMD='ESSCMDG'
sxr esscmd smalxret.scr %HOST=$SXR_DBHOST %USER=$SXR_USER %PWD=$SXR_PASSWORD \
			%APP=$1 %DB=$2 %ROW=$3 %COL=$4 \
			%IFILE=`sxr which -data $5` \
			%RSIZE="$6" %CSIZE="$7" %OFILE="$8"
export SXR_ESSCMD='ESSCMD'
}


# Retrieve
retrieve ()
{
# UserName UserPassword AppName DBName RetrieveInputFileName TotalColumnsInRetrive TotalRowsInRetrieve RetrieveOutputFileName
export SXR_ESSCMD='ESSCMDG'
sxr esscmd msxxrtv.scr  	%HOST=$SXR_DBHOST %USER=$SXR_USER %PASSWD=$SXR_PASSWORD \
				%APPNAME=$1 %DBNAME=$2 %INITROW=65000 %INITCOL=250 \
				%RTVIN=`sxr which -data $3` %ROW=$4 %COL=$5 %RTVOUT=$6
export SXR_ESSCMD='ESSCMD'
}


# Zoom In
zoom_in ()
{
# AppName DBName ZoomInFileName TotalRowsInFile TotalColumnsInFile ZoomInRowCell ZoomInColumnCell ZoomInLevel ZoomInOuputFileName

export SXR_ESSCMD='ESSCMDG'
sxr esscmd msxxzoomin.scr  	%HOST=$SXR_DBHOST %USER=$SXR_USER %PASSWD=$SXR_PASSWORD \
		    		%APPNAME=$1 %DBNAME=$2 %INITROW=65000 %INITCOL=250 \
				%ZIN=`sxr which -data $3` %TROW=$4 %TCOL=$5 %ZROW=$6 \
				%ZCOL=$7 %ZLEV=$8 %ZOUTP=$9 %ZOPT=1
export SXR_ESSCMD='ESSCMD'
}


# Zoom Out
zoom_out ()
{
# AppName DBName ZoomOutFileName TotalRowsInFile TotalColumnsInFile ZoomOutRowCell ZoomOutColumnCell ZoomOutOuputFileName

export SXR_ESSCMD='ESSCMDG'
sxr esscmd msxxzoomout.scr  	%HOST=$SXR_DBHOST %USER=$SXR_USER %PASSWD=$SXR_PASSWORD \
		    		%APPNAME=$1 %DBNAME=$2 %INITROW=65000 %INITCOL=250 \
				%ZOFILE=`sxr which -data $3` %TROW=$4 %TCOL=$5 %ZOROW=$6 \
				%ZOCOL=$7 %ZOOUT=$8
export SXR_ESSCMD='ESSCMD'
}


# Keep Only
keep_only ()
{
# AppName DBName KeepOnlyFileName TotalRowsInFile TotalColumnsInFile KeepOnlyRowCell KeepOnlyColumnCell KeepOnlyOuputFileName

export SXR_ESSCMD='ESSCMDG'
sxr esscmd msxxkeeponly.scr  	%HOST=$SXR_DBHOST %USER=$SXR_USER %PASSWD=$SXR_PASSWORD \
		    		%APPNAME=$1 %DBNAME=$2 %INITROW=65000 %INITCOL=250 \
				%KFILE=`sxr which -data $3` %TROW=$4 %TCOL=$5 %KROW=$6 \
				%KCOL=$7 %KOUT=$8
export SXR_ESSCMD='ESSCMD'
}


# Remove Only
remove_only ()
{
# AppName DBName RemoveOnlyFileName TotalRowsInFile TotalColumnsInFile RemoveOnlyRowCell RemoveOnlyColumnCell RemoveOnlyOuputFileName

export SXR_ESSCMD='ESSCMDG'
sxr esscmd msxxremoveonly.scr  	%HOST=$SXR_DBHOST %USER=$SXR_USER %PASSWD=$SXR_PASSWORD \
		    		%APPNAME=$1 %DBNAME=$2 %INITROW=65000 %INITCOL=250 \
				%RFILE=`sxr which -data $3` %TROW=$4 %TCOL=$5 %RROW=$6 \
				%RCOL=$7 %ROUT=$8
export SXR_ESSCMD='ESSCMD'
}


# Lock and Send
lock_send ()
{
# AppName DBName LockAndSendFileName TotalRowsInFile TotalColumnsInFile

export SXR_ESSCMD='ESSCMDG'
sxr esscmd msxxlockandsend.scr  %HOST=$SXR_DBHOST %USER=$SXR_USER %PASSWD=$SXR_PASSWORD \
		    		%APPNAME=$1 %DBNAME=$2 %INITROW=65000 \
				%INITCOL=250 %UPDATE=`sxr which -data $3` %ROW=$4 %COL=$5
export SXR_ESSCMD='ESSCMD'
}


# Pivot
pivot_only ()
{
# AppName DBName PivotFileName TotalRowsInFile TotalColumnsInFile PivotRowCell PivotColumnCell PivotOuputFileName

export SXR_ESSCMD='ESSCMDG'
sxr esscmd msxxpivot.scr  	%HOST=$SXR_DBHOST %USER=$SXR_USER %PASSWD=$SXR_PASSWORD \
		    		%APPNAME=$1 %DBNAME=$2 %INITROW=65000 %INITCOL=250 \
				%PFILE=`sxr which -data $3` %TROW=$4 %TCOL=$5 %PROW=$6 \
				%PCOL=$7 %POUT=$8
export SXR_ESSCMD='ESSCMD'
}



############################################################################
# User Manipulation

# Grant application access to user
grant_app ()
{
# OutputFileName AccessLevel AppName UserName
export SXR_ESSCMD='essmsh'
sxr esscmd msxxgrantappaccess.scr   %1="$1" %2="$2" %3="$3" %4="$4"
export SXR_ESSCMD='ESSCMD'
}


# Grant database access to user
grant_db ()
{
# OutputFileName AccessLevel AppName DBName UserName
export SXR_ESSCMD='essmsh'
sxr esscmd msxxgrantdbaccess.scr   %1="$1" %2="$2" %3="$3" %4="$4" %5="$5"
export SXR_ESSCMD='ESSCMD'
}


# Grant system access to user
grant_system ()
{
# OutputFileName AccessLevel UserName
export SXR_ESSCMD='essmsh'
sxr esscmd msxxgrantsystemaccess.scr   %1="$1" %2="$2" %3="$3"
export SXR_ESSCMD='ESSCMD'
}


# Create group
create_group ()
{
# OutputFileName GroupName
export SXR_ESSCMD='essmsh'
sxr esscmd msxxcreategroup.scr    %1="$1" %2="$2"
export SXR_ESSCMD='ESSCMD'
}


# Create user
create_user ()
{
# UserName
sxr msh msxxcreateuser.msh    $SXR_USER $SXR_PASSWORD $SXR_DBHOST "$1"
}


# Delete user
delete_user ()
{
# UserName
sxr msh msxxdrop_user.msh    $SXR_USER $SXR_PASSWORD $SXR_DBHOST "$1"
}


# Add user to group
add_togroup ()
{
# OutputFileName UserName GroupName
export SXR_ESSCMD='essmsh'
sxr esscmd msxxaddtogroup.scr   %1="$1" %2="$2" %3="$3"
export SXR_ESSCMD='ESSCMD'
}


############################################################################
# New commands for E-license


# Display license info
display_license_info ()
{
# OutFile
sxr msh msxxdisplicinfo.msh ${SXR_USER} ${SXR_PASSWORD} ${SXR_DBHOST} $1
}


# Create app type
create_app_type ()
{
# Location AppName StorageType AppType FrontEndType OutFile
sxr esscmd -q msxxcreappwithtype.scr %HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD \
	    %LOC="$1" %APPNAME="$2" %STOTYPE="$3" %APPTYPE="$4" %FRONTENDTYPE="$5" %OUTFILE="$6"
}


# Get app type
get_app_type ()
{
# AppName OutFile
sxr esscmd -q msxxgetapptype.scr %HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD \
				    %APP="$1" %OUTFILE="$2"
}


# Set app type
Set_app_type ()
{
# AppName FrontEndType OutFile
sxr esscmd -q msxxsetapptype.scr %HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD \
				    %APP="$1" %FRONTENDTYPE="$2" %OUTFILE="$3"
}


# Create external user with type
create_extuser_type ()
{
# OutFile UserName UserPwd Protocol ConnectionParam Type
# Note: Type = "1 2 -1" for Essbase|Planning for example
sxr esscmd -q msxxcreextuserwithtype.scr %HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD \
		%OUTFILE="$1" %USERNAME="$2" %USERPWD="" %PRO="$3" %CON="" %TYPE="$4"
}


# Create user with type
create_user_type ()
{
# OutFile UserName UserPwd AccLev Type
# Note: Type = "1 2 -1" for Essbase|Planning for example
sxr esscmd -q msxxcreuserwithtype.scr %HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD \
			    %OUTFILE="$1" %USERNAME="$2" %USERPWD="$3" %ACCLEV="$4" %TYPE="$5"
}


# Create user with type and key
create_user_type_key ()
{
# OutFile UserName UserPwd PlatformToken Type
# Note: Type = "1 2 -1" for Essbase|Planning for example
sxr esscmd -q msxxcreuserwithtypekey.scr %HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD \
			    %OUTFILE="$1" %USERNAME="$2" %USERPWD="$3" %FLATTOKEN="$4" %TYPE="$5"
}


# Get user type
get_user_key_type ()
{
# UserName OutFile
sxr esscmd -q msxxgetuserkeyandtype.scr %HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD \
				    %USERNAME="$1" %OUTFILE="$2"
}


# Get user type
get_user_type ()
{
# UserName OutFile
sxr esscmd -q msxxgetusertype.scr %HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD \
				    %USERNAME="$1" %OUTFILE="$2"
}


# Set user type
set_user_type ()
{
# OutFile UserName Type Cmd
# Note: Type = "1 2 -1" for Essbase|Planning for example
sxr esscmd -q msxxsetusertype.scr %HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD \
			    %OUTFILE="$1" %USERNAME="$2" %TYPE="$3" %CMD="$4"
}


############################################################################
# LRO's

# Create a linked reporting object - Cell Note
create_lro_note ()
{
# Member1 Member2 Member3 Member4 CellNote NumberOfDimensions AppName DBName

sxr esscmd -q msxxcreatelronote.scr %HOST=$SXR_DBHOST %USER=$SXR_USER %PASSWD=$SXR_PASSWORD \
					%MEM1="$1" %MEM2="$2" %MEM3="$3" %MEM4="$4" \
                                	%NOTE="$5" %DIMS="$6" %APP=$7 %DB=$8
}


# Create a linked reporting object - URL
create_lro_url ()
{
# Member1 Member2 Member3 Member4 URL Comment NumberOfDimensions AppName DatabaseNam

sxr esscmd -q msxxcreatelrourl.scr      %HOST=$SXR_DBHOST %USER=$SXR_USER %PASSWD=$SXR_PASSWORD \
                                	%MEM1="$1" %MEM2="$2" %MEM3="$3" %MEM4="$4" \
                                	%URL="$5" %COMMENt="$6" %DIMS="$7" %APP=$8 %DB=$9
}


# Create a linked reporting object - file
create_lro_file ()
{
# Member1 Member2 Member3 Member4 NumberOfDimensions FileToBeAttached Comment AppName DBName

sxr fcopy -in -data "$FILE"
sxr esscmd -q msxxcreatelrofile.scr     %HOST=$SXR_DBHOST %USER=$SXR_USER %PASSWD=$SXR_PASSWORD \
                                	%MEM1="$1" %MEM2="$2" %MEM3="$3" %MEM4="$4" \
	                                %DIMS="$5" %FILE=$SXR_WORK/$6 %COMMENT="$7" %APP=8 %DB=$9
}


# List Linked Reporting objects per database
list_lro ()
{
# OutputFileName ValidateFileName AppName DBName

sxr esscmd -q msxxlistlro.scr   %HOST=$SXR_DBHOST %USER=$SXR_USER %PASSWD=$SXR_PASSWORD \
                                %OUTPUT=$1 %VALIDATE=$2 %APP=$3 %DB=$4
}



############################################################################
# Outline Manipulation

# Add a dimension
add_dim ()
{
# NewDimensionName DenseSparseCofig SiblingOfNewDimension AppName DBName

sxr esscmd -q msxxadddim.scr     %HOST=$SXR_DBHOST %USER=$SXR_USER %PASSWD=$SXR_PASSWORD \
                                 %NEWDIM="$1" %CONF="$2" %FINDMEM="$3" %APP=$4 %DB=$5
}


# Build Dimension
build_dim ()
{
# AppName DBName RuleFileName BuildFileFileName

sxr esscmd msxxbuild.scr	%HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD \
		    		%APP=$1 %DB=$2 %RFILE=`sxr which -data $3` \
				%DFILE=`sxr which -data $4`
}


# Add a member
add_mem ()
{
# SiblingOfNewMember NewMemberName ParentForNewMember AppName DBName

sxr esscmd -q msxxaddmem.scr    %HOST=$SXR_DBHOST %USER=$SXR_USER %PASSWD=$SXR_PASSWORD \
                                %SIB="$1" %ADD="$2" %PARENT="$3" %APP=$4 %DB=$5
}


# Add a member with formula
add_mdx_mem ()
{
# SiblingOfNewMember NewMemberName ParentForNewMember Formula AppName DBName

sxr esscmd -q msxxaddmdxformmem.scr	%HOST=$SXR_DBHOST %USER=$SXR_USER %PASSWD=$SXR_PASSWORD \
				    %SIB="$1" %ADD="$2" %PARENT="$3" %FORMULA="$4" %APP=$5 %DB=$6
}


# Rename a member
rename_mem ()
{
# OriginalMemberName NewMemberName AppName DBName

sxr esscmd -q msxxrenamemem.scr %HOST=$SXR_DBHOST %USER=$SXR_USER %PASSWD=$SXR_PASSWORD \
                                %FIND="$1" %NEWMEM="$2" %APP=$3 %DB=$4
}

# Move a member
move_mem ()
{
# MemberToBeMoved NewParentForMember NewSiblingForMember AppName DBName

sxr esscmd -q msxxmovemem.scr   %HOST=$SXR_DBHOST %USER=$SXR_USER %PASSWD=$SXR_PASSWORD \
                                %FINDA="$1" %FINDB="$2" %FINDN="$3" %APP=$4 %DB=$5
}


# Delete a member
delete_mem ()
{
# MemberToDelete AppName DBName

sxr esscmd -q msxxdelmem.scr    %HOST=$SXR_DBHOST %USER=$SXR_USER %PASSWD=$SXR_PASSWORD \
                                %FIND="$1" %APP=$2 %DB=$3
}


# Add member formula
addformula()
{
# AppName DBName Loc Member Formula
sxr esscmd -q msxxaddmdxform.scr %HOST=${SXR_DBHOST} %UID=${SXR_USER} %PWD=${SXR_PASSWORD} \
				    %APP="$1" %DB="$2" %MBR="$3" %FORMULA="$4"
}


# Add member formula from file
addformulafromfile()
{
# AppName DBName Loc Member FormulaFile
sxr esscmd -q msxxaddmdxformfromfile.scr %HOST=${SXR_DBHOST} %UID=${SXR_USER} \
		%PWD=${SXR_PASSWORD} %APP=$1 %DB=$2 %MBR=$3 %FORMULAFILE=`sxr which -data $4`
}


# Restruct outline
restruct_otl()
{
# AppName DBName
sxr esscmd -q msxxrest.scr      %HOST=${SXR_DBHOST} %UID=${SXR_USER} \
                                %PWD=${SXR_PASSWORD} %APP=$1 %DB=$2
}


# Get Member Info
get_member_info ()
{
# AppName DBName OutputFileName MemberName

sxr esscmd msxxgetmbri.scr	%HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD \
		    		%APP=$1 %DB=$2 %OFILE=$3 %MBR="$4"
}


# Change Dense/Sparse Config
config_set ()
{
# DimensionName NewCofigurationForDim AppName DBName

sxr esscmd -q msxxdensesparseconf.scr	%HOST=$SXR_DBHOST %USER=$SXR_USER %PASSWD=$SXR_PASSWORD \
                                	%FIND="$1" %CONF="$2" %APP=$3 %DB=$4
}


############################################################################
# Report scripts

# Run report
run_report()
{
sxr esscmd msxxrunrept.scr %HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD \
			    %APP=$1 %DB=$2 %REP=`sxr which -rep $3` %OUTPUT="$4"
}


# Run MDX report
run_mdx()
{
# AppName DBName MDXReport Format MDXOutput [MDXLog]
_mdxlog=$6
if [ -z "$_mdxlog" ]; then
    _mdxlog=$SXR_NULLDEV
fi
sxr esscmd -q msxxrunmdxrept.scr %HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD \
				 %APP=$1 %DB=$2 %MDXREP=`sxr which -rep $3` %FORMAT=$4 \
				 %MDXOUT=$5 %MDXLOG=$_mdxlog
}


############################################################################
# Trigger scripts

# Create trigger
create_trigger()
{
# AppName DBName TriggerFile OutputFile
sxr esscmd -q msxxcretrigger.scr %HOST=${SXR_DBHOST} %UID=${SXR_USER} %PWD=${SXR_PASSWORD} \
				 %APP=$1 %DB=$2 %IFILE=`sxr which -rep $3` %OFILE=$4
}


# Create trigger - using qmdxtrigger command
create_trigger_ex()
{
# AppName DBName TriggerStatement OutputFile
sxr esscmd -q msxxqmdxtrigger.scr %HOST=${SXR_DBHOST} %UID=${SXR_USER} %PWD=${SXR_PASSWORD} \
				 %APP=$1 %DB=$2 %TRGSTMT="$3" %OFILE=$4
}


# Drop trigger
drop_trigger()
{
# AppName DBName TriggerName
sxr msh msxxdroptrigger.msh $SXR_USER $SXR_PASSWORD $SXR_DBHOST $1 $2 $3
}


# Copy trigger spool file to work
gettrgsplfile()
{
# ApplicationName DatabaseName SourceSpoolFileName DestinationSpoolFileName
sxr esscmd -q msxxgettrgsplfile.scr %HOST=$SXR_DBHOST %USER=$SXR_USER %PASSWD=$SXR_PASSWORD \
				   %APP=$1 %DB=$2 %SRCTRGFILE=$3 %DESTTRGFILE=$4
}


# Delete a specific trigger spool file
delete_spool_file ()
{
# ApplicationName DatabaseName SpoolFileName
sxr esscmd -q msxxdeltrgsplfile.scr %HOST=$SXR_DBHOST %USER=$SXR_USER %PASSWD=$SXR_PASSWORD \
				    %APP=$1 %DB=$2 %TRGSPLFILE=$3
}


# Delete all trigger spool files
delete_all_spool_files ()
{
# ApplicationName DatabaseName
sxr esscmd -q msxxdelalltrgsplfiles.scr %HOST=$SXR_DBHOST %USER=$SXR_USER \
					%PASSWD=$SXR_PASSWORD %APP=$1 %DB=$2
}


# Display triggers
display_trigger ()
{
# ApplicationName DatabaseName TriggerName OutputFile
sxr esscmd -q msxxqdisplaytrigger.scr %HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD \
				    %APP=$1 %DB=$2 %TRGNAME=$3 %OFILE=$4
}


# List spool files
list_spool_files ()
{
# ApplicationName DatabaseName OutputFile
sxr esscmd -q msxxqlistspoolfiles.scr %HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD \
				    %APP=$1 %DB=$2 %OFILE=$3
}


############################################################################
# Miscellaneous scripts

create_loc_alias ()
{
sxr esscmd dmcccloc.scr %HOST=$SXR_DBHOST %APP_Target=$1 %DB_Target=$2 %ALIAS=$3 \
			%THOST=$4 %APP=$5 %DB=$6 %USER=$SXR_USER %PASSWORD=$SXR_PASSWORD
}


############################################################################
# System scripts
# Get OPG Stats
opgstat_get()
{
#AppName OutputFileName
sxr esscmd msxxgetopgstats.scr %HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD \
                                %APP=$1 %OFILE=$2
}

# Get OS
get_os()
{
# OutputFile
sxr esscmd -q msxxgetosres.scr %HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD \
				%OFILE=$1
}


# Get memory
get_memory()
{
# AppName DBName OutFile
sxr esscmd -q smalgetmem.scr %HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD \
				%APP=$1 %DB=$2 %OUT=$3
}


# Get system config
get_sys_cfg ()
{
# SystemConfigFile
sxr esscmd -q msxxgetsyscfg.scr  %HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD \
				    %OFILE=$1
# Exiting test if failed to get the system config
if [ $? -ne 0 -o ! -f "$SXR_WORK/system.cfg" ]; then
    errcode=$?
    echo "!!!FAILURE!!! Failed to get the system config. Please make sure that essbase server is running!" | tee -a "Failure.$$.dif"
    exit $errcode
fi
}


# Return $ARBORPATH of the $SXR_DBHOST
get_dbhost_arborpath ()
{
    if [ ! -f "$SXR_WORK/system.cfg" ]; then
	get_sys_cfg "system.cfg" > /dev/null 2>&1
    fi

    if [ -f "$SXR_WORK/system.cfg" ]; then
	grep 'ARBORPATH' "$SXR_WORK/system.cfg" | sed 's/^Environment.*ARBORPATH.* = //'
    fi
}


# Return ostype of the $SXR_DBHOST
get_dbhost_os ()
{
    if [ -z "$DBHOST_ARBORPATH" ]; then
	export DBHOST_ARBORPATH=$(get_dbhost_arborpath)
    fi
    if [ "${DBHOST_ARBORPATH#/}" != "${DBHOST_ARBORPATH}" ]; then
	echo "unix"
    else
	echo "nti"
    fi
}


############################################################################
# API supports

run_make ()
{
    # Use Gmake on UNIX and nmake on NT to support macro in common.mak
    _make="Gmake"
    if [ "$SXR_PLATFORM" = "nti" ]; then
	_make="nmake"
    fi
    $_make -f $1
}


############################################################################
# Other functions

# Return the original string with first character capitalized
init_cap ()
{
# String
    _firstchar=`echo $1 | cut -c 1 | tr [a-z] [A-Z]`
    _remain=`echo ${1#${_firstchar}}`
    echo $_firstchar$_remain
}


# Create an application name from the input string with the specified len
create_app_name ()
{
# String Len
    LEN=$2
    if [ -z "$LEN" -o "$LEN" -gt 8 ]; then
        LEN=8
    fi

    # Construct app name with init cap
    init_cap `echo $1 | cut -c 1-$LEN`
}


# Search log file for errors
search_log ()
{
# LogFile OutputFile Error1 [Error2 ...]
# Error = Invalid file | recovering | xcp ...
    _logfile=$1; shift
    _outfile=$1; shift

    while [ -n "$1" ]
    do
	grep -i "$1" $_logfile >> $_outfile
	shift
    done
}


# Convert unix file to handle exponential values
# For example: NT displays the value 1200000 as 1.2e+006
#		      while UNIX displays it as 1.2e+06
convert_exp ()
{
    if [ "$(get_dbhost_os)" != "nti" ]; then
	mv ${1} ${1}.tmp
	sed -e 's/\([eE]\)\([+-]\)\([0-9][0-9]\)/\1\20\3/g' ${1}.tmp > ${1}
	rm ${1}.tmp
    fi
}


# Generic diff files against 2 base lines
# Assume we have 2 base lines to compare
# 1) Main base line: dxmdprpd9_000000.csv
# 2) Platform/mode specific base line: dxmdprpdaso9_000000.csv
# And both base line names follow this pattern: ${PREFIX}${INDEX}${SUFFIX}.${EXT}
# For example:
#   Main base line:   PREFIX=dxmdprpd, INDEX=9, SUFFIX=_000000, EXT=csv
#   ASO specific base line: PREFIX=dxmdprpdaso, INDEX=9, SUFFIX=_000000, EXT=csv
#
# When this function is called with these parameters
#    diff_files [-ignore "pattern"] Prefix SpecPrefix Index Suffix Ext
# it will perform diff as follows
#
# if base line ${SpecPrefix}${Index}${Suffix}.${Ext} exists
#    sxr diff ${Prefix}${Index}${Suffix}.${Ext} ${SpecPrefix}${Index}${Suffix}.${Ext}
# elif base line ${SpecPrefix}${Index}${Suffix}.bas exists
#    sxr diff ${Prefix}${Index}${Suffix}.${Ext} ${SpecPrefix}${Index}${Suffix}.bas
# elif base line ${Prefix}${Index}${Suffix}.${Ext} exists
#    sxr diff ${Prefix}${Index}${Suffix}.${Ext} ${Prefix}${Index}${Suffix}.${Ext}
# else
#    sxr diff ${Prefix}${Index}${Suffix}.${Ext} ${Prefix}${Index}${Suffix}.bas
#
diff_files ()
{
    # [-ignore pattern] Prefix SpecPrefix Index Suffix Ext
    _ignore=""
    while [ "${1#-}" != "${1}" ]; do
	_ignore="${_ignore} ${1} \"${2}\""; shift 2
    done

    # $1=Prefix $2=SpecPrefix $3=Index $4=Suffix $5=Ext

    if [ -f "`sxr which -log \"${2}${3}${4}.${5}\"`" ]; then
	eval "sxr diff ${_ignore} \"${1}${3}${4}.${5}\" \"${2}${3}${4}.${5}\""
    elif [ -f "`sxr which -log \"${2}${3}${4}.bas\"`" ]; then
	eval "sxr diff ${_ignore} \"${1}${3}${4}.${5}\" \"${2}${3}${4}.bas\""
    elif [ -f "`sxr which -log \"${1}${3}${4}.${5}\"`" ]; then
	eval "sxr diff ${_ignore} \"${1}${3}${4}.${5}\""
    else
	eval "sxr diff ${_ignore} \"${1}${3}${4}.${5}\" \"${1}${3}${4}.bas\""
    fi

    # Print result
    diff_result "${1}${3}${4}"
}


# Diff files type "ntv"
diff_ntv ()
{
    _ignore=""
    while [ "${1#-}" != "${1}" ]; do
	_ignore="${_ignore} ${1} \"${2}\""; shift 2
    done

    if [ -f "${SXR_WORK}/${1}${3}${4}.ntv" ]; then
	diff_files ${_ignore} "${1}" "${2}" "${3}" "${4}" "ntv"
    else
	echo "Query ${1}${3}${4} is an error condition"
    fi
}


# Diff files type "csv"
diff_csv ()
{
    _ignore=""
    while [ "${1#-}" != "${1}" ]; do
	_ignore="${_ignore} ${1} \"${2}\""; shift 2
    done

    if [ -f "${SXR_WORK}/${1}${3}${4}_000000.csv" ]; then
	for f in ${SXR_WORK}/${1}${3}${4}_*.csv
	do
	    _fname=`basename $f .csv`
	    _end=`echo ${_fname} | sed 's/.*_/_/'`
	    convert_exp ${_fname}.csv

	    # Compare files
	    diff_files ${_ignore} "${1}" "${2}" "${3}" "${4}${_end}" "csv"
	done
    else
	echo "Query ${1}${3}${4} is an error condition"
    fi

}


# Print result
diff_result()
{
    if [ -f ${1}.dif ]; then
        echo "Failed to compare ${1}"
    else
        echo "Succeeded to compare ${1}"
    fi
}


# Display tablespace in platform independent
# Equivalent to msxxfixestbsp.sh
fix_tbsp ()
{
    # Use egrep to support -e option
    egrep -i -e ' [a-zA-Z]:[/\]' -e ' /.*' $1 | sed -e 's/\\/\//g' -e 's/\/app\//\/APP\//g' \
	    -e 's/^ .*\/APP\//MY_ESSBASE\/APP\//g' | awk '{print $1":"$2":"$3}' > tmp.$$
    mv tmp.$$ $1
}



Maxl.func

############################################################################
#
# File: maxl.func
# Purpose: implement functions using new MaxL scripts. Some of functions
#          found in this module will overwrite any same-name functions
#          defined in the based esscmd.func module and some will support
#          both DSO and ASO application modes.
#
#   if ${SXR_MODE} is undefined or is "ASO" ==> call ASO functions (* default)
#   if ${SXR_MODE} is "DSO"                 ==> call DSO functions
#
#
# Date created: 01/07/2004
#
# Modifications:
# 6/1/04 by jsalmon - add get stats for ASO applications and databases
# 4/9/04 by jsalmon - added create buffer function.
# 08/23/04 by nnguyen - reimplemented exiting tests based on returned error code
#
#
#
# NOTE!! This module only contains functions using MaxL scripts. If you need
#        add new ESSCMD based functions or other support functions, please add
#        it to esscmd.func.
#
############################################################################

FUNCMOD=`sxr which -sh maxl.func`
echo "Loading ${FUNCMOD} module..."


############################################################################
# Copy a File - see based esscmd.func




############################################################################
# Server Essbase.cfg Manipulation - see based esscmd.func




############################################################################
# Application and Database Manipulation

# Create a new app - Overwrite
create_app ()
{
if [ -z "$SXR_MODE" -o "$SXR_MODE" = "aso" ]; then
    # AppName
    sxr msh msxxcreasoapp.msh $SXR_USER $SXR_PASSWORD $SXR_DBHOST $(init_cap $1)
else # DSO mode
    sxr newapp -force $1
fi
if [ $? -ne 0 ]; then
    errcode=$?
    echo "!!!FAILURE!!! Failed to create app [$1]!" | tee -a "Failure.$$.dif"
    exit $errcode
fi
}


# Create a new db - Overwrite
create_db ()
{
if [ -z "$SXR_MODE" -o "$SXR_MODE" = "aso" ]; then
    # [OutlineName] AppName DBName
    if [ $# -eq 2 ]; then
	sxr msh msxxcredb.msh $SXR_USER $SXR_PASSWORD $SXR_DBHOST $1 $(init_cap $2)
    else # Force to use DSO mode when creating DB with Outline
	sxr newdb -otl $1 $2 $3
    fi
else # DSO mode
    # [OutlineName] AppName DBName
    if [ $# -eq 2 ]; then
	sxr newdb $1 $2
    else
	sxr newdb -otl $1 $2 $3
    fi
fi
if [ $? -ne 0 ]; then
    errcode=$?
    if [ $# -eq 2 ]; then
	echo "!!!FAILURE!!! Failed to create db [$1.$2]!" | tee -a "Failure.$$.dif"
    else
	echo "!!!FAILURE!!! Failed to create app [$2.$3]!" | tee -a "Failure.$$.dif"
    fi
    exit $errcode
fi
}


# Delete application - Overwrite
delete_app ()
{
# AppName
sxr msh msxxdropapp.msh $SXR_USER $SXR_PASSWORD $SXR_DBHOST $1
}


# Delete database - Overwrite
delete_db()
{
# AppName DBName
sxr msh msxxdropdb.msh ${SXR_USER} ${SXR_PASSWORD} ${SXR_DBHOST} ${1} ${2}
}


# Copy application - Overwrite
copy_app()
{
# AppName NewAppName
sxr msh msxxcopyasoapp.msh ${SXR_USER} ${SXR_PASSWORD} ${SXR_DBHOST} ${2} ${1}
}


# Rename application - Overwrite
rename_app()
{
# AppName NewAppName
sxr msh msxxalterapp.msh "rename_application" ${SXR_USER} ${SXR_PASSWORD} ${SXR_DBHOST} ${1} ${2}
}


# Rename database - Overwrite
rename_db()
{
# AppName DBName NewDBName
sxr msh msxxalterdb.msh "rename_database" ${SXR_USER} ${SXR_PASSWORD} ${SXR_DBHOST} ${1} ${2} ${3}
}


# Export data - Overwrite (Compatible ???)
export_data ()
{
# AppName DBName [ReportScript] OutData
if [ -z "$4" ]; then
    OPT="export_data"
    sxr msh msxxexportdata.msh $OPT $SXR_USER $SXR_PASSWORD $SXR_DBHOST $1 $2 $3
else
    OPT="report_script"
    sxr msh msxxexportdata.msh $OPT $SXR_USER $SXR_PASSWORD $SXR_DBHOST $1 $2 `sxr which -rep $3` $4
fi
}


# Reset/clear data - Overwrite
reset_db ()
{
# AppName DBName [ResetOpt]
_opt=$3
if [ -z "$_opt" ]; then
    _opt="all_data"
fi
sxr msh msxxresetdb.msh	$_opt $SXR_USER $SXR_PASSWORD $SXR_DBHOST $1 $2 $3
}


# Alter file location - New
file_location()
{
# ASO mode only
# Opt AppName DBName FileLoc
# Where Opt = add_file_location | alter_file_location | drop_file_location
sxr msh msxxfilelocation.msh $1 $SXR_USER $SXR_PASSWORD $SXR_DBHOST $2 $3 $4
}


# Set size location - New
set_size_location()
{
# ASO mode only
# Opt AppName DBName FileLoc Size
# Where Opt = add_set_file_size | add_set_disk_size | alter_set_file_size | alter_set_disk_size
sxr msh msxxsetsizeonly.msh $1 $SXR_USER $SXR_PASSWORD $SXR_DBHOST $2 $3 $4 $5
}


# Set file and disk file location - New
set_file_disk_file_location()
{
# ASO mode only
# Opt AppName DBName FileLoc MaxFileSize MaxDiskSize
# Where Opt = add_set_file_disk_size | add_set_disk_file_size \
#		alter_set_file_disk_size | alter_set_disk_file_size
sxr msh msxxsetfdsize.msh $1 $SXR_USER $SXR_PASSWORD $SXR_DBHOST $2 $3 $4 $5 $6
}


# Display tablespace - New
display_tbsp()
{
# ASO mode only
# OutFile AppName DBName TablespaceName
sxr msh msxxdisplaytbsp.msh $SXR_USER $SXR_PASSWORD $SXR_DBHOST $1 $2 $3 $4
}

# Get App/db statistics - New
get_stats()
{
#TypeOfStats OutputFileName ApplicationName [dbName]
if [ -z "$4" ]
then
sxr msh msxxgetasostats.msh $1 $SXR_USER $SXR_PASSWORD $SXR_DBHOST $2 $3
else
sxr msh msxxgetasostats.msh $1 $SXR_USER $SXR_PASSWORD $SXR_DBHOST $2 $3 $4
fi
}


# Set retrieve buffer size - New
set_retrieve_buffer_size()
{
# ASO mode only
# AppName DBName NewBufferSize
sxr msh msxxsetretrievebuffersize.msh $SXR_USER $SXR_PASSWORD $SXR_DBHOST $1 $2 $3
}


############################################################################
# View manipulation

# Execute view - New
execute_view_process()
{
# ASO mode only
# AppName DBName
sxr msh msxxexeallagg.msh $SXR_USER $SXR_PASSWORD $SXR_DBHOST $1 $2
}


# Build view - New
execute_build_view()
{
# ASO mode only
# AppName DBName ViewID ViewSize OutLineID
sxr msh msxxexeaggbltview.msh $SXR_USER $SXR_PASSWORD $SXR_DBHOST $1 $2 $3 $4 $5
}

execute_aggregate_db()
{
# Opt AppName DbName Criteria_size
# where Opt = [built_all|build_stop|build_each]
sxr msh msxxaggbltopt.msh $1 $SXR_USER $SXR_PASSWORD $SXR_DBHOST $2 $3 $4 $5 $6
}


# Select view - New
execute_select_view()
{
# ASO mode only
# AppName DBName NumViews OutFile
sxr msh msxxexeaggselview.msh $SXR_USER $SXR_PASSWORD $SXR_DBHOST $4 $1 $2 $3
}


# List view - New
list_agg_view()
{
# ASO mode only
# AppName DBName OutFile
sxr msh msxxlistaggview.msh $SXR_USER $SXR_PASSWORD $SXR_DBHOST $3 $1 $2
}


# Clear view - New
clear_agg_view()
{
# ASO mode only
# AppName DBName
sxr msh msxxclearaggview.msh $SXR_USER $SXR_PASSWORD $SXR_DBHOST $1 $2
}


# get outlineID for aggregating view - new
get_outline_id()
{
# ASO mode only
# Appname Dbname OutFile
sxr msh msxxgetotlid.msh $SXR_USER $SXR_PASSWORD $SXR_DBHOST $3 $1 $2
}


####################################
# New Cromwell Features

# Enable/Disable query tracking - New
enable_query ()
{
# ASO mode only
# Appname Dbname
sxr msh msxxenablequery.msh $SXR_USER $SXR_PASSWORD $SXR_DBHOST $1 $2
}


disable_query ()
{
# ASO mode only
# Appname Dbname
sxr msh msxxdisablequery.msh $SXR_USER $SXR_PASSWORD $SXR_DBHOST $1 $2
}


# Select views based on query data - New
select_query_data_views ()
{
# ASO mode only
# Appname Dbname OutFile
sxr msh msxxselquerydataviews.msh $SXR_USER $SXR_PASSWORD $SXR_DBHOST $1 $2 $3
}


############################################################################
# Load Data

# Load Data - Overwrite
load_data ()
{
if [ -z "$SXR_MODE" -o "$SXR_MODE" = "aso" ]; then
    # AppName DBName DataFile [RuleFile]
    _opt="no_rule_file"
    if [ -n "$4" ]; then
	_opt="with_rule_file"
    fi
    sxr msh msxxloaddata.msh $_opt $SXR_USER $SXR_PASSWORD $SXR_DBHOST $1 $2 \
				`sxr which -data $3` `sxr which -data $4`
else # DSO mode
    # AppName DBName DataFile [LoadOpt]
    # Where LoadOpt = 3 (local - default) | 2 (server)
    _scriptname="msxxloaddata.scr"
    if [ "$4" -eq 2 ]; then
	_scriptname="msxxloaddataserver.scr"
    fi
    sxr esscmd ${_scriptname}   %HOST=$SXR_DBHOST %USER=$SXR_USER %PASSWD=$SXR_PASSWORD \
			       %APPNAME=$1 %DBNAME=$2 %LOADDATA=`sxr which -data $3`
fi
if [ $? -ne 0 ]; then
    errcode=$?
    echo "!!!FAILURE!!! Failed to load data [$3]!" | tee -a "Failure.$$.dif"
    exit $errcode
fi
}

# Create Data Buffer - New
create_buffer()
{
#ApplicatonName DBName BufferID
           sxr msh msxxcreldbuff.msh $SXR_USER $SXR_PASSWORD $SXR_DBHOST $1 $2 $3
}

# Load data from buffer - New
#   used to load data from buffer to database
load_data_from_buffer ()
{
# LoadOpt AppName DBName BufferID
# Where LoadOpt = default | add_to | sub_from | overwrite | end
sxr msh msxxcommtodb.msh $1 $SXR_USER $SXR_PASSWORD $SXR_DBHOST $2 $3 $4
}


# Load data to buffer - New
#   used to load data from file to buffer
load_data_to_buffer ()
{
# LoadOpt AppName DBName BufferID [DataFile ErrorFile] \
#                                 [DataFile ErrorFile RuleFile [DBUser DBPwd OutFile]]
# Where LoadOpt = com_to_db | no_rule_file | no_rule_file_ex | with_rule_file | with_serv_rule \
#                 with_serv_rule_ex | frm_sql
case "$1" in
com_to_db)
    # LoadOpt AppName DBName BufferID
    sxr msh msxxlddatawbuff.msh $1 $SXR_USER $SXR_PASSWORD $SXR_DBHOST $2 $3 "" "" $4
    ;;
no_rule_file|no_rule_file_ex)
    # LoadOpt AppName DBName BufferID DataFile ErrorFile
    sxr msh msxxlddatawbuff.msh $1 $SXR_USER $SXR_PASSWORD $SXR_DBHOST $2 $3 $5 $6 $4
    ;;
with_rule_file|with_serv_rule|with_serv_rule_ex)
    # LoadOpt AppName DBName BufferID DataFile ErrorFile RuleFile
    sxr msh msxxlddatawbuff.msh $1 $SXR_USER $SXR_PASSWORD $SXR_DBHOST $2 $3 $5 $7 $4 $6
    ;;
frm_sql)
    # LoadOpt AppName DBName BufferID DataFile ErrorFile RuleFile DBUser DBPwd OutFile
    sxr msh msxxlddatawbuff.msh $1 $SXR_USER $SXR_PASSWORD $SXR_DBHOST $10 $2 $3 $8 $9 $7 $4 $6
    ;;
esac
}


#import Dimensions
#used to build outline
import_dim()
{
#Appname DBName Datafile RulesFile ErrorFile
sxr msh msxximportdim.msh $SXR_USER $SXR_PASSWORD $SXR_DBHOST $1 $2 $3 $4 $5
}
############################################################################
# Run Calc

# Run Default Calc - Overwrite
runcalc_default ()
{
# AppName DBName
run_calc $1 $2
}


# Run Custom Calc - Overwrite
runcalc_custom ()
{
# AppName DBName CalcScript
run_calc $1 $2 $3
}


# Run Calc - New
run_calc ()
{
if [ -z "$SXR_MODE" -o "$SXR_MODE" = "aso" ]; then
    execute_view_process $1 $2
else # DSO mode
    # AppName DBName [CalcScript]
    _opt="default"
    if [ -n "$3" ]; then
	_opt="calc_script"
    fi
    sxr msh msxxexecalc.msh $_opt $SXR_USER $SXR_PASSWORD $SXR_DBHOST $1 $2 `sxr which -csc $3`
fi
}



############################################################################
# Partition Manipulation - see based esscmd.func




############################################################################
# Spreadsheet Requests - see based esscmd.func




############################################################################
# User Manipulation - see based esscmd.func

grant_app_access ()
{
# AccessLevel AppName UserName
sxr msh msxxgrantappaccess.msh   $SXR_USER $SXR_PASSWORD $SXR_DBHOST "$1" "$2" "$3"
}


grant_db_access ()
{
# AccessLevel AppName UserName
sxr msh msxxgrant_dbaccess.msh   $SXR_USER $SXR_PASSWORD $SXR_DBHOST "$1" "$2" "$3" "$4"
}


############################################################################
# Filter Manipulation

# Grant filter access to user
grant_filter ()
{
# AppName DBName FilterName UserName
sxr msh msxxgrant_filter.msh    $SXR_USER $SXR_PASSWORD $SXR_DBHOST "$1" "$2" "$3" "$4"
}



############################################################################
# LRO's - see based esscmd.func




############################################################################
# Outline Manipulation - see based esscmd.func




############################################################################
# Report scripts - see based esscmd.func

# Run report - Overwrite
run_report()
{
if [ -z "$SXR_MODE" -o "$SXR_MODE" = "aso" ]; then
    # AppName DBName ReportScript OutData
    export_data $1 $2 $3 $4
else # DSO mode
    sxr esscmd msxxrunrept.scr %HOST=${SXR_DBHOST} %UID=${SXR_USER} %PWD=${SXR_PASSWORD} \
				%APP=${1} %DB=${2} %REP=`sxr which -rep ${3}` %OUTPUT="${4}"
fi
}




############################################################################
# Miscellaneous scripts - see based esscmd.func




############################################################################
# Other functions  - see based esscmd.func


Css.func

############################################################################
#
# File: css.func
# Purpose: create a collection of common CSS functions used in essbase.
#
# Date created: 01/10/2005
#
# Modifications:
#
# 01/10/05 by nnguyen - initial version (not compatible with pre-cromwell release structure)
#
############################################################################

FUNCMOD=`sxr which -sh css.func`
echo "Loading ${FUNCMOD} module..."

# Default error code
export errcode=0

############################################################################
# Retrieve JVM, CSS version from the setting environment

_jvm_nti="bin/server/jvm.dll"
_jvm_solaris="lib/sparc/server/libjvm.so"
_jvm_aix="bin/classic/libjvm.a"
_jvm_linux="lib/i386/server/libjvm.so"
if [ "`uname -m`" = "ia64" ]; then
    _jvm_hpux="lib/IA64W/server/libjvm.so"
else
    _jvm_hpux="lib/PA_RISC2.0/server/libjvm.sl"
fi

_my_jvm=`eval echo \\${_jvm_\${SXR_PLATFORM}}`
_jvm_path=`find ${HYPERION_HOME}/common -name ${_my_jvm##*/} | grep ${_my_jvm} | tail -1`
_java_home=`echo ${_jvm_path%/${_my_jvm}}`
_java_base=`echo ${_java_home%/*}`
_sep=":"
if [ "${SXR_PLATFORM}" = "nti" ]; then _sep=";"; fi


############################################################################
#

#
# Set _java_home based on input _jvm_ver (overwrite the default _java_home).
#
set_java_home ()
# [_jvm_ver]
{
    if [ -n "$1" ]; then
	_java_home="${_java_base}/$1"
    fi
}

#
# Return the default _java_home found from the environment.
#
get_java_home ()
{
    echo "${_java_home}"
}

#
# Return the default _java_home found from the environment.
#
get_jvm ()
{
    echo "${_jvm_path}"
}

get_classpath ()
{
_css_jar=`find ${HYPERION_HOME}/common/CSS -name "*.jar" | tail -1`
_log_jar=`find ${HYPERION_HOME}/common/loggers -name "*.jar" | tail -1`
_dom_jar=`find ${HYPERION_HOME}/common/XML -name "dom.jar" | tail -1`
_jaxp_jar=`find ${HYPERION_HOME}/common/XML -name "jaxp-api.jar" | tail -1`
_jdom_jar=`find ${HYPERION_HOME}/common/XML -name "jdom.jar" | tail -1`
_sax_jar=`find ${HYPERION_HOME}/common/XML -name "sax.jar" | tail -1`
_xalan_jar=`find ${HYPERION_HOME}/common/XML -name "xalan.jar" | tail -1`
_xercesImpl_jar=`find ${HYPERION_HOME}/common/XML -name "xercesImpl.jar" | tail -1`

_java_classpath=".${_sep}${_css_jar}${_sep}${_log_jar}${_sep}${_dom_jar}${_sep}${_jaxp_jar}${_sep}${_jdom_jar}${_sep}${_sax_jar}${_sep}${_xalan_jar}${_sep}${_xercesImpl_jar}"
echo "${_java_classpath}"
}

get_agent_port ()
{
    _agentport=""
    touch "$1"
    _tmp=`grep -i agentport $1 | tail -1`
    if [ "${_tmp#;}" = "${_tmp}" ]; then
	_agentport=`echo ${_tmp} | awk '{ print $2 }'`
    fi
    echo "${_agentport}"
}

create_config ()
{
echo "JvmModuleLocation $1" > "${ARBORPATH}/bin/essbase.cfg"
if [ "${SXR_PLATFORM}" = "nti" ]; then
    echo "AuthenticationModule CSS file://localhost/$2" >> "${ARBORPATH}/bin/essbase.cfg"
else
    echo "AuthenticationModule CSS file://localhost$2" >> "${ARBORPATH}/bin/essbase.cfg"
fi
if [ -n "$3" ]; then
    echo "EssbaseLicenseServer $3" >> "${ARBORPATH}/bin/essbase.cfg"
    echo "AnalyticServerId 1" >> "${ARBORPATH}/bin/essbase.cfg"
fi
if [ -n "$4" ]; then
    echo "AgentPort $4" >> "${ARBORPATH}/bin/essbase.cfg"
fi
}

start_essbase ()
{
    # Construct PATH and library path for specific platform
    export PATH=".${_sep}${ARBORPATH}/bin${_sep}${PATH}"

    if [ "${SXR_PLATFORM}" = "solaris" ]; then
	export LD_LIBRARY_PATH="${_jvm_home}/lib/sparc/server${_sep}${_jvm_home}/lib/sparc${_sep}${ARBORPATH}/bin${_sep}${HYPERION_HOME}/common/ODBC/Merant/4.2/lib${_sep}/usr/lib${_sep}${LD_LIBRARY_PATH}"
    elif [ "${SXR_PLATFORM}" = "aix" ]; then
	export LIBPATH="${_jvm_home}/bin/classic${_sep}${_jvm_home}/bin${_sep}${ARBORPATH}/bin${_sep}${HYPERION_HOME}/common/ODBC/Merant/4.2/lib${_sep}/usr/lib${_sep}${LIBPATH}"
    elif [ "${SXR_PLATFORM}" = "linux" ]; then
	export LD_LIBRARY_PATH="${_jvm_home}/lib/i386/server${_sep}${_jvm_home}/lib/i386${_sep}${ARBORPATH}/bin${_sep}${HYPERION_HOME}/common/ODBC/Merant/4.2/lib${_sep}/usr/lib${_sep}${LD_LIBRARY_PATH}"
    elif [ "${SXR_PLATFORM}" = "nti" ]; then
	export PATH="${_jvm_home}/bin/server${_sep}${_jvm_home}/bin${_sep}${HYPERION_HOME}/common/ODBC/Merant/4.2/lib${_sep}/usr/lib${_sep}${PATH}"
    elif [ "${SXR_PLATFORM}" = "hpux" ]; then
	if [ "`uname -m`" = "ia64" ]; then
	    export SHLIB_PATH="${_jvm_home}/lib/IA64W/server${_sep}${_jvm_home}/lib/IA64W${_sep}${ARBORPATH}/bin${_sep}${HYPERION_HOME}/common/ODBC-IA64/Merant/4.2/lib${_sep}/usr/lib${_sep}${SHLIB_PATH}"
	else
	export SHLIB_PATH="${_jvm_home}/lib/PA_RISC2.0/server${_sep}${_jvm_home}/lib/PA_RISC2.0${_sep}${ARBORPATH}/bin${_sep}${HYPERION_HOME}/common/ODBC/Merant/4.2/lib${_sep}/usr/lib${_sep}${SHLIB_PATH}"
	fi
    fi

    # Need to preload jvm for hpux
    if [ "${SXR_PLATFORM}" = "hpux" ]; then
	export LD_PRELOAD=$(get_jvm)
	${ARBORPATH}/bin/ESSBASE password -b &
	unset LD_PRELOAD
    else
	sxr agtctl start
    fi
}

############################################################################################
# Function: get_token  (combined two Java programs created by Gaurav)
#
# Format:  java CSSAuthenticateForEssbase <username> <password> <xml> > <output>
#
# Excecution format:  get_token $1 $2 $3 $4
# $1: User Name
# $2: Password
# $3: URL_Path
# $4: Token output files (will be needed to be processed to erase the two spaces:
#
# E.g:  get_token azhang password ${ARBORPATH}/bin/sample.xml output
#
# Note:	The token got from the Java program has two End-0f line char, so need call function 2
#         to eliminate the space for the authentication by ESSCMDQ (LoginByToken)
#
############################################################################################

get_token ()
{
    if [ ! -f CSSAuthenticateForEssbase.class ]; then
	sxr fcopy -in -data CSSAuthenticateForEssbase.class
    fi
    if [ ! -f AppContract.class ]; then
	sxr fcopy -in -data AppContract.class
    fi

    # Print out JAVA_HOME and JAVA_CLASSPATH for debuging purpose
    _java_home=$(get_java_home)
    echo "Set JAVA_HOME=${_java_home}"

    _java_classpath=$(get_classpath)
    echo "Set JAVA_CLASSPATH=${_java_classpath}"

    ${_java_home}/bin/java -classpath "${_java_classpath}" CSSAuthenticateForEssbase "$1" "$2" "localhost/$3" > "$4"

    # Remove newline
    _token=""
    while read line
    do
	_token="${_token}${line}"
    done < "$4"
    echo "${_token}" > "$4"
}




Aug. 19 Create concurrent login from stsun8 to azhang1:
1. to change localhost to azhang1
[/vol3/views/az1/login_1000_css_user/sh/Login_Concur_1000_CSS_user_azhang2]
(regraz1@stsun8)> sed 's/localhost/azhang1/' 2-login_1000_css_user_rows >
2-login_1000_css_user_rows_azhang2 (to change localhost to azhang1)

2. split one text file into 1000 scr files
(regraz1@stsun8)> cat split_999_usersFromSingleLine.sh
# This program slip 6290 lines into 3145 files

let i=1
while read line
do
        echo "$line;"     >> 1000_userlogin${i}.scr
        echo "sleep 500;" >> 1000_userlogin${i}.scr
        echo "Logout;"   >> 1000_userlogin${i}.scr
        let i=i+1

echo $i
        echo ""
done < 2-login_1000_css_user_rows_azhang2


Aug. 18
[/vol2/views/azhang/login_1k-10kuser/sh]
(regraz1@sthp10)cat  login_10k_user278.scr

(regraz1@sthp10)cat  login_10k_user278.scr
….

login "localhost" "u2771" "password";
login "localhost" "u2772" "password";
login "localhost" "u2773" "password";
login "localhost" "u2774" "password";
login "localhost" "u2775" "password";
login "localhost" "u2776" "password";
login "localhost" "u2777" "password";
login "localhost" "u2778" "password";
login "localhost" "u2779" "password";
login "localhost" "u2780" "password";
sleep 1000;
logout;
exit;


(regraz1@sthp10)cat concurrentlogin_1000Users.sh
i=1
while (test ${i} -le 100 )
do
     i=`expr ${i} + 1`
 ESSCMD  login_10k_user${i}.scr &
done

(regraz1@sthp10)cat create_10k_userlogin-scr.sh
i=0
while (test ${i} -le 4050)

do
     i=`expr ${i} + 1`
     echo "login \"localhost\" \"u${i}\" \"password\";" > login_10k_user${i}.scr
     echo "sleep 1000;" >> login_10k_user${i}.scr
     echo "logout;"     >> login_10k_user${i}.scr
     echo "exit;"       >> login_10k_user${i}.scr

done


(regraz1@sthp10)cat create_multi_login_user.sh
let j=1
while (test ${j} -le 300)
do
        let i=1
        while (test ${i} -le 10)
        do
                let k=j-1
                let k=k*10
                let k=k+i

        echo "login \"localhost\" \"u${k}\" \"password\";" >> login_10k_user${j}.scr
                let i=i+1
        done
        echo "sleep 1000;" >> login_10k_user${j}.scr
        echo "logout;"     >> login_10k_user${j}.scr
        echo "exit;"       >> login_10k_user${j}.scr
        let j=j+1
done


Mar. 6, 2003 truncate the unwanted info from getdbstats
Hi Guys,

I just created a script that will truncate the unwanted info from getdbstats output such as
clustering ratio
fragmentation ratio
recovery

it is checked in both theta and clearcase (7.0.x.cs)

To use the script:
1. copy this file to work directory of a view
2. call it as (./msxxtruncdbstat.sh filename)
Note: the filename that you pass in is the filename that it returns

Christina, you can forward this info to Teresa group if you want too

thanks
baon


Jan.24, 2003 Run script at backgroung – Christina
This will run agtpjlmain.sh every Wednesday at 9:

start.sh
cd /vol1/regrcl1/views
sxr goview -ws test
at -f /vol3/views/start.sh 9 am Wednesday

example of what is written to the .sxrrc
export SXR_GOVIEW_TRIGGER='sxr sh agtpjlmain.sh parallel direct'

This will run it in the background

sxr sh agtpjlmain.sh &

or

nohup sxr sh agtpjlmain.sh &

loop
Example 1:
Dmpcformb.sh
i=1
while :

do
        touch loop$i
        sxr sh dmpcformb.sh
        mkdir $SXR_VIEWHOME/work/DifDir$i
        mv $SXR_VIEWHOME/work/*dif $SXR_VIEWHOME/work/DifDir$i
          touch loop$i
        i=`expr ${i} + 1`
done

or:
let i=1
while (test $i -le 5)

do
        touch loop$i
        echo loop$i
        sleep 1
        mkdir DifDir$i

        let i=i+1
done


Example 2:
LoopCreateFilters.sh:
HOST=${SXR_DBHOST}
UID=${SXR_USER}
PWD=${SXR_PASSWORD}
WORK=${SXR_WORK}
VIEW=${SXR_VIEWHOME}

# It's extected to fail for last two filters creation
i=1
while ( test ${i} -le 479 )
do
        sxr esscmd -q   agsycreatefilter.scr %HOST=$HOST %UID=$UID %PWD=$PWD \
                        %APP=$APP02 %DB=$DB01 \
                        %filter=filter${i}
        i=`expr ${i} + 1`
done

#
#  Cleanup
sxr esscmd msxxrmap.scr %HOST=$HOST %USER=$SXR_USER %PASSWD=$SXR_PASSWORD \
                        %APP=$APP01

sxr esscmd msxxrmap.scr %HOST=$HOST %USER=$SXR_USER %PASSWD=$SXR_PASSWORD \
                        %APP=$APP02

agsycreatefilter.scr
login "%HOST" "%UID" "%PWD";

createfilter "%APP" "%DB" "%filter" "1" "Jan" "2";
logout;
exit;

Example 3:
if [ $# -eq 0 ]
then
    echo "YOU'RE RUNNING 2HRS TEST"
	sxr sh agtaimain01.sh
	#sxr sh agtaimain02.sh
	#sxr sh agtaiother.sh
else
    echo "YOU'RE RUNNING FOREVER TEST"
    while :
    do
	sxr sh agtaimain01.sh
##	sxr sh agtaimain02.sh
	#sxr sh agtaiother.sh
    done
fi

Example 4:

i=0
while ( test ${i} -lt 10 )
do
   i=`expr ${i} + 1`
   echo $# >> agtaiarchive.out
done

cat agtaiarchive.out
$ cat agtaiarchive.out
0
0
0
0
0
0
0
0
0
0


Chose different platforms Different server
CL’s dmududf.sh
I modified dmududf62.sh test so that it can be run on any Unix platform (with the exception of LINUX) from any user login,  as long as a supported jdk is installed in the default locations.  It's no longer necessary to use 3_00, login as regjava, run environment scripts, or set the jvmmodule.
This is only applies to Solaris, HP, and AIX.  NT and Linux will still require manual environment setup before running the test.
The machines I used to test the change are staix1, sthp02, sthp10, stsun9.
Hopefully, this will make running this test easier.



uname > dmudbox.out
BOX=`cat $SXR_WORK/dmudbox.out`

echo $BOX
if [ $BOX = Windows_NT ]
then
echo "Set up your environment"
elif [ $BOX = HP-UX ]
then
export JAVA_HOME=/opt/java1.2
export CLASSPATH=$ARBORPATH/java/parser.jar:$ARBORPATH/java/jaxp.jar
export PATH=/usr/lib:$JAVA_HOME/jre/bin:$ARBORPATH/java:$JAVA_HOME/jre/lib/PA_RISC/classic:$PATH:
export ESS_JVM_OPTION1="-Djava.compiler=NONE"
export SHLIB_PATH=/usr/lib:$JAVA_HOME/jre/lib/PA_RISC:$JAVA_HOME/jre/lib/PA_RISC/classic:$ARBORPATH/dlls$SHLIB_PATH
sxr sh dmudhpsetup.sh
elif [ $BOX = SunOS ]
then
sxr sh dmudsunsetup.sh
elif [ $BOX = AIX ]
then
sxr sh dmudaixsetup.sh
export JAVA_HOME=/usr/java_dev2
export PATH=$JAVA_HOME/jre:/usr/java_dev2/jre/bin:/usr/java_dev2/jre/bin/classic:$ARBORPATH/java:$PATH:
export LIBPATH=$JAVA_HOME/jre/bin:$JAVA_HOME/jre/bin/classic:$LIBPATH
elif [ $BOX = LINUX ]
then
echo "Set up your environment"
else
echo "Environment not automatically set"
fi

Kevin’s dmccrmcc.sh
# Filename:          dmccrmcc.sh
# Authour:           Kevin Liao
# Date:              04/08/99
# Calling Files:     dmxxunld.scr
#                    dmccrmcctgt0.scr, dmccrmcctgt2.scr, dmccrmcctgt4.scr
#                    dmdcldr.scr
#                    dmccrcsc.csc
#                    dmxxexpt.scr
#                    dmdcdela.scr
#
# Description:       Remote Calc main test script.
#
# 04/19/99 kliao:    Captitalize app|db name for Unix platform
#                    Add $testfilename for lower case test scripts
# 04/22/99 kliao:    1) Replace export with report scripts
#                    2) Change the log files names to have 8 characters
#

# Initialize local variables
host=local
user=essexer
password=password
appsrc1=Rmccsrc1
appsrc2=Rmccsrc2
appsrc3=Rmccsrc3
apptgt=Rmcctgt
dbsrc1=Source1
dbsrc2=Source2
dbsrc3=Source3
dbtgt=Target
testfilename=rmcctgt

# Start the Essbase agent
sxr agtctl start

###############   REGULAR OUTLINE WITH NO ATTRIBUTES  ####################

#
#  SETUP
#
#  Create new application and db
sxr newapp -force $appsrc1
sxr newapp -force $appsrc2
sxr newapp -force $appsrc3
sxr newapp -force $apptgt

sxr newdb -otl ${testfilename}1.otl $appsrc1 $dbsrc1
sxr newdb -otl ${testfilename}1.otl $appsrc2 $dbsrc2
sxr newdb -otl ${testfilename}1.otl $appsrc3 $dbsrc3
sxr newdb -otl ${testfilename}1.otl $apptgt  $dbtgt

#  Load and Calc the Source databases
#  Reset and load Source1
sxr esscmd dmdcldr.scr  %HOST=$host %APPNAME=$appsrc1 %DBNAME=$dbsrc1 %DATAFILE=`sxr which -data dmccrmcc.txt`
sxr esscmd dmccrcsc.scr %HOST=$host %APPNAME=$appsrc1 %DBNAME=$dbsrc1 %CALC=`sxr which -csc dmccrmsc.csc`

#  Reset and load Source2
sxr esscmd dmdcldr.scr  %HOST=$host %APPNAME=$appsrc2 %DBNAME=$dbsrc2 %DATAFILE=`sxr which -data dmccrmcc.txt`
sxr esscmd dmccrcsc.scr %HOST=$host %APPNAME=$appsrc2 %DBNAME=$dbsrc2 %CALC=`sxr which -csc dmccrmsc.csc`

#  Reset and load Source3
sxr esscmd dmdcldr.scr  %HOST=$host %APPNAME=$appsrc3 %DBNAME=$dbsrc3 %DATAFILE=`sxr which -data dmccrmcc.txt`
sxr esscmd dmccrcsc.scr %HOST=$host %APPNAME=$appsrc3 %DBNAME=$dbsrc3 %CALC=`sxr which -csc dmccrmsc.csc`


sxr esscmd dmccrcsc.scr %HOST=$host %APPNAME=$appsrc3 %DBNAME=$dbsrc3 %CALC=`sxr which -csc dmccrmsc.csc`

#  Loop through 3 tests with different partitition definitions
#  Test0:   Partition across 1 Sparse dimension (Division Total)
#  Test2:   Partition across the last Sparse dimension (Account Total)
#  Test4:   Partition across 2 Sparse dimensions (World Wide Total, Division Total)

for TestID in 0 2 4
do

   #  Create Partition Definition Files
   sxr esscmd -q dmccrmcctgt${TestID}.scr %HOST=$host %APPSRC1=$appsrc1 %APPSRC2=$appsrc2 %APPSRC3=$appsrc3 \
                                          %APPTGT=$apptgt %DBSRC1=$dbsrc1 %DBSRC2=$dbsrc2 %DBSRC3=$dbsrc3 %DBTGT
=$dbtgt

   #  Copy Partition Definition Files
   sxr fcopy -in 'Target.ddn'  -out !!!!$apptgt!$dbtgt!
   sxr fcopy -in 'Source1.ddn' -out !!!!$appsrc1!$dbsrc1!
   sxr fcopy -in 'Source2.ddn' -out !!!!$appsrc2!$dbsrc2!
   sxr fcopy -in 'Source3.ddn' -out !!!!$appsrc3!$dbsrc3!

   #  Replace Region Files
   sxr esscmd -q dmxxrepr.scr %HOST=$host %APPNAME=$appsrc1 %DBNAME=$dbsrc1
   sxr esscmd -q dmxxrepr.scr %HOST=$host %APPNAME=$appsrc2 %DBNAME=$dbsrc2
   sxr esscmd -q dmxxrepr.scr %HOST=$host %APPNAME=$appsrc3 %DBNAME=$dbsrc3
   sxr esscmd -q dmxxrepr.scr %HOST=$host %APPNAME=$apptgt  %DBNAME=$dbtgt

   #  Run Calc on Target Database
   sxr esscmd dmccrcsc.scr %HOST=$host %APPNAME=$apptgt %DBNAME=$dbtgt %CALC=`sxr which -csc dmccrmcc.csc`

   # Run the report script to get the test result
   sxr runrept $apptgt $dbtgt dmccrc0${TestID}.rep dmccrc0${TestID}.log

   # Compare the test result with the baseline
   sxr diff dmccrc0${TestID}.log dmccrc0${TestID}.log

done

#  Cleanup - Delete Databases
sxr esscmd dmdcdela.scr %HOST=$host %APPNAME=$appsrc1 %DBNAME=$dbsrc1
sxr esscmd dmdcdela.scr %HOST=$host %APPNAME=$appsrc2 %DBNAME=$dbsrc2
sxr esscmd dmdcdela.scr %HOST=$host %APPNAME=$appsrc3 %DBNAME=$dbsrc3
sxr esscmd dmdcdela.scr %HOST=$host %APPNAME=$apptgt %DBNAME=$dbtgt
#########################################################################

#################   OUTLINE WITH ATTRIBUTES   ###########################
sxr sh dmccrmat.sh
#########################################################################


Maxl variable substitution and loop (for essexer 2_20a)
Create_app-mxl.sh
HOST=${SXR_DBHOST}
UID=${SXR_USER}
PWD=${SXR_PASSWORD}
WORK=${SXR_WORK}
VIEW=${SXR_VIEWHOME}

APP=Sample_

# create 100 applicaions using while loop
export SXR_ESSCMD=essmsh

i=1
while ( test ${i} -le 5 )
do
        sxr esscmd  create_app_loop.mxl %3=$HOST %1=$UID %2=$PWD \
                        %4=$APP${i}
        i=`expr ${i} + 1`
done
export SXR_ESSCMD=ESSCMD

create_app_loop.mxl
login "%1" "%2" on "%3";
create application "%4";
alter system unload application "%4";
logout;
exit;

Bao’s if-else control
E:/views/create_app_loop/sh/agtptsumain-1.sh
agtptsumain-1.sh
# Run the first regression test on separate agent and server ports

# bnguyen 10/16/02 - evoke regression mode to regression suite

CALCMODE1=serial
CALCMODE2=parallel
IO1=buffer
IO2=direct
MODE1=${1}
MODE2=${2}

# check for arguments
if [ $# -gt 1 ]
then
        # check for serial and direct mode
        if [ "x${MODE1}" = "x${CALCMODE1}" -a "x${MODE2}" = "x${IO2}" ]
        then
	    # change mode for all following test
	    sxr sh regress_mode.sh ${1} ${2}

	    echo "You are running ${CALCMODE1} and ${IO2}"
            if [ "${3}" -eq 1 ]
            then
                echo "***************************************************"
                echo "* This is part 1 of serial_direct --> Takes 18hrs *"
                echo "***************************************************"
		# tests from 62balanced1.sh

		sleep 5


	    elif [ "${3}" -eq 2 ]
            then
                echo "***************************************************"
                echo "* This is part 2 of serial_direct --> Takes 18hrs *"
                echo "***************************************************"
		# tests from 62balanced2.sh

		sleep 5

	    else
		echo "*********************************************************"
		echo "* There are 2 parts for this mode. Please follow format *"
		echo "* sxr sh agtptsumain.sh serial direct (1or2)            *"
		echo "*********************************************************"
	    fi

        # check for parallel and direct mode
        elif [ "x${MODE1}" = "x${CALCMODE2}" -a "x${MODE2}" = "x${IO2}" ]
        then
		# change mode for all following test
                sxr sh regress_mode.sh ${1} ${2}

		echo "You are running ${CALCMODE2} and ${IO2}"
                echo "**********************************************"
                echo "* Only 1 part for para_direct --> Takes 8hrs *"
                echo "**********************************************"
		#test from 62balanced3.sh

			sleep 5

        # check for parallel and buffer mode
        elif [ "x${MODE1}" = "x${CALCMODE2}" -a "x${MODE2}" = "x${IO1}" ]
        then
	    # change mode for all following test
            sxr sh regress_mode.sh ${1} ${2}

	    echo "You are running ${CALCMODE2} and ${IO1}"
            echo "***********************************************"
            echo "* Only 1 part for para_buffer --> Takes 8hrs *"
            echo "***********************************************"
	    # test from 62balanced3.sh

	sleep 5
        # check for invalid input
        else
		echo "**************************************************"
                echo "*You have chosen wrong regression_mode. Try Again*"
		echo "**************************************************"
        fi

# run on default mode
elif [ $# -eq 1 ]
then
        if [ "${1}" -eq 1 ]
        then
            echo "*********************************************"
            echo "* This is part 1 of default --> Takes 17hrs *"
            echo "*********************************************"

	sleep 5

	elif [ "${1}" -eq 2 ]
        then
            echo "*********************************************"
            echo "* This is part 2 of default --> Takes 18hrs *"
            echo "*********************************************"

	sleep 5

	fi

else
        echo "*******************************"
        echo "* Your are running 40hrs test *"
        echo "*******************************"

	sleep 5

fi

Run Result
1) sxr  sh agtptsumain-1.sh

*******************************
* Your are running 40hrs test *
*******************************
1) sxr sh agtptsumain-1.sh parallel buffer

You are running parallel and buffer
***********************************************
* Only 1 part for para_buffer --> Takes 8hrs *
***********************************************

2) sxr  sh agtptsumain-1.sh 1

*********************************************
* This is part 1 of default --> Takes 17hrs *
*********************************************
3) sxr  sh agtptsumain-1.sh 2
*********************************************
* This is part 2 of default --> Takes 18hrs *
*********************************************

4) sxr  sh agtptsumain-1.sh serial buffer

**************************************************
*You have chosen wrong regression_mode. Try Again*
**************************************************
5) sxr  sh agtptsumain-1.sh serial direct
***************************************************************
You are about running serial direct for all of the regression suite
***************************************************************
.
You are running serial and direct
*********************************************************
* There are 2 parts for this mode. Please follow format *
* sxr sh agtptsumain.sh serial direct (1or2)            *
*********************************************************

6) sxr  sh agtptsumain-1.sh serial direct 1










2) sxr sh agtptsumain-1.sh parallel buffer 1

***************************************************************
You are about running parallel buffer for all of the regression suite
***************************************************************

***********************************************
* Only 1 part for para_buffer --> Takes 8hrs *
***********************************************

3) sxr  sh agtptsumain-1.sh parallel buffer 2


***************************************************************
You are about running parallel buffer for all of the regression suite
***************************************************************

***********************************************
* Only 1 part for para_buffer --> Takes 8hrs *
***********************************************


Kone Shell review
Erase empty line by awk

awk '($0 !~ /^ *$/) {print $0}' dmccmiblock1.out  > dmccmiblock1.out1


test command

number=20
test $number  -eq 20
echo $?
0

test $number  -eq 21
echo $?



Using awk
netstat
netstat 5 | awk 'NR!=3 {print $0}'

netstat 5 | grep –v localhost | awk 'NR!=3 {print $0}'

netstat  | grep –v localhost | awk 'NR!=3 {print $0}'


netstat 1 | awk 'NR!=3 {print $0}'


replace name with sed
Replace regraz4 with regraz2 in the file odbcinst.ini
 sed -i 's/regraz4/regraz2/g' odbcinst.ini
sed -i 's/regraz1/regraz3/g' odbcinst.ini


2009/03/31 use sed to modify version of ODBC/Merand/5.2 to 5.3
e.g. sed 's/show/Display/' andrew.txt

sed 's/5.2/5.3/' talleyrand_stlx8.env
sed 's/5.2/5.3/' talleyrand_sthp10.env



2008/10/13 How to get cpu number for Solaris
psrinfo -v


2014/03/26 Run concurrently
run 3 test*.sh concurrently

./test1.sh &
./test2.sh &
./test3.sh &

or use for loop:

for one in test1.sh test2.sh test3.sh; do
	./$one &
done


Run 3 test*.sh sequenctially, but kicked out by one command
./test1.sh; \
./test2.sh; \
./test3.sh  &

Bioinformatics Data Skills.pdf (p.420)
xargs and Parallelization
An incredibly powerful feature of xargs is that it can launch a limited number of processes
in parallel. I emphasize limited number, because this is one of xargs’s strengths
over Bash’s for loops. We could launch numerous multiple background processes
with Bash for loops, which on a system with multiple processors would run in parallel
(depending on other running tasks):

for filename in *.fastq; do
program "$filename" &
done




