#!/bin/ksh
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
# 07/14/06 by rukumar - added function to delete location alias.
# 07/20/06 by azhang - added Time dimension related functions for Beckett
# 08/17/11 by nnguyen - implemented exit_test() and clean_up() func which are automatically called when a test is aborted due to a major failure occurs
# 05/09/13 by nnguyen - implemented list_application(), list_variable(), list_security() and exclude_from_output() to fix issues in mxls<script>.sh
# 08/08/13 by sakula  - added code in fix_host to identify [::1] as host name (incase of IPV6) for bug 12821424
# 09/04/13 by nnguyen - fixed ctrl-M were accidentally removed by previous checkin
# 09/11/13 by azhang - added fix_version() and IPv4 support in fix_host()
# 10/17/13 by sakula - replace IPv6 addresses with 'FIX_IPADDR' to be compatible with old baselines in fix_host()
############################################################################

FUNCMOD=`sxr which -sh esscmd.func`
echo "Loading ${FUNCMOD} module..."

# Default error code
export errcode=0

# Error file to report fatal error
ERRFILE=$(basename $0 .sh)

# Save original SXR_USER/SXR_PASSWORD for later use
export SXR_USER_BAK="${SXR_USER}"
export SXR_PASSWORD_BAK="${SXR_PASSWORD}"

# On Solaris, the default awk utility under /usr/bin does not support [-v assignment] option.
# So use /usr/xpg4/bin/awk as default on Solaris and all scripts should use `$AWK` instead of `awk`
# for cross platforms compatibility
AWK="`which awk`"
if [ "${SXR_PLATFORM#solaris}" != "${SXR_PLATFORM}" -a -f /usr/xpg4/bin/awk ]; then
   AWK=/usr/xpg4/bin/awk
fi

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
sxr esscmd -q msxxcopycfgfile.scr %HOST=$SXR_DBHOST %UID="$SXR_USER" %PWD=$SXR_PASSWORD \
                                %OLDFILE=$1 %NEWFILE=$2
}


# Delete file from Server $ARBOR/Bin dir
delete_cfg ()
{
# File to delete
sxr esscmd -q msxxremovecfgfile.scr %HOST=$SXR_DBHOST %UID="$SXR_USER" %PWD=$SXR_PASSWORD %CFGFILE=$1
}


# Rename a file in Server $ARBOR/Bin dir
rename_cfg ()
{
# OldFileName, NewFileName
sxr esscmd -q msxxrenamecfgfile.scr %HOST=$SXR_DBHOST %UID="$SXR_USER" %PWD=$SXR_PASSWORD \
                                    %OLDFILE=$1 %NEWFILE=$2
}


# Append file contents to Essbase.cfg file on server
send_to_cfg ()
{
# File containing new settings to Append
sxr esscmd -q msxxsendcfgfile.scr %HOST=$SXR_DBHOST %UID="$SXR_USER" %PWD=$SXR_PASSWORD %CFGFILE=$1
}


# Get config values from Essbase.cfg file on server
get_cfg_values ()
{
# OutputFile
sxr esscmd -q msxxgetcfgvalues.scr %HOST=$SXR_DBHOST %UID="$SXR_USER" %PWD=$SXR_PASSWORD %CFGFILE=$1
}


############################################################################
# Application and Database Manipulation

# Create a new app
create_app ()
{
# AppName
sxr msh msxxcreapp.msh "dso" "$SXR_USER" $SXR_PASSWORD $SXR_DBHOST $(init_cap $1)
errcode=$?

if [ $errcode -ne 0 ]; then
    echo "!!!FAILURE!!! Failed to create app [$1]!" | tee -a ${ERRFILE}.dif
    exit_test $errcode
fi
}


