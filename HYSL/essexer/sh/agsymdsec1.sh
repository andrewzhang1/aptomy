#: Authors: Andrew Zhang
#: Reviewers:
#: Date: 3/13/03 
#: Purpose:    Test Metadata securtiy for new filter definitio: MetaRead
#: Test cases: See Feature test below 
#                   
#  1. Check the correctness of the navigation of the member and dimensions,
#     include zoom-in and out, data retrieval
#  2. Layers and components supported by MetaRead:
#     Query Extractor, Member Selection (By Vivian using Silk)
#     Report Extractor,
#     Lock-n-Send.
#  4. Error Cases:
#     - Part One: "Unknown Member" for members without access
#     - Part Two: "Unknown Member" for member does not existed in the outline
#
#: Component/Sub Comp: Server Administration/Essbase Security
#: Owned by: Andrew Zhang
#: Tag: NORMR
#: Dependencies: esscmd.func
#: Runnable: true
#: Arguments: none
#: Memory/Disk: 200MB/200MB
#: SUC: 14
#: Created for: 7.1
#: Retired for:
#: Test time:  5 minutes
#: History:
# 02/05/2006 Andrew Zhang
#            Updated for the common log of kennedy features
#
# 02/19/2008 Van Gee
#            Removed references to ARBORPATH
#

APP01=Agsymd1
DB01=Basic
OTL=agsymd
DATA=agsymd.txt

#Start Agent
sxr agtctl start

create_app ()
{
echo "In create_app, para = $1"
sxr newapp -force $1
}

create_db ()
{
echo "In create_db, para = $1, $2, $3"
sxr newdb -otl $1 $2 $3
}

copy_file_to_work ()
{
echo "In copy_file_t_work, para = $1"
sxr fcopy -in -data $1
}

copy_file_to_db ()
{
echo "In copy_file_t_db, para = $1, $2, $3"
sxr fcopy -in -data $1 -out !$2!$3!
}

load_data ()
{
echo "In load_data, para = $1, $2 $3"
sxr esscmd msxxloaddataserver.scr %HOST=$SXR_DBHOST %USER=$SXR_USER\
                            %PASSWD=$SXR_PASSWORD %APPNAME=$1\
                            %DBNAME=$2 %LOADDATA=$3
}

runcalc_default ()
{
echo "In runcalc_default,  para = $1, $2"
# ApplicationName DatabaseName
sxr esscmd msxxrundefaultcalc.scr %HOST=$SXR_DBHOST %UID=$3 \
                            %PWD=password %APP=$1 %DB=$2
}

retrieve ()
{
echo "In retrieve, para = $1, $2, $3, $4, $5, $6, $7";
export SXR_ESSCMD='ESSCMDG'
sxr esscmd msxxrtv.scr      %HOST=$SXR_DBHOST %USER=$7 \
		            %PASSWD=password %APPNAME=$1 %DBNAME=$2 \
                            %INITROW=65000 %INITCOL=250 %RTVIN=$3 %COL=$4 \
		            %ROW=$5 %RTVOUT=$6 \
export SXR_ESSCMD='ESSCMD'
}


clear_data ()
{
# ApplicationName DatabaseName
sxr esscmd msxxresetdb.scr  %HOST=$SXR_DBHOST %UID=$SXR_USER \
                            %PWD=$SXR_PASSWORD %APP=$1 %DB=$2
}

#  Alternated to add SetGridOption to 0 2
zoom_in ()
{
echo "In zoom_in, para = $1 $2 $3 $4 $5 $6 $7 $8 $9 $10"
export SXR_ESSCMD='ESSCMDG'
sxr esscmd msxxzoomin_mduser1.scr %HOST=$SXR_DBHOST %USER=mduser1 \
                            %PASSWD=password %APPNAME=$1 \
	                    %DBNAME=$2 %INITROW=65000 %INITCOL=250 \
	                    %ZIN=$3 %TROW=$4 %TCOL=$5 %ZROW=$6 %ZCOL=$7 \
	                    %ZLEV=$8 %ZOUTP=$9 %ZOPT=1
export SXR_ESSCMD='ESSCMD'
}

