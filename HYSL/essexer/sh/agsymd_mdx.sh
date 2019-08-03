#:
#: Purpose:  Test Metadataseurity for MDX/maxl
#:           user  name: usermdx
#:           filter access: MetaRead: @IDESCENDANTS("East"),"California",
#:
#: Author:           Andrew Zhang
#: Date created:     July 11, 2006
#: Tag:
#: Dependencies:
#: Runnable:         true
#: Arguments:        none
#: Test Information:
#:    Estimate run-time -        30 sec.
#:    Memory/Disk space -        5M
#:    Number of suc files -       9
#:
#: Modification History:
#:    12/10/2012 vgee - Added ignore for user name and password.
#:
#--------------------------------------------------------------
#  1. Check the basic correctness of MDX / Maxl
#      "MAXL> Select [Market].members on columns from Agsymdx.Basic;"  etc
#
#  2. Error case  "Select South.children on columns From Sample.basic;"
#
#  Bug found:   71250
#
###############################################################################

APP01=Agsymdx
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
                            %PWD=$SXR_PASSWORD %APP=$1 %DB=$2
}

retrieve ()
{
echo "In retrieve, para = $1, $2, $3, $4, $5, $6, $7";
export SXR_ESSCMD='ESSCMDG'
sxr esscmd msxxrtv.scr %HOST=$SXR_DBHOST %USER=$7 \
		       %PASSWD=$SXR_PASSWORD %APPNAME=$1 %DBNAME=$2 \
                       %INITROW=65000 %INITCOL=250 %RTVIN=$3 %COL=$4 \
		       %ROW=$5 %RTVOUT=$6
export SXR_ESSCMD='ESSCMD'
}


clear_data ()
{
# ApplicationName DatabaseName
sxr esscmd msxxresetdb.scr  %HOST=$SXR_DBHOST %UID=$SXR_USER \
                            %PWD=$SXR_PASSWORD %APP=$1 %DB=$2
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

# Copy dataload file to the application database dir
copy_file_to_db $DATA $APP01 $DB01

clear_data $APP01 $DB01

# Load data to database
load_data $APP01 $DB01 $DATA


###########################################################
#  Part 1:  run MDX Basic
###########################################################

# Created user
export SXR_ESSCMD='essmsh'
sxr esscmd agsycremduserMDX.mxl %1=agsycremduserMDX1.out %2=usermdx1 \
                         %3=password
export SXR_ESSCMD='ESSCMD'

# Created filter
export SXR_ESSCMD='essmsh'
sxr esscmd agsycremdfilter.mxl %1=agsycrefiltMDX1.out %2=$APP01 \
                         %3=$DB01 %4=filter_MDX1 \
                       	 %5="@IDESCENDANTS("East"), California"
 export SXR_ESSCMD='ESSCMD'

# Grant permission
export SXR_ESSCMD='essmsh'
sxr esscmd agsymdgrantuser.mxl %1=agsymdgrantuser_MDX1.out %2=$APP01 \
                         %3=$DB01 %4=filter_MDX1 %5=usermdx1
export SXR_ESSCMD='ESSCMD'

# run basic MDX:

export SXR_ESSCMD='essmsh'
sxr esscmd agsymdMDX1-1.mxl  %1=agsymdMDX1-1.out  %2=userMDX1  %3=password
export SXR_ESSCMD='ESSCMD'


export SXR_ESSCMD='essmsh'
sxr esscmd agsymdMDX1-2.mxl  %1=agsymdMDX1-2.out  %2=userMDX1  %3=password
export SXR_ESSCMD='ESSCMD'

export SXR_ESSCMD='essmsh'
sxr esscmd agsymdMDX1-3.mxl  %1=agsymdMDX1-3.out  %2=userMDX1  %3=password
export SXR_ESSCMD='ESSCMD'

# Error case:
export SXR_ESSCMD='essmsh'
sxr esscmd agsymdMDX1-err.mxl  %1=agsymdMDX1-err.out  %2=userMDX1  %3=password
export SXR_ESSCMD='ESSCMD'

compare_result   agsycrefiltMDX1.out      agsycrefiltMDX1.bas
compare_result   agsycremduserMDX1.out    agsycremduserMDX1.bas
compare_result   agsymdgrantuser_MDX1.out agsymdgrantuser_MDX1.bas
compare_result   agsymdMDX1-1.out         agsymdMDX1-1.bas
compare_result   agsymdMDX1-2.out         agsymdMDX1-2.bas
compare_result   agsymdMDX1-3.out         agsymdMDX1-3.bas

compare_result   agsymdMDX1-err.out      agsymdMDX1-err.bas

# Cleaning..

# Delete user
export SXR_ESSCMD='essmsh'
sxr esscmd agsymddeluserMDX.mxl %1=agsymddeluserMDX1.out %2=usermdx1
export SXR_ESSCMD='ESSCMD'

compare_result   agsymddeluserMDX1.out  agsymddeluserMDX1.bas

# Delete filter
export SXR_ESSCMD='essmsh'
sxr esscmd agsymddelfilt.mxl  %1=agsymddelfiltMDX1.out %2=$APP01 %3=$DB01 \
                              %4=filter_MDX1
export SXR_ESSCMD='ESSCMD'

compare_result   agsymddelfiltMDX1.out  agsymddelfiltMDX1.bas

#Delete Application
delete_app $APP01