# Create a new db
create_db ()
{
# [OutlineName] AppName DBName
_app=$1; _db=$2; _otl=""
if [ $# -gt 2 ]; then
    if [ -f "$1" ]; then
	_otl=$1
    else
	cp "`sxr which -data $1`" $SXR_WORK
	_otl="$SXR_WORK/$1"
	chmod 777 "$_otl"
    fi
    _app=$2; _db=$3
fi

sxr msh msxxcredb.msh "$SXR_USER" $SXR_PASSWORD $SXR_DBHOST $_app $_db

if [ -n "$_otl" ]; then # Create DB with Outline
    sxr esscmd -q msxxcredbex.scr %HOST=$SXR_DBHOST %UID="$SXR_USER" %PWD=$SXR_PASSWORD \
	     %APP=$_app %DB=$_db %OTLFILE=$_otl %XMLFILE="`sxr which -data $_xml`" %OPT="OTL"
fi

errcode=$?
if [ $errcode -ne 0 ]; then
    echo "!!!FAILURE!!! Failed to create db [$_app.$_db]!" | tee -a ${ERRFILE}.dif
    exit_test $errcode
fi
}


# Delete application
delete_app ()
{
# AppName
sxr esscmd msxxrmap.scr %HOST=$SXR_DBHOST %USER="$SXR_USER" %PASSWD=$SXR_PASSWORD %APP=$1
}


# Delete Database
delete_db ()
{
# AppName DBName
sxr esscmd msxxrmdb.scr %HOST=$SXR_DBHOST %USER="$SXR_USER" %PASSWD=$SXR_PASSWORD %APP=$1 %DB=$2
}


# Copy application
copy_app()
{
# SourceAppName DestAppName
sxr esscmd -q msxxcopyapp.scr %HOST=${SXR_DBHOST} %UID="${SXR_USER}" %PWD=${SXR_PASSWORD} \
			    %SRCAPP=$1 %DESTAPP=$2
}


# Copy database
copy_db()
{
# SourceAppName SourceDBName DestAppName DestDBName
sxr esscmd -q msxxcopydb.scr %HOST=${SXR_DBHOST} %UID="${SXR_USER}" %PWD=${SXR_PASSWORD} \
			  %SRCAPP=$1 %SRCDB=$2 %DESTAPP=$3 %DESTDB=$4
}


# Rename application
rename_app()
{
# OldAppName NewAppName
sxr esscmd -q msxxrenapp.scr %HOST=${SXR_DBHOST} %UID="${SXR_USER}" %PWD=${SXR_PASSWORD} \
			    %OLDAPP=$1 %NEWAPP=$2
}


# Rename database
rename_db()
{
# AppName DBName NewDBName
sxr esscmd -q msxxrendb.scr %HOST=${SXR_DBHOST} %UID="${SXR_USER}" %PWD=${SXR_PASSWORD} \
			    %APP=$1 %OLDDB=$2 %NEWDB=$3
}


# Load application
load_app ()
{
# AppName
sxr esscmd msxxldap.scr %HOST=$SXR_DBHOST %USER="$SXR_USER" %PASSWD=$SXR_PASSWORD %APP=$1
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
sxr esscmd msxxunloadapp.scr %HOST=$SXR_DBHOST %UID="$SXR_USER" %PWD=$SXR_PASSWORD %APP=$1
}


# Unload Database
unload_db ()
{
# AppName DBName
sxr esscmd msxxunloaddb.scr %HOST=$SXR_DBHOST %USER="$SXR_USER" %PASSWD=$SXR_PASSWORD \
				%APPNAME=$1 %DBNAME=$2
}


# Set Database State
dbstate_set ()
{
# AppName DBName Item Argument1 Argument2
sxr esscmd msxxsetdbstitem.scr 	%HOST=$SXR_DBHOST %UID="$SXR_USER" %PWD=$SXR_PASSWORD \
				%APP=$1 %DB=$2 %ITEM=$3 %ARG1=$4 %ARG2=$5 %ARG3=$6
}


# Get Database State
dbstate_get ()
{
# AppName DBName OutputFileName
sxr esscmd msxxgetdbstate.scr	%HOST=$SXR_DBHOST %UID="$SXR_USER" %PWD=$SXR_PASSWORD \
				%APP=$1 %DB=$2 %OFILE=$3
}


# List Database's Index/Page Files
dbstate_list ()
{
# FileType AppName DBName OutputFileName
sxr esscmd msxxlistdbfiles.scr	%HOST=$SXR_DBHOST %UID="$SXR_USER" %PWD=$SXR_PASSWORD \
				%FTYPE=$1 %APP=$2 %DB=$3 %OFILE=$4
}


# Get Database Statistics
dbstat_get ()
{
# AppName DBName OutputFileName
sxr esscmd msxxgetdbstats.scr	%HOST=$SXR_DBHOST %UID="$SXR_USER" %PWD=$SXR_PASSWORD \
				%APP=$1 %DB=$2 %OFILE=$3
}


# Get limit
get_limit()
{
# AppName DBName OutFile
sxr esscmd -q smalgetlimit.scr %HOST=$SXR_DBHOST %UID="$SXR_USER" %PWD=$SXR_PASSWORD \
				%APP=$1 %DB=$2 %OUT=$3
}


# Get the app log
applog_copy ()
{
# AppName OutputFileName 
sxr esscmd -q msxxgetlog.scr 	%HOST=$SXR_DBHOST %UID="$SXR_USER" %PWD=$SXR_PASSWORD \
				%APP=$1 %LOG=$2
}


# Delete the app log
delete_log ()
{
# AppName 
sxr esscmd -q msxxdellog.scr 	%HOST=$SXR_DBHOST %UID="$SXR_USER" %PWD=$SXR_PASSWORD %APP=$1
}


# Export data - column format
export_data ()
{
# AppName DBName OutputFile ExportOption
sxr esscmd msxxcolexport.scr	%HOST=$SXR_DBHOST %UID="$SXR_USER" %PWD=$SXR_PASSWORD \
				%APP=$1 %DB=$2 %EXPORTPATH=$SXR_WORK %FILENAME=$3 %NUM=$4
}


# Export data - default format
export_data_def ()
{
# AppName DBName OutputFile ExportOption
sxr esscmd msxxexport.scr	%HOST=$SXR_DBHOST %UID="$SXR_USER" %PWD=$SXR_PASSWORD \
				%APP=$1 %DB=$2 %FNAME="$SXR_WORK/$3" %OPT=$4
}


# Reset/clear data
reset_db ()
{
# AppName DBName
sxr esscmd msxxresetdb.scr	%HOST=$SXR_DBHOST %UID="$SXR_USER" %PWD=$SXR_PASSWORD \
				%APP=$1 %DB=$2
}


# Create Substitution Variable
create_sub_var ()
{
# AppName DBName SubstitutionVariable SubstitutionValue
sxr esscmd msxxcreatesubvar.scr	%HOST=$SXR_DBHOST %USER="$SXR_USER" %PASSWD=$SXR_PASSWORD \
				%APPNAME=$1 %DBNAME=$2 %SUBVAR=$3 %SUBVAL=$4
} 


# Get Object
get_object ()
{
# ObjType AppName DBName ObjName NewObjName
sxr esscmd -q msxxgetobject.scr %HOST=${SXR_DBHOST} %UID="${SXR_USER}" %PWD=${SXR_PASSWORD} \
			    %TYPE=$1 %APP=$2 %DB=$3 %OBJ=$4 %DES=$5
}


# Put Object
put_object ()
{
# Dest ObjType AppName DBName ObjName ObjLoc UnlockObj
sxr esscmd -q msxxputobject3.scr %HOST=${SXR_DBHOST} %UID="${SXR_USER}" %PWD=${SXR_PASSWORD} \
	    %DEST=$1 %TYPE=$2 %APP=$3 %DB=$4 %OBJ=$5 %LOC="$6" %UNLCK="Y"
}


# Enable/Disable Unicode
set_unicode ()
{
# [Enable | Disable]
sxr msh msxxsetunicode.msh "${SXR_USER}" ${SXR_PASSWORD} ${SXR_DBHOST} $1
}


# Set database param
set_db_param ()
{
# AppName DbName Param Value
#    where param value can be one of followings
# 1) retrieve_buffer_sise	[SIZE_STRING]
# 2) retrieve_sort_buffer_sise	[SIZE_STRING]
# 3) data_cache_sise		[SIZE_STRING]
# 4) data_file_cache_sise	[SIZE_STRING]
# 5) index_cache_sise		[SIZE_STRING]
# 6) currency_database		[DBS_STRING]
# 7) currency_member		[MEMBER_NAME]
# 8) currency_conversion	[division|multiplication]
# 9) compression		[rle|bitmap|zlib]
# 10) lock_timeout		[immediate|never]
# 11) io_access_mode		[buffered|direct]
sxr msh msxxsetdbparam.msh "${SXR_USER}" ${SXR_PASSWORD} ${SXR_DBHOST} $1 $2 $3 $4
}


# Dump Meta Data
dump_meta_data ()
{
# AppName DbName MetaDataFile
sxr esscmd -q msxxdumpmetadata.scr %HOST=${SXR_DBHOST} %UID="${SXR_USER}" %PWD=${SXR_PASSWORD} %APP=$1 %DB=$2 %METAFILE=$3
}


############################################################################
# Load Data

# Load Data
load_data ()
{
# AppName DBName DataFile [LoadOpt]
# Where LoadOpt = 3 (local - default) | 2 (server)
if [ "$4" = "2" ]; then
    sxr esscmd msxxloaddataserver.scr  %HOST=$SXR_DBHOST %USER="$SXR_USER" %PASSWD=$SXR_PASSWORD \
					%APPNAME=$1 %DBNAME=$2 %LOADDATA=$3
    errcode=$?
else
    sxr esscmd msxxloaddata.scr  %HOST=$SXR_DBHOST %USER="$SXR_USER" %PASSWD=$SXR_PASSWORD \
					%APPNAME=$1 %DBNAME=$2 %LOADDATA=`sxr which -data $3`
    errcode=$?
fi
if [ $errcode -ne 0 ]; then
    echo "!!!FAILURE!!! Failed to load data [$3]!" | tee -a ${ERRFILE}.dif
    exit_test $errcode
fi
}



# Import_data
import_data ()
{
# AppName DBName DataFileLocation DataLoadFileName DataLoadFileType RuleFileLocation RuleFileName
    _data=`echo $4 | sed 's/\..*//'`
    if [ "$3" = "3" ]; then _data=`sxr which -data $4`; fi

    _rule=`echo $7 | sed 's/\..*//'`
    if [ "$6" = "3" ]; then _rule=`sxr which -data $7`; fi

    _opt="with_rule"
    if [ -z "${_rule}" ]; then _opt="no_rule"; fi

    sxr esscmd msxximportex.scr %HOST=$SXR_DBHOST %UID="$SXR_USER" %PWD=$SXR_PASSWORD \
				%APP=$1 %DB=$2 %DLOC=$3 %DFILE=${_data} \
				%TYPE=$5 %RLOC=$6 %RFILE=${_rule} %OPT=${_opt}

errcode=$?
if [ $errcode -ne 0 ]; then
    echo "!!!FAILURE!!! Failed to import data [${_data}]!" | tee -a ${ERRFILE}.dif
    exit_test $errcode
fi
}



############################################################################
# Run Calc

# Run Default Calc
runcalc_default ()
{
# AppName DBName
sxr esscmd msxxrundefaultcalc.scr	%HOST=$SXR_DBHOST %UID="$SXR_USER" %PWD=$SXR_PASSWORD \
					%APP=$1 %DB=$2
}


# Run Custom Calc Script
runcalc_custom ()
{
# AppName DBName CalcScriptName [Opt]
# Where Opt = 3 (local - default) | 2 (server) | 1 (client)
    if [ -z "$4" -o "$4" = "3" ]; then
	_loc=3
	_calc=`sxr which -csc $3`
    else
	_loc=$4
	_calc=$(basename $3 .csc)
    fi

    sxr esscmd msxxcscex.scr	%HOST=$SXR_DBHOST %UID="$SXR_USER" %PWD=$SXR_PASSWORD \
				%APP=$1 %DB=$2 %CSC=${_calc} %LOC=${_loc}

errcode=$?
if [ $errcode -ne 0 ]; then
    echo "!!!FAILURE!!! Failed to run calc [$3]!" | tee -a ${ERRFILE}.dif
    exit_test $errcode
fi
}


# Run Calc Script
run_calc ()
{
# AppName DBName [CalcScriptNAme]
if [ $# -eq 2 ]; then
    runcalc_default $1 $2
else
    runcalc_custom $1 $2 $3 $4
fi
}


# Run Calc String
run_calc_str ()
{
# AppName DBName CalcStr
sxr esscmd msxxcalcstr.scr %HOST=${SXR_DBHOST} %UID="${SXR_USER}" %PWD=${SXR_PASSWORD} \
				%APP=$1 %DB=$2 %CALCSTR="$3"
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
sxr msh msxxdroppartition.msh "$SXR_USER" $SXR_PASSWORD $SXR_DBHOST $1 $2 $3 $4 $5
}


# Refresh replicated partition
refresh_repl_part ()
{
# SourceAppName SourceDBName TargetAppName TargetDBName [all | updated]
sxr msh msxxrefreshreplpart.msh "$SXR_USER" $SXR_PASSWORD $SXR_DBHOST "$1" "$2" "$3" "$4" "$5"
}


# Refresh outlien
refresh_outline ()
{
# [replicated | transparent | linked ] SourceAppName SourceDBName TargetAppName TargetDBName 
#	[purge outline change_file | apply all | apply nothing ]
sxr msh msxxrefreshoutline.msh "$SXR_USER" $SXR_PASSWORD $SXR_DBHOST "$1" "$2" "$3" "$4" "$5" "$6"
}


############################################################################
# Spreadsheet Requests

# Retrieve data
ret_data()
{
# AppName DBName MaxRow MaxCol RetInFileName TotalRowsInFile TotalColumnsInFile RetOutFileName
export SXR_ESSCMD='ESSCMDG'
sxr esscmd smalxret.scr %HOST=$SXR_DBHOST %USER="$SXR_USER" %PWD=$SXR_PASSWORD \
			%APP=$1 %DB=$2 %ROW=$3 %COL=$4 \
			%IFILE=`sxr which -data $5` \
			%RSIZE="$6" %CSIZE="$7" %OFILE="$8"
export SXR_ESSCMD='ESSCMD'
}


# Retrieve
retrieve ()
{
# AppName DBName RetInFileName TotalRowsInFile TotalColumnsInFile RetOutFileName [Suppress#Mi=0|1]
_scriptname=msxxrtv
if [ "$7" = "1" ]; then _scriptname=msxxrtv_sprmiss; fi

export SXR_ESSCMD='ESSCMDG'
sxr esscmd ${_scriptname}.scr  	%HOST=$SXR_DBHOST %USER="$SXR_USER" %PASSWD=$SXR_PASSWORD \
				%APPNAME=$1 %DBNAME=$2 %INITROW=65000 %INITCOL=250 \
				%RTVIN=`sxr which -data $3` %ROW=$4 %COL=$5 %RTVOUT=$6
export SXR_ESSCMD='ESSCMD'
}


# Zoom In
zoom_in ()
{
# AppName DBName ZoomInFileName TotalRowsInFile TotalColumnsInFile ZoomInRowCell ZoomInColumnCell ZoomInLevel ZoomInOuputFileName
export SXR_ESSCMD='ESSCMDG'
sxr esscmd msxxzoomin.scr  	%HOST=$SXR_DBHOST %USER="$SXR_USER" %PASSWD=$SXR_PASSWORD \
		    		%APPNAME=$1 %DBNAME=$2 %INITROW=65000 %INITCOL=250 \
				%ZIN=`sxr which -data $3` %TROW=$4 %TCOL=$5 %ZROW=$6 \
				%ZCOL=$7 %ZLEV=$8 %ZOUTP=$9 %ZOPT=1
export SXR_ESSCMD='ESSCMD'
}


# Zoom In
zoom_in_sprmiss ()
{
# AppName DBName ZoomInFileName TotalRowsInFile TotalColumnsInFile ZoomInRowCell ZoomInColumnCell ZoomInLevel ZoomInOuputFileName
export SXR_ESSCMD='ESSCMDG'
sxr esscmd msxxzoomin_sprmiss.scr %HOST=$SXR_DBHOST %USER="$SXR_USER" %PASSWD=$SXR_PASSWORD \
		    		%APPNAME=$1 %DBNAME=$2 %INITROW=65000 %INITCOL=250 \
				%ZIN=`sxr which -data $3` %TROW=$4 %TCOL=$5 %ZROW=$6 \
				%ZCOL=$7 %ZLEV=$8 %ZOUTP=$9 %ZOPT=1
export SXR_ESSCMD='ESSCMD'
}


# Zoom In
rolap_zoom_in ()
{
# AppName DBName ZoomInFileName TotalRowsInFile TotalColumnsInFile ZoomInRowCell ZoomInColumnCell ZoomInLevel ZoomInOuputFileName

export SXR_ESSCMD='ESSCMDG'
sxr esscmd msxxrolapzoomin.scr 	%HOST=$SXR_DBHOST %USER="$SXR_USER" %PASSWD=$SXR_PASSWORD \
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
sxr esscmd msxxzoomout.scr  	%HOST=$SXR_DBHOST %USER="$SXR_USER" %PASSWD=$SXR_PASSWORD \
		    		%APPNAME=$1 %DBNAME=$2 %INITROW=65000 %INITCOL=250 \
				%ZOFILE=`sxr which -data $3` %TROW=$4 %TCOL=$5 %ZOROW=$6 \
				%ZOCOL=$7 %ZOOUT=$8
export SXR_ESSCMD='ESSCMD'
}


# Zoom Out
rolap_zoom_out ()
{
# AppName DBName ZoomOutFileName TotalRowsInFile TotalColumnsInFile ZoomOutRowCell ZoomOutColumnCell ZoomOutOuputFileName

export SXR_ESSCMD='ESSCMDG'
sxr esscmd msxxrolapzoomout.scr	%HOST=$SXR_DBHOST %USER="$SXR_USER" %PASSWD=$SXR_PASSWORD \
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
sxr esscmd msxxkeeponly.scr  	%HOST=$SXR_DBHOST %USER="$SXR_USER" %PASSWD=$SXR_PASSWORD \
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
sxr esscmd msxxremoveonly.scr  	%HOST=$SXR_DBHOST %USER="$SXR_USER" %PASSWD=$SXR_PASSWORD \
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
sxr esscmd msxxlockandsend.scr  %HOST=$SXR_DBHOST %USER="$SXR_USER" %PASSWD=$SXR_PASSWORD \
		    		%APPNAME=$1 %DBNAME=$2 %INITROW=65000 \
				%INITCOL=250 %UPDATE=`sxr which -data $3` %ROW=$4 %COL=$5
export SXR_ESSCMD='ESSCMD'
}


# Pivot
pivot_only ()
{
# AppName DBName PivotFileName TotalRowsInFile TotalColumnsInFile PivotRowCell PivotColumnCell PivotOuputFileName

export SXR_ESSCMD='ESSCMDG'
sxr esscmd msxxpivot.scr  	%HOST=$SXR_DBHOST %USER="$SXR_USER" %PASSWD=$SXR_PASSWORD \
		    		%APPNAME=$1 %DBNAME=$2 %INITROW=65000 %INITCOL=250 \
				%PFILE=`sxr which -data $3` %TROW=$4 %TCOL=$5 %PROW=$6 \
				%PCOL=$7 %POUT=$8
export SXR_ESSCMD='ESSCMD'
}



############################################################################
# User Manipulation & Permissions

# Grant application access to user
grant_app ()
{
# <no_access|restart|manager|1..3> App Name
PRIV=${1}
if [ "${1}" = "no_access" ]; then
   PRIV=1
elif [ "${1}" = "restart" ]; then
   PRIV=2
elif [ "${1}" = "manager" ]; then
   PRIV=3
fi
sxr esscmd -q msxxsetappaccess2.scr %HOST=${SXR_DBHOST} %UID="${SXR_USER}" %PWD=${SXR_PASSWORD} \
					%APP=${2} %USER="${3}" %PRIV=${PRIV}
}


# Grant database access to user
grant_db ()
{
# <no_access|read|write|execute|restart|manager|1..6> AppName DbName Name
PRIV=${1}
if [ "${1}" = "1" ]; then
   PRIV=no_access
elif [ "${1}" = "2" ]; then
   PRIV=read
elif [ "${1}" = "3" ]; then
   PRIV=write
elif [ "${1}" = "4" -o "${1}" = "execute" ]; then
   PRIV="execute any"
elif [ "${1}" = "5" ]; then
   PRIV=read
elif [ "${1}" = "6" ]; then
   PRIV=manager
fi
sxr msh msxxgrant_dbaccess.msh "${SXR_USER}" $SXR_PASSWORD $SXR_DBHOST "${PRIV}" "$2" "$3" "$4"
}


# Grant system access to user
grant_system ()
{
# <no_access|administrator|create_application|create_user> Name
export SXR_ESSCMD='essmsh'
sxr esscmd msxxgrantsystemaccess.scr   %1="$SXR_NULLDEV" %2="$1" %3="$2"
export SXR_ESSCMD='ESSCMD'
}


# Create group
create_group ()
{
# GroupName
sxr msh msxxcreate_group.msh    "$SXR_USER" $SXR_PASSWORD $SXR_DBHOST "$1"
}


# Delete group
delete_group ()
{
# GroupName
sxr esscmd -q msxxdeletegroup.scr    %UID="$SXR_USER" %PWD=$SXR_PASSWORD %HOST=$SXR_DBHOST %USER="$1"
}


# Rename group
rename_group ()
{
# OldName NewName
sxr msh msxxrengroup.msh "$SXR_USER" $SXR_PASSWORD $SXR_DBHOST "$1" "$2"
}


# Create user
create_user ()
{
# UserName [Password]
sxr msh msxxcreateuser.msh    "$SXR_USER" $SXR_PASSWORD $SXR_DBHOST "$1" "${2:-$SXR_PASSWORD}"
}


# Delete user
delete_user ()
{
# UserName
sxr msh msxxdrop_user.msh    "$SXR_USER" $SXR_PASSWORD $SXR_DBHOST "$1"
}


# Rename user
rename_user()
{
# OldName NewName
sxr msh msxxrenuser.msh "$SXR_USER" $SXR_PASSWORD $SXR_DBHOST "$1" "$2"
}


# Reset password
reset_pwd ()
{
# UserName NewPassword
sxr msh msxxresetpwd.msh "$SXR_USER" $SXR_PASSWORD $SXR_DBHOST "$1" "$2"
}


# Enable/Disable user
set_user_state()
{
# UserName enable|disable
sxr msh msxxsetuserstate.msh "$SXR_USER" $SXR_PASSWORD $SXR_DBHOST "$1" "$2"
}


# Add user to group
add_togroup ()
{
# GroupName Member
sxr msh msxxaddtogroup.msh   "$SXR_USER" $SXR_PASSWORD $SXR_DBHOST "$1" "$2"
}


# Remove from group
remove_fromgroup ()
{
# GroupName Member
sxr msh msxxremovefromgroup.msh   "$SXR_USER" $SXR_PASSWORD $SXR_DBHOST "$1" "$2"
}


# Grant filter access to user
grant_filter ()
{
# App DB Filter Name
sxr msh msxxgrant_filter.msh "$SXR_USER" $SXR_PASSWORD $SXR_DBHOST "$1" "$2" "$3" "$4"
}


# Revoke filter access to user - same as grant no_access to database
revoke_filter ()
{
# App DB Filter Name
sxr msh msxxgrant_dbaccess.msh "$SXR_USER" $SXR_PASSWORD $SXR_DBHOST no_access "$1" "$2" "$4"
}


# Drop filter
drop_filter()
{
# App Db Filter
sxr msh msxxdropfilter.msh "$SXR_USER" ${SXR_PASSWORD} ${SXR_DBHOST} $1 $2 $3
}


# Grant calculation access to user
grant_calc ()
# App DB Calc Name
{
sxr msh msxxgrantcalcpri.msh calc_script "$SXR_USER" $SXR_PASSWORD $SXR_DBHOST \
				"$1" "$2" "$3" "$4"
}


# Revoke calculation access to user - same as no_access to database
revoke_calc ()
# App DB Calc Name
{
sxr msh msxxgrant_dbaccess.msh "$SXR_USER" $SXR_PASSWORD $SXR_DBHOST no_access "$1" "$2" "$4"
}



############################################################################
# New commands for E-license


# Display license info
display_license_info ()
{
# OutFile
sxr msh msxxdisplicinfo.msh "${SXR_USER}" ${SXR_PASSWORD} ${SXR_DBHOST} $1
}


# Create app type
create_app_type ()
{
# Location AppName StorageType AppType FrontEndType OutFile
sxr esscmd -q msxxcreappwithtype.scr %HOST=$SXR_DBHOST %UID="$SXR_USER" %PWD=$SXR_PASSWORD \
	    %LOC="$1" %APPNAME="$2" %STOTYPE="$3" %APPTYPE="$4" %FRONTENDTYPE="$5" %OUTFILE="$6"
}


# Get app type
get_app_type ()
{
# AppName OutFile
sxr esscmd -q msxxgetapptype.scr %HOST=$SXR_DBHOST %UID="$SXR_USER" %PWD=$SXR_PASSWORD \
				    %APP="$1" %OUTFILE="$2"
}


# Set app type
Set_app_type ()
{
# AppName FrontEndType OutFile
sxr esscmd -q msxxsetapptype.scr %HOST=$SXR_DBHOST %UID="$SXR_USER" %PWD=$SXR_PASSWORD \
				    %APP="$1" %FRONTENDTYPE="$2" %OUTFILE="$3"
}


# Create external user with type
create_extuser_type ()
{
# OutFile UserName UserPwd Protocol ConnectionParam Type
# Note: Type = "1 2 -1" for Essbase|Planning for example
sxr esscmd -q msxxcreextuserwithtype.scr %HOST=$SXR_DBHOST %UID="$SXR_USER" %PWD=$SXR_PASSWORD \
		%OUTFILE="$1" %USERNAME="$2" %USERPWD="" %PRO="$3" %CON="" %TYPE="$4"
}


# Create user with type
create_user_type ()
{
# OutFile UserName UserPwd AccLev Type
# Note: Type = "1 2 -1" for Essbase|Planning for example
sxr esscmd -q msxxcreuserwithtype.scr %HOST=$SXR_DBHOST %UID="$SXR_USER" %PWD=$SXR_PASSWORD \
			    %OUTFILE="$1" %USERNAME="$2" %USERPWD="$3" %ACCLEV="$4" %TYPE="$5"
}


# Create user with type and key
create_user_type_key ()
{
# OutFile UserName UserPwd PlatformToken Type
# Note: Type = "1 2 -1" for Essbase|Planning for example
sxr esscmd -q msxxcreuserwithtypekey.scr %HOST=$SXR_DBHOST %UID="$SXR_USER" %PWD=$SXR_PASSWORD \
			    %OUTFILE="$1" %USERNAME="$2" %USERPWD="$3" %FLATTOKEN="$4" %TYPE="$5"
}


# Get user type
get_user_key_type ()
{
# UserName OutFile
sxr esscmd -q msxxgetuserkeyandtype.scr %HOST=$SXR_DBHOST %UID="$SXR_USER" %PWD=$SXR_PASSWORD \
				    %USERNAME="$1" %OUTFILE="$2"
}


# Get user type
get_user_type ()
{
# UserName OutFile
sxr esscmd -q msxxgetusertype.scr %HOST=$SXR_DBHOST %UID="$SXR_USER" %PWD=$SXR_PASSWORD \
				    %USERNAME="$1" %OUTFILE="$2"
}


# Set user type
set_user_type ()
{
# OutFile UserName Type Cmd
# Note: Type = "1 2 -1" for Essbase|Planning for example
sxr esscmd -q msxxsetusertype.scr %HOST=$SXR_DBHOST %UID="$SXR_USER" %PWD=$SXR_PASSWORD \
			    %OUTFILE="$1" %USERNAME="$2" %TYPE="$3" %CMD="$4"
}


############################################################################
# LRO's

# Create a linked reporting object - Cell Note
create_lro_note ()
{
# Member1 Member2 Member3 Member4 CellNote NumberOfDimensions AppName DBName

sxr esscmd -q msxxcreatelronote.scr %HOST=$SXR_DBHOST %USER="$SXR_USER" %PASSWD=$SXR_PASSWORD \
					%MEM1="$1" %MEM2="$2" %MEM3="$3" %MEM4="$4" \
                                	%NOTE="$5" %DIMS="$6" %APP=$7 %DB=$8
}


# Create a linked reporting object - URL
create_lro_url ()
{
# Member1 Member2 Member3 Member4 URL Comment NumberOfDimensions AppName DatabaseNam

sxr esscmd -q msxxcreatelrourl.scr      %HOST=$SXR_DBHOST %USER="$SXR_USER" %PASSWD=$SXR_PASSWORD \
                                	%MEM1="$1" %MEM2="$2" %MEM3="$3" %MEM4="$4" \
                                	%URL="$5" %COMMENt="$6" %DIMS="$7" %APP=$8 %DB=$9
}


# Create a linked reporting object - file
create_lro_file ()
{
# Member1 Member2 Member3 Member4 NumberOfDimensions FileToBeAttached Comment AppName DBName

sxr fcopy -in -data "$FILE"
sxr esscmd -q msxxcreatelrofile.scr     %HOST=$SXR_DBHOST %USER="$SXR_USER" %PASSWD=$SXR_PASSWORD \
                                	%MEM1="$1" %MEM2="$2" %MEM3="$3" %MEM4="$4" \
	                                %DIMS="$5" %FILE=$SXR_WORK/$6 %COMMENT="$7" %APP=8 %DB=$9
}


# List Linked Reporting objects per database
list_lro ()
{
# OutputFileName ValidateFileName AppName DBName

sxr esscmd -q msxxlistlro.scr   %HOST=$SXR_DBHOST %USER="$SXR_USER" %PASSWD=$SXR_PASSWORD \
                                %OUTPUT=$1 %VALIDATE=$2 %APP=$3 %DB=$4
}



############################################################################
# Outline Manipulation

# Add a dimension
add_dim ()
{
# NewDimensionName DenseSparseCofig SiblingOfNewDimension AppName DBName

sxr esscmd -q msxxadddim.scr     %HOST=$SXR_DBHOST %USER="$SXR_USER" %PASSWD=$SXR_PASSWORD \
                                 %NEWDIM="$1" %CONF="$2" %FINDMEM="$3" %APP=$4 %DB=$5
}


# Build Dimension
build_dim ()
{
# AppName DBName RuleFileName BuildFileFileName

sxr esscmd msxxbuild.scr	%HOST=$SXR_DBHOST %UID="$SXR_USER" %PWD=$SXR_PASSWORD \
		    		%APP=$1 %DB=$2 %RFILE=`sxr which -data $3` \
				%DFILE=`sxr which -data $4`
}


# Add a member
add_mem ()
{
# SiblingOfNewMember NewMemberName ParentForNewMember AppName DBName

sxr esscmd -q msxxaddmem.scr    %HOST=$SXR_DBHOST %USER="$SXR_USER" %PASSWD=$SXR_PASSWORD \
                                %SIB="$1" %ADD="$2" %PARENT="$3" %APP=$4 %DB=$5
}


# Add a member with formula
add_mdx_mem ()
{
# SiblingOfNewMember NewMemberName ParentForNewMember Formula AppName DBName

sxr esscmd -q msxxaddmdxformmem.scr	%HOST=$SXR_DBHOST %USER="$SXR_USER" %PASSWD=$SXR_PASSWORD \
				    %SIB="$1" %ADD="$2" %PARENT="$3" %FORMULA="$4" %APP=$5 %DB=$6
}


# Rename a member
rename_mem ()
{
# OriginalMemberName NewMemberName AppName DBName

sxr esscmd -q msxxrenamemem.scr %HOST=$SXR_DBHOST %USER="$SXR_USER" %PASSWD=$SXR_PASSWORD \
                                %FIND="$1" %NEWMEM="$2" %APP=$3 %DB=$4
}

# Move a member
move_mem ()
{
# MemberToBeMoved NewParentForMember NewSiblingForMember AppName DBName

sxr esscmd -q msxxmovemem.scr   %HOST=$SXR_DBHOST %USER="$SXR_USER" %PASSWD=$SXR_PASSWORD \
                                %FINDA="$1" %FINDB="$2" %FINDN="$3" %APP=$4 %DB=$5
}


# Delete a member
delete_mem ()
{
# MemberToDelete AppName DBName

sxr esscmd -q msxxdelmem.scr    %HOST=$SXR_DBHOST %USER="$SXR_USER" %PASSWD=$SXR_PASSWORD \
                                %FIND="$1" %APP=$2 %DB=$3
}


# Add member formula
addformula()
{
# AppName DBName Loc Member Formula
sxr esscmd -q msxxaddmdxform.scr %HOST=${SXR_DBHOST} %UID="${SXR_USER}" %PWD=${SXR_PASSWORD} \
				    %APP="$1" %DB="$2" %MBR="$3" %FORMULA="$4"
}


# Add member formula from file
addformulafromfile()
{
# AppName DBName Loc Member FormulaFile
sxr esscmd -q msxxaddmdxformfromfile.scr %HOST=${SXR_DBHOST} %UID="${SXR_USER}" \
		%PWD=${SXR_PASSWORD} %APP=$1 %DB=$2 %MBR=$3 %FORMULAFILE=`sxr which -data $4`
}


# Restruct outline
restruct_otl()
{
# AppName DBName
sxr esscmd -q msxxrest.scr      %HOST=${SXR_DBHOST} %UID="${SXR_USER}" \
                                %PWD=${SXR_PASSWORD} %APP=$1 %DB=$2
}


# Get Member Info
get_member_info ()
{
# AppName DBName OutputFileName MemberName

sxr esscmd msxxgetmbri.scr	%HOST=$SXR_DBHOST %UID="$SXR_USER" %PWD=$SXR_PASSWORD \
		    		%APP=$1 %DB=$2 %OFILE=$3 %MBR="$4"
}


# Change Dense/Sparse Config
config_set ()
{
# DimensionName NewCofigurationForDim AppName DBName

sxr esscmd -q msxxdensesparseconf.scr	%HOST=$SXR_DBHOST %USER="$SXR_USER" %PASSWD=$SXR_PASSWORD \
                                	%FIND="$1" %CONF="$2" %APP=$3 %DB=$4
}


############################################################################
# Report scripts

# Run report
run_report()
{
sxr esscmd msxxrunrept.scr %HOST=$SXR_DBHOST %UID="$SXR_USER" %PWD=$SXR_PASSWORD \
			    %APP=$1 %DB=$2 %REP=`sxr which -rep $3` %OUTPUT="$4"
}


# Run MDX report
run_mdx()
{
# AppName DBName MDXReport Format MDXOutput [MDXLog]
sxr esscmd -q msxxrunmdxrept.scr %HOST=$SXR_DBHOST %UID="$SXR_USER" %PWD=$SXR_PASSWORD \
				 %APP=$1 %DB=$2 %MDXREP=`sxr which -rep $3` %FORMAT=$4 \
				 %MDXOUT=$5 %MDXLOG=${6:-$SXR_NULLDEV}
}


# Run Rolap MDX report
run_rolap_mdx()
{
# AppName DBName MDXReport MDXOutput
_mdxqry=""
while read _line
do
    _mdxqry=$_mdxqry' '$_line
done < `sxr which -rep $3`

echo "
login \"%HOST\" \"%UID\" \"%PWD\";
select \"%APP\" \"%DB\";
output 1 \"%MDXOUT\";
qRunRolapMdx \"$_mdxqry\";
output 3;
" > $SXR_VIEWHOME/scr/msxxrunrolapmdxrept.scr

sxr esscmd -q msxxrunrolapmdxrept.scr %HOST=$SXR_DBHOST %UID="$SXR_USER" %PWD=$SXR_PASSWORD \
				%APP=$1 %DB=$2 %MDXOUT=$4
}


############################################################################
# Trigger scripts

# Create trigger
create_trigger()
{
# AppName DBName TriggerFile OutputFile
sxr esscmd -q msxxcretrigger.scr %HOST=${SXR_DBHOST} %UID="${SXR_USER}" %PWD=${SXR_PASSWORD} \
				 %APP=$1 %DB=$2 %IFILE=`sxr which -rep $3` %OFILE=$4
}


# Create trigger - using qmdxtrigger command
create_trigger_ex()
{
# AppName DBName TriggerStatement OutputFile
sxr esscmd -q msxxqmdxtrigger.scr %HOST=${SXR_DBHOST} %UID="${SXR_USER}" %PWD=${SXR_PASSWORD} \
				 %APP=$1 %DB=$2 %TRGSTMT="$3" %OFILE=$4
}


# Drop trigger
drop_trigger()
{
# AppName DBName TriggerName
sxr msh msxxdroptrigger.msh "$SXR_USER" $SXR_PASSWORD $SXR_DBHOST $1 $2 $3
}


# Copy trigger spool file to work
gettrgsplfile()
{
# ApplicationName DatabaseName SourceSpoolFileName DestinationSpoolFileName
sxr esscmd -q msxxgettrgsplfile.scr %HOST=$SXR_DBHOST %USER="$SXR_USER" %PASSWD=$SXR_PASSWORD \
				   %APP=$1 %DB=$2 %SRCTRGFILE=$3 %DESTTRGFILE=$4
}


# Delete a specific trigger spool file
delete_spool_file ()
{
# ApplicationName DatabaseName SpoolFileName
sxr esscmd -q msxxdeltrgsplfile.scr %HOST=$SXR_DBHOST %USER="$SXR_USER" %PASSWD=$SXR_PASSWORD \
				    %APP=$1 %DB=$2 %TRGSPLFILE=$3
}


# Delete all trigger spool files
delete_all_spool_files ()
{
# ApplicationName DatabaseName
sxr esscmd -q msxxdelalltrgsplfiles.scr %HOST=$SXR_DBHOST %USER="$SXR_USER" \
					%PASSWD=$SXR_PASSWORD %APP=$1 %DB=$2
}


# Display triggers
display_trigger ()
{
# ApplicationName DatabaseName TriggerName OutputFile
sxr esscmd -q msxxqdisplaytrigger.scr %HOST=$SXR_DBHOST %UID="$SXR_USER" %PWD=$SXR_PASSWORD \
				    %APP=$1 %DB=$2 %TRGNAME=$3 %OFILE=$4
}


# List spool files
list_spool_files ()
{
# ApplicationName DatabaseName OutputFile
sxr esscmd -q msxxqlistspoolfiles.scr %HOST=$SXR_DBHOST %UID="$SXR_USER" %PWD=$SXR_PASSWORD \
				    %APP=$1 %DB=$2 %OFILE=$3
}


############################################################################
# Miscellaneous scripts

create_loc_alias ()
{
sxr esscmd dmcccloc.scr	%HOST=$SXR_DBHOST %UID="$SXR_USER" %PWD=$SXR_PASSWORD \
			%APP_Target=$1 %DB_Target=$2 %ALIAS=$3 %THOST=$4 \
			%APP=$5 %DB=$6 %USER="$7" %PASSWD=$8
}

delete_loc_alias ()
{
# AppName DBName LocationAlias
sxr esscmd dmccrloc.scr %HOST=$SXR_DBHOST %UID="$SXR_USER" %PWD=$SXR_PASSWORD \
                        %APPNAME=$1 %DBNAME=$2 %LOCALIAS=$3
}

############################################################################
# System scripts
# Get OPG Stats
opgstat_get()
{
#AppName OutputFileName
sxr esscmd msxxgetopgstats.scr %HOST=$SXR_DBHOST %UID="$SXR_USER" %PWD=$SXR_PASSWORD \
                                %APP=$1 %OFILE=$2
}

# Get OS
get_os()
{
# OutputFile
sxr esscmd -q msxxgetosres.scr %HOST=$SXR_DBHOST %UID="$SXR_USER" %PWD=$SXR_PASSWORD \
				%OFILE=$1
}


# Get memory
get_memory()
{
# AppName DBName OutFile
sxr esscmd -q smalgetmem.scr %HOST=$SXR_DBHOST %UID="$SXR_USER" %PWD=$SXR_PASSWORD \
				%APP=$1 %DB=$2 %OUT=$3
}


# Get system config
get_sys_cfg ()
{
# SystemConfigFile
sxr esscmd -q msxxgetsyscfg.scr  %HOST=$SXR_DBHOST %UID="$SXR_USER" %PWD=$SXR_PASSWORD %OFILE=$1
errcode=$?

# Exiting test if failed to get the system config
if [ $errcode -ne 0 -o ! -f "$SXR_WORK/$1" ]; then
    echo "!!!FAILURE!!! Failed to get the system config. Please make sure that essbase server is running!" | tee -a ${ERRFILE}.dif
    exit_test $errcode
fi
}


# Return $ARBORPATH of the $SXR_DBHOST
get_dbhost_arborpath ()
{
    if [ ! -f "$SXR_WORK/system.cfg" ]; then
	get_sys_cfg "system.cfg" > /dev/null 2>&1
    fi      

    if [ -f "$SXR_WORK/system.cfg" ]; then
	grep '^Environment Variable\:  ARBORPATH' "$SXR_WORK/system.cfg" | sed 's/^Environment Variable\:  ARBORPATH.* = //' | tr '\134' '/'
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


# Check for existing ODBC entry
odbc_exists ()
{
    _odbc_ini="${ODBCINI}"
    if [ "${SXR_PLATFORM}" = "nti" ]; then
	_odbc_ini="`echo ${SystemRoot} | tr '\\' '/'`/odbc.ini"
    elif [ -z "${_odbc_ini}" ]; then
	_odbc_ini="${ARBORPATH}/bin/.odbc.ini"
    fi

    if [ -z "${_odbc_ini}" ]; then
	echo 1
    else
	grep -i "${1}" "${_odbc_ini}" > "${SXR_NULLDEV}"
	echo $?
    fi
}


# Add new disk volume
add_disk_vol ()
# MappedDir MappedName DriveLetter
{
    # Make sure MappedDir exists
    mkdir -p "$1"

    # Use net use/share command on NT to add new volume drive
    # This function assumes t, u, v and w drive letter are reserved for automation
    if [ "${SXR_PLATFORM}" = "nti" -o "${SXR_PLATFORM}" = "nta" ]; then
	# Detect Windows version since "net share" has different options between 2000 vs 2003
	winver=`uname -rv`
	if [ "${winver}" = "5 00" ]; then
	    echo "net share $2=$1" > cmd.$$
	else
	    echo "net share $2=$1 /grant:Everyone,full" > cmd.$$
	fi
	# On NT, need to convert '/' to '\' in order to use net command
	echo "net use $3 '//$SXR_HOST/$2'" | tr '/' '\\' >> cmd.$$
	sh cmd.$$
    else
	# Create a soft link on UNIX
	mkdir -p "/tmp/${LOGNAME}"
	rm -fr "/tmp/${LOGNAME}/$2"
	ln -s "$1" "/tmp/${LOGNAME}/$2"
    fi

    # Failing to share and map new drive using one of these letters will abort the test
    errcode=$?
    if [ $errcode -ne 0 ]; then
	echo "!!!FAILURE!!! Failed to add new disk volume [$2=$1]!" | tee -a ${ERRFILE}.dif
	exit_test $errcode
    fi
}


del_disk_vol ()
# MappedName DriveLetter
{
    # Use net use/share command on NT to add new volume drive
    # This function assumes t, u, v and w drive letter are reserved for automation
    if [ "${SXR_PLATFORM}" = "nti" -o "${SXR_PLATFORM}" = "nta" ]; then
	# On NT, need to convert '/' to '\' in order to use net command
	echo "net use $2 /d /y" > cmd.$$
	echo "net share $1 /d /y" >> cmd.$$
	sh cmd.$$
    else
	rm "/tmp/${LOGNAME}/$1"
    fi
}


add_db_disk_vol ()
# AppName DbName Vol Vsize Ftype Fsize
{
    sxr esscmd -q smaladddskvol.scr %HOST=${SXR_DBHOST} %UID=${SXR_USER} %PWD=${SXR_PASSWORD} \
			%APP=$1 %DB=$2 %NDSKVOL=1 %VOL1=${3%:} %VSIZE1=$4 %FTYPE1=$5 %FSIZE1=$6
}


del_db_disk_vol ()
# AppName DbName VolNum
{
    sxr esscmd -q smaldeldskvol.scr %HOST=${SXR_DBHOST} %UID=${SXR_USER} %PWD=${SXR_PASSWORD} \
			%APP=$1 %DB=$2 %VOLNUM=$3
}


archive_db ()
# AppName DbName ArFile ArLog [ArOpt]
{
    sxr esscmd -q smbuardb.scr %HOST=${SXR_DBHOST} %UID=${SXR_USER} %PWD=${SXR_PASSWORD} \
			    %APP="$1" %DB="$2" %ARFILE="$3" %ARLOG="$4" %AROPT="${5:-n}"
}


restore_db ()
# AppName DbName ArcFile ArcLog Force NumVols [[old new]...]
{
    # Save first 5 arguments are for AppName DbName ArcFile Force NumVols
    _app=$1; shift
    _db=$1; shift
    _arc=$1; shift
    _log=$1; shift
    _force=$1; shift
    _numvol=$1; shift

    if [ -z "$1" ]; then
	_script=smburedb.scr
    else
	# Construct the rest as old/new volume pairs
	_replacevol=""
	while [ -n "$1" ]
	do
	    _old=`echo ${1%:} | sed 's/\//\\\\\//g'`
	    _new=`echo ${2%:} | sed 's/\//\\\\\//g'`
	    _replacevol=`echo ${_replacevol} \"${_old}\" \"${_new}\"`
	    shift; shift
	done

	# Copy script template to work directory
	_script=${SXR_WORK}/smburedb.scr
	sed "s/NDSKVOL\";/NDSKVOL\" ${_replacevol};/" `sxr which -scr smburedb.scr` > ${_script}
    fi

    # Execute the script
    sxr esscmd -q ${_script} %HOST=${SXR_DBHOST} %UID=${SXR_USER} %PWD=${SXR_PASSWORD} \
		%APP=$_app %DB=$_db %ARCFILE=$_arc %ARCLOG=$_log %FORCE=$_force %NDSKVOL=$_numvol
}


query_archive ()
# ArcFile FileOut Opt (1=Overview | 2=List disk volume)
{
    sxr msh smbuqryarchive.msh ${SXR_USER} ${SXR_PASSWORD} ${SXR_DBHOST} $1 $2 $3
}


list_trans ()
# AppName DbName OutFile FOpt [TOpt]
# where FOpt = 1|2 (Output to console)
#	       3|4 (Output to file)
#	TOpt = mm/dd/yyyy:00:00:00 | mm/dd/yy:00:00:00
{
    sxr esscmd -q smbulisttrans.scr %HOST=${SXR_DBHOST} %UID=${SXR_USER} %PWD=${SXR_PASSWORD} \
					%APP=$1 %DB=$2 %OFILE="${SXR_WORK}/$3" %FOPT=$4 %TOPT=$5
}


replay_trans ()
# AppName DbName OFile Opt [AfterTime | sequence_ids_file]
{
    sxr esscmd -q smbureplaytrans.scr %HOST=${SXR_DBHOST} %UID=${SXR_USER} %PWD=${SXR_PASSWORD} \
					%APP=$1 %DB=$2 %OFILE=$3 %OPT=$4 %ARG=$5
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
    _firstchar=`echo $1 | cut -c 1`
    _remain=`echo ${1#${_firstchar}}`
    echo "`echo $_firstchar | tr [a-z] [A-Z]`$_remain"
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
	grep -i "$1" $_logfile >> $_outfile 2>${SXR_NULLDEV}
	shift
    done
    touch $_outfile
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
    # Fix negative zero if any
    fix_neg_zero ${1}
}


# Convert Rolap MDX output file to handle values returned by different DBMS
# For example: DB2 and Oracle display the value 12000 as 12000
#		      while MSSQL displays it as 12000.0
rolap_output ()
{
    if [ "${DBMS}" == "sql" ]; then
	mv ${1} ${1}.tmp
	sed 's/\.0$//' ${1}.tmp > ${1}
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
	    _fname=$(basename $f .csv)
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
	    -e 's/^ .*\/APP\//MY_ESSBASE\/APP\//g' | ${AWK} '{print $1":"$2":"$3}' > tmp.$$
    mv tmp.$$ $1
}    


# Fix File Path
fix_file_path ()
{
    _filepath=`echo ${ARBORPATH} | sed 's/\//\\\\\//g'`
    cat $1 | sed -e 's/\\/\//g' -e 's/\/app\//\/APP\//g' \
	    -e "s/${_filepath}\/APP\/\([^ ]*\),/MY_ESSBASE\/APP\/\1,/g" \
	    -e "s/${_filepath}\/APP\/\([^ ]*\) *\([^ ]*\)/MY_ESSBASE\/APP\/\1        \2/g" \
	    -e "s/@Native Directory//" > tmp.$$
    mv tmp.$$ $1
}    


# Fix disk volume
fix_disk_vol ()
{
    _def=`echo $def | sed 's/\//\\\\\//g'`
    _DEF=`echo $_def | tr [a-z] [A-Z]`
    _vol1=`echo $vol1 | sed 's/\//\\\\\//g'`
    _vol2=`echo $vol2 | sed 's/\//\\\\\//g'`
    _vol3=`echo $vol3 | sed 's/\//\\\\\//g'`
    egrep "File .*: " $1 | sed -e '/Size/d' -e 's/\\/\//g' -e 's/\/app\//\/APP\//g' \
	-e "s/$_def\//DEF\//g" -e "s/$_DEF\//DEF\//g" -e "s/$_vol1\//VOL1\//g" \
	-e "s/$_vol2\//VOL2\//g" -e "s/$_vol3\//VOL3\//g" -e 's/\/.*\/APP\//\/APP\//g' > tmp.$$
    mv tmp.$$ $1
}    


# fix_arc_disk_vol
fix_arc_disk_vol ()
{
    _def=`echo $def | sed -e 's/://' -e 's/\//\\\\\//g'`
    _DEF=`echo $_def | tr [a-z] [A-Z]`
    _vol1=`echo $vol1 | sed -e 's/://' -e 's/\//\\\\\//g'`
    _vol2=`echo $vol2 | sed -e 's/://' -e 's/\//\\\\\//g'`
    _vol3=`echo $vol3 | sed -e 's/://' -e 's/\//\\\\\//g'`
    _work=`echo ${SXR_WORK} | sed 's/\//\\\\\//g'`
    cat $1 | sed -e 's/\\/\//g' -e "s/$_work\//ARCPATH\//" -e "s/ $_def *$/ DEF/" \
	-e "s/ $_DEF *$/ DEF/" -e "s/ $_vol1 *$/ VOL1/" -e "s/ $_vol2 *$/ VOL2/" \
	-e "s/ $_vol3 *$/ VOL3/" > tmp.$$
    mv tmp.$$ $1
}


# Display fixed hostname
# Equivalent to fixhost.sh
fix_host ()
{
    # handle short/long hostname with or w/o port like
    # host | host:port | host.domain.com | host.domain.com:port
    # add IPv4 and IPv6 support
    # replace IPv4 addresses with 'FIX_IPADDR' to be compatible with old baselines
	# replace IPv6 addresses with 'FIX_IPADDR' to be compatible with old baselines 
    dbhost=`echo $SXR_DBHOST | sed "s/\..*//"`
    lower=`echo $dbhost | tr [A-Z] [a-z]`
    upper=`echo $dbhost | tr [a-z] [A-Z]`
    cat $1 | sed -e 's!'$dbhost[\.a-zA-Z\:0-9]*[\ \t\n]*'!REPLACED_BY_FIXHOST !g' \
             -e 's!'$lower[\.a-zA-Z\:0-9]*[\ \t\n]*'!REPLACED_BY_FIXHOST !g' \
	     -e 's!'$upper[\.a-zA-Z\:0-9]*[\ \t\n]*'!REPLACED_BY_FIXHOST !g' \
	     -e 's!'dhcp-[a-zA-Z0-9\-]*[\ \t\n]*'!REPLACED_BY_FIXHOST !g' \
	     -e 's!'[\[]\:\:[1][]]:[0-9]*[\ \t\n]*'!REPLACED_BY_FIXHOST !g' \
		 -e 's!''[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\} *[\n^ ]''!FIX_IPADDR          !g' > $1.tmp
	cat $1.tmp | sed 's!''[a-zA-Z0-9]\{1,4\}\:\:[a-zA-Z0-9]\{1,4\}\:[a-zA-Z0-9]\{1,4\}\:[a-zA-Z0-9]\{1,4\} *''!FIX_IPADDR          !g' > $1.tmp.tmp	 
    mv $1.tmp.tmp $1
}


# Equivalent to fixversion.sh
fix_version ()
{
    # Version number format ex: 9.1.2 or 11.1.2.3
    sed -e 's!''[0-9]\{1,2\}\.[0-9]\{1,2\}\.[0-9]\{1,2\}\.[0-9]\{1,2\}   ''!FIX_VERSION!g' \
        -e 's!''[0-9]\{1,2\}\.[0-9]\{1,2\}\.[0-9]\{1,2\}     ''!FIX_VERSION!g' $1 > $1.tmp
    mv $1.tmp $1
}


# Fix negative zeros returned by some platforms
# Need to replace '-0' based on different cases
# case1 : if ',-0' is detected, replace it with ',0'
# case2 : if ' -0' is detected, replace it with '  0' (double spaces before 0)
fix_neg_zero ()
{
    sed -e 's/$/!/' -e 's/\([,]\)-0\([ ,!]\)/\10\2/g' -e 's/\([ ]\)-0\([ ,!]\)/\1 0\2/g' -e 's/!//' ${1} > ${1}.tmp
    mv ${1}.tmp ${1}
}


# Truncate function to eliminate difs caused by fraction
truncate ()
# InputFile [TruncateDigit]
{
    _ndec=10
    if [ -n "$2" ]; then _ndec=$2; fi
    if [ "${SXR_PLATFORM}" != "nti" -a "${SXR_PLATFORM}" != "nta" ]; then
	FORMATSTR="s/\([eE]\)\([+-]\)\([0-9][0-9]\)\([^0-9]*\)/\1\20\3\4/g"
    else
	FORMATSTR="s/\([eE]\)\([+-]\)\([0-9][0-9]\)\([^[0-9]]*\)/\1\20\3\4/g"
    fi
    cat ${1} | sed -e "s/\([.][0-9]\{$_ndec\}\)[0-9]*/\1/g" -e "${FORMATSTR}" -e 's/\([ ,]\)-0\([ ,]\)/\10\2/g' | tr -d '' > ${1}.tmp
    mv ${1}.tmp ${1}
}


#----------------------------------------------------------
# Function to check the status of the previous command.
# If the previous command fail then print message and exit.
# Arguments:
#  1. Status of the previous command.
#  2. Fail message.
#  3. Output file to display message.
#---------------------------------------------------------
ExitIfError()
{
   if [ $1 -ne 0 ]
   then
      echo "!!!FAILURE!!! $2 failed." | tee -a "$3"
      exit_test $1 
   fi
}


#
# Function to substitute variables inside a MaxL script with actual input values
#
sub_vars ()
{
# MaxLScript Arg1 Arg2 ... Arg9
    cp `sxr which -msh $1` ${SXR_WORK}
    _newscript=$1
    chmod 755 ${_newscript}
    shift

    # Create substitution script based on number of arguments
    _argc=1
    while [ -n "$1" ]
    do
	sed "s/\$`echo ${_argc}`/$1/g" ${_newscript} > tmp
	mv tmp ${_newscript}
	_argc=`expr ${_argc} + 1`
	shift
    done
}


#
# Function to get new public/private key
#
gen_new_key ()
{
    ${ARBORPATH}/bin/essmsh -gk > tmp.$$
    export PUBKEY=`grep -i 'public' tmp.$$ | sed 's/^.*: //'`
    export PRIVKEY=`grep -i 'private' tmp.$$ | sed 's/^.*: //'`
    rm tmp.$$
}


# Function to run cksum and compare result
check_sum()
{
# CksumFile CksumOut [CksumBaseLine]
    # Replace -0 by 0 and remove all decimal fractions
    #cat $1 |  sed -e 's/\.[0-9eE+-]*//g' -e 's/\([ ,]\)-0\([ ,]\)/\10\2/g' | tr -d '' > $1.tmp
    cp $1 $1.tmp
    truncate $1.tmp
    cksum $1.tmp | ${AWK} '{print $1 $2}' > $2
    sxr diff $2 $3
}


# Function to terminate a request after a timeout expires
abort_request ()
{
    # Wait for input delay before terminating the client request
    sleep $1

    # Abort all client requests from ESSCMD/essmsh
    ps -fu ${LOGNAME} | grep -v grep | grep $2 | ${AWK} '{ print $2 }' > .pid

    while read pid
    do
	kill -9 $pid > /dev/null
    done < .pid
}


# Function to check if the agent is ready
ping_agent ()
# DelayTime
{
    # Wait for $1 seconds
    sleep $1

    # Start abort_request in background just in case command is hung
    abort_request 30 essmsh &
    pid=$!

    echo "display system version;" | essmsh -l "${SXR_USER}" ${SXR_PASSWORD} -s ${SXR_DBHOST} -i > /dev/null 2>&1

    if [ $? -eq 0 ]; then
	kill -9 $pid
	echo "0"
    else
	echo "1"
    fi
}


# Function to crash agent/server
xcpt ()
# AppName DBName XCPType
{
    sxr esscmd -q msxxxcpt.scr %HOST=${SXR_DBHOST} %UID="${SXR_USER}" %PWD=${SXR_PASSWORD} %APP="$1" %DB="$2" %XCPTYPE="$3"
}


# Function to perform/clean up after each test
exit_test ()
# ErrorCode
{
    # Make sure the agent is up
    sxr agtctl start

    # Restore the default ${SXR_USER} if changed during test
    if [ "${SXR_USER}" != "${SXR_USER_BAK}" ]; then 
	export SXR_USER="${SXR_USER_BAK}" 
    fi
    if [ "${SXR_PASSWORD}" != "${SXR_PASSWORD_BAK}" ]; then 
	export SXR_PASSWORD="${SXR_PASSWORD_BAK}" 
    fi

    # Call clean up function
    clean_up

    # Unload all running app if any
    sxr msh msxxunloadappall.msh ${SXR_USER} ${SXR_PASSWORD} ${SXR_DBHOST}

    # Restore the original essbase.cfg if modified
    if [ -f ${FILE}.cfg ]; then
        rename_cfg ${FILE}.cfg essbase.cfg
        sxr agtctl stop
    fi

    # Return input errorcode
    exit $1
}


# Function to clean up
clean_up ()
{
    # This acts like a virtual function
    # If a test needs to perform some cleanup, overwrite it
    : do nothing
}


# Function to list existing applications in system
list_application ()
{
# outputFile
    echo  "display application;" | essmsh -l $SXR_USER $SXR_PASSWORD -s $SXR_DBHOST -i | \
    ${AWK} 'BEGIN { isIncluded = 0 }
    {
       if ($1 ~ /^[+]/) { isIncluded = 1 }
       else if (isIncluded == 1 && length == 0) { isIncluded = 0 }
       else if (isIncluded == 1 && length > 0) { print substr($0,1,20) }
    }' > "$1"
}


# Function to list existing variables in system
list_variable ()
{
# outputFile
    echo  "display variable;" | essmsh -l $SXR_USER $SXR_PASSWORD -s $SXR_DBHOST -i | \
    ${AWK} 'BEGIN { isIncluded = 0 }
    {
       if ($1 ~ /^[+]/) { isIncluded = 1 }
       else if (isIncluded == 1 && length == 0) { isIncluded = 0 }
       else if (isIncluded == 1 && length > 0) { print substr($0,1,20) }
    }' > "$1"
}


# Function to list existing users/groups in system
list_security ()
{
# outputFile
    echo  "display user;" | essmsh -l $SXR_USER $SXR_PASSWORD -s $SXR_DBHOST -i | \
    ${AWK} 'BEGIN { isIncluded = 0 }
    {
       if ($1 ~ /^[+]/) { isIncluded = 1 }
       else if (isIncluded == 1 && length == 0) { isIncluded = 0 }
       else if (isIncluded == 1 && length > 0) { print substr($0,1,20) }
    }' | sed "/$SXR_USER /d" > "$1"

    echo  "display group;" | essmsh -l $SXR_USER $SXR_PASSWORD -s $SXR_DBHOST -i | \
    ${AWK} 'BEGIN { isIncluded = 0 }
    {
       if ($1 ~ /^[+]/) { isIncluded = 1 }
       else if (isIncluded == 1 && length == 0) { isIncluded = 0 }
       else if (isIncluded == 1 && length > 0) { print substr($0,1,20) }
    }' >> "$1"
}


# Function to remove existing applications/securities from the final output
exclude_from_output ()
{
# itemList outputFile [col=0, [width=20]]

   # The excluded items such as existing users, groups, applications or variables are displayed in 
   # different columns by different display commands. When excluding them, we need to specify the 
   # column's number and the column's width of these items. 
   # The default column for user|group|appplication is the 1st column with width=20

   while read line
   do
      ${AWK} -v Item="$line" -v Col="${3:-0}" -v Width="${4:-20}" 'BEGIN { isExcluded = 0; Name = "" }
      {
         if ($1 ~ /^[+]/) { isExcluded = 1; print }
         else if (length == 0) { isExcluded = 0; print }
         else if (isExcluded == 0) { print }
         else {
            Name = substr($0, Col, Width)  # Assign Name with the first 20 chars (default column width)
            gsub(/^ *| *$/, "", Name)      # Trip all leading and trailing spaces
            if (Name != Item) { print }
         }
      }' < "$2" > "$2.tmp"
      mv "$2.tmp" "$2"
   done < "$1"
}


############################################################################
# !!!ATTENTION!!! This module MUST be loaded at the end of this file
# If you need to add additional functions, please make sure that they are added
# before this section

# Security version (0=Native,1=HSS,2=BI)

export SECURITY_NATIVE=0
export SECURITY_HSS=1
export SECURITY_BI=2

if [ ! -f security.ver ]; then
   # Check your Essbase security model here
   if [ "${HYPERION_HOME##/*/}" = "Oracle_BI1" ]; then
      EPMSYS_REGISTRY="`find ${HYPERION_HOME}/../instances -name "epmsys_registry.*"`"
      if [ -f "${EPMSYS_REGISTRY}" ]; then
         SECURITY_VERSION=`${EPMSYS_REGISTRY} view SHARED_SERVICES_PRODUCT/@security_version | grep security | ${AWK} '{print $3}' 2>${SXR_NULLDEV}`
      fi
   elif [ "${HYPERION_HOME##/*/}" = "EPMSystem11R1" -a "${ARBORPATH}" != "${ESSBASEPATH}" ]; then
      SECURITY_VERSION=${SECURITY_HSS}
   fi
   # Set security version and write to file
   echo ${SECURITY_VERSION:-${SECURITY_NATIVE}} > security.ver
fi

# Include the specific module based on the security model
export SECURITY_VERSION=`cat security.ver`
if [ ${SECURITY_VERSION} -eq ${SECURITY_BI} ]; then
   . `sxr which -sh bi.func`
elif [ ${SECURITY_VERSION} -eq ${SECURITY_HSS} ]; then
   . `sxr which -sh hss.func`
fi