# Lock and send
lock_send ()
{
# ApplicationName DatabaseName LockAndSendFileName TotalRowsInFile 
# TotalColumnsInFile
echo "In Lock and Send para = $1, $2 $3 $4 $5 $6"

export SXR_ESSCMD='ESSCMDG'
sxr esscmd msxxlockandsend_md.scr  %HOST=$SXR_DBHOST %USER=$6 \
                            %PASSWD=password \
                            %APPNAME=$1 %DBNAME=$2 %INITROW=65000 \
                            %INITCOL=250 %UPDATE=$3 %ROW=$4 %COL=$5
export SXR_ESSCMD='ESSCMD'
}

unload_app ()
{
echo "In unload_app, para = $1"
sxr esscmd msxxunap.scr     %HOST=$SXR_DBHOST %USER=$SXR_USER \
                            %PASSWD=$SXR_PASSWORD %APP=$1
}

delete_app ()
{
sxr esscmd msxxrmap.scr     %HOST=$SXR_DBHOST %USER=$SXR_USER \
                            %PASSWD=$SXR_PASSWORD %APP=$1
}

run_report ()
{
echo "In run_report = $1, $2, $3"
sxr esscmd msxxreport.scr   %HOST=$SXR_DBHOST %USER=$1 %PASSWD=password \
                            %APPNAME=$2 %DBNAME=$3 %REPORT=$4 %RPTOUT=$5
}

compare_result ()
{
# OutputFileName BaselineFileName (by pair)
sxr diff -ignore "Average Clust.*$" -ignore "Average Fragment.*$" \
	 -ignore '\[... .*$' -ignore '\[... .*$' -ignore 'Last login .*$' \
         -ignore 'process id .*$' \
         -ignore 'Total Calc Elapsed Time .*$' \
         -ignore '\[... .*$' -ignore 'Logging out .*$' \
	 -ignore 'Average Fragmentation Quotient .*$' \
	 -ignore "essexer" \
	 -ignore "$SXR_USER" \
	 $1  $2

if [ $? -eq 0 ]
     then
			 echo ""
			 echo Success comparing $1
     else
			 echo ""
			 echo Failure comparing $1
fi
}


###################
#  Begin the test #
###################

sxr agtctl start

# Create an application
create_app $APP01

# Create db dbtest1 under application test1
create_db ${OTL}.otl $APP01 $DB01

# Copy spreadsheet file to the sxr work dir
copy_file_to_work agsymdrv1-1.txt
copy_file_to_work agsymdrv1-3.txt
copy_file_to_work agsymdrv1-4.txt
copy_file_to_work agsymdlocksend1.txt
copy_file_to_work agsymderror1.txt

# Copy dataload file to the application database dir
copy_file_to_db $DATA $APP01 $DB01
sxr fcopy -in -rep agsymd1.rep -out !$APP01!$DB01!

clear_data $APP01 $DB01

# Load data to database
load_data $APP01 $DB01 $DATA

# runcalc_default  $APP01 $DB01 essexer

# Created user
export SXR_ESSCMD='essmsh'
sxr esscmd agsycremduser1.mxl %1=mduser1 %2=password
export SXR_ESSCMD='ESSCMD'

# Created filter
export SXR_ESSCMD='essmsh'
sxr esscmd agsycremdfilter1.mxl
export SXR_ESSCMD='ESSCMD'

# Grant permission
export SXR_ESSCMD='essmsh'
sxr esscmd agsymdgrantuser1-1.mxl %1=mduser1
export SXR_ESSCMD='ESSCMD'

###########################################################
#
#  Case 1:  Basic retrieval
#
###########################################################

# Retrieve spreadsheet
retrieve $APP01 $DB01 agsymdrv1-1.txt 5 2 agsymdsec1-1.out mduser1

# ZoomIn on member Market
zoom_in $APP01 $DB01 agsymdrv1-1.txt 2 5 0 3 1 agsymdsec1-2.out

		# "" mduser1 #essexer

# ZoomIn on member East
zoom_in $APP01 $DB01 agsymdrv1-3.txt 4 5 1 0 1 agsymdsec1-3.out

# ZoomIn on member West
zoom_in $APP01 $DB01 agsymdrv1-4.txt 6 5 4 0 1 agsymdsec1-4.out

#  Clear data


###########################################################
#
#  Case 2:  Report Extractor
#
###########################################################

run_report  mduser1 $APP01 $DB01   agsymd1  agsymdreport1-1.out


###########################################################
#
#  Case 3:  Lock and Send
#
###########################################################

# Grant permission of Database access to mdusr1 in order to run lock & send

export SXR_ESSCMD='essmsh'
sxr esscmd agsymdgrantuser1.mxl %1=mduser1
export SXR_ESSCMD='ESSCMD'


# Lock and send
lock_send   $APP01 $DB01 agsymdlocksend1.txt   10 6  mduser1

# Rundefaul calc
runcalc_default  $APP01 $DB01 mduser1

# Retrieve spreadsheet
retrieve $APP01 $DB01 agsymdlocksend1.txt  6 10  agsymdlocksend-1.out mduser1

###########################################################
#
#  Case 4:  Error case
#
###########################################################

retrieve $APP01 $DB01 agsymderror1.txt 9 21 agsymderror1.out mduser1

sxr esscmd -q msxxgetlog.scr %HOST=$SXR_DBHOST %UID=$SXR_USER \
                             %PWD=$SXR_PASSWORD %APP=Agsymd1 \
                             %LOG=agsymdsec1.log

grep -i "The sheet contains an unknown member: Pacific"	\
        agsymdsec1.log > agsymderror2.out
grep -i "The sheet contains an unknown member: South" \
        agsymdsec1.log >> agsymderror2.out
grep -i "The sheet contains an unknown member: Massachusetts" \
        agsymdsec1.log >> agsymderror2.out
grep -i "The sheet contains an unknown member: Connecticut" \
        agsymdsec1.log >> agsymderror2.out
grep -i "The sheet contains an unknown member: New Hampshire" \
        agsymdsec1.log >> agsymderror2.out
grep -i "The sheet contains an unknown member: Washington" \
        agsymdsec1.log >> agsymderror2.out
grep -i "The sheet contains an unknown member: Utah" \
        agsymdsec1.log >> agsymderror2.out
grep -i "The sheet contains an unknown member: Nevada" \
        agsymdsec1.log >> agsymderror2.out

#  Compare results:

compare_result   agsycremduser1.out    agsycremduser1.bas
compare_result   agsycremdfilt1.out    agsycremdfilt1.bas
compare_result   agsymdgrantuser1.out  agsymdgrantuser1.bas
compare_result   agsymdgrantuser1-1.out  agsymdgrantuser1-1.bas

compare_result   agsymdsec1-1.out agsymdsec1-1.bas
compare_result   agsymdsec1-2.out agsymdsec1-2.bas
compare_result   agsymdsec1-3.out agsymdsec1-3.bas
compare_result   agsymdsec1-4.out agsymdsec1-4.bas
compare_result   agsymdlocksend-1.out agsymdlocksend-1.bas
compare_result   agsymdreport1-1.out  agsymdreport1-1.bas
compare_result   agsymderror1.out  agsymderror1.bas
compare_result   agsymderror2.out  agsymderror2.bas


# Cleaning..

# Delete user
export SXR_ESSCMD='essmsh'
sxr esscmd agsymddeluser1.mxl %1=mduser1
export SXR_ESSCMD='ESSCMD'

compare_result   agsymddeluser1.out      agsymddeluser1.bas

# Delete filter
export SXR_ESSCMD='essmsh'
sxr esscmd agsymddelfilt1.mxl
export SXR_ESSCMD='ESSCMD'

compare_result   agsymddelfilt1.out      agsymddelfilt1.bas

#Delete Application
delete_app $APP01


