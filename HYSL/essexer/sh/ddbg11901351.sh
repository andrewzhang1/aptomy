#: Authors: Andrew Zhang
#: Date: 08/29/12 
#: Purpose:   Automation of Bug #11901351
#: Test cases: create user, filter , and load date with empty cells 
#: Component/Sub Comp: Server Administration/Data load
#: Owned by: Andrew Zhang
#: Tag: Bug NORMR
#: Dependencies: esscmd.func
#: Runnable: true
#: Arguments: none
#: Memory/Disk: 200MB/200MB
#: SUC: 6
#: Created for: 11.1.2.2.500 (Baseline is based on this release)
#: Retired for:
#: Test time:  3 minutes
#: History:
#:     vgee 10/09/2012 - Added delete user to end of script.
#:     vgee 10/25/2012 - Fixed hardcoded name in msxxexport.scr
#:
###############################################

#  Start agent if not already started
sxr agtctl start

###############################################
# Include shared functions section
. `sxr which -sh esscmd.func`


#########################
#Variable Section: 
#########################

APP=11901351
DB=11901351
FILE=11901351
FILE1=11901351a

###################
#  Begin the test #
###################

# Create BSO application
sxr newapp -force ${APP}

# Create BSO database with local copy outline
sxr newdb -force -otl ${FILE}.otl ${APP} ${DB}


# Copy spreadsheet file to the sxr work dir

Copy dataload file to the application database dir
copy_file_to_db ${FILE}.txt $APP $DB
copy_file_to_db ${FILE1}.txt $APP $DB
copy_file_to_db ${FILE}.rul $APP $DB

compare_result ()
{
# OutputFileName BaselineFileName (by pair)
sxr diff -ignore "Average Clust.*$" -ignore "Average Fragment.*$" \
	 -ignore '\[... .*$' -ignore '\[... .*$' -ignore 'Last login .*$' \
         -ignore 'process id .*$' \
         -ignore 'Elapsed Time .*$' \
         -ignore '\[... .*$' -ignore 'Logging out .*$' \
	 -ignore 'Average Fragmentation Quotient .*$' \
	 -ignore "essexer" \
	 -ignore "$SXR_USER" \
	 $1  $2

if [ $? -eq 0 ]
     then
			 echo ""
			 echo "Success comparing $1"
     else
			 echo ""
			 echo "Failure comparing $1"
fi
}

# 1. Created user mduser1 
export SXR_ESSCMD='essmsh'
sxr esscmd ddbg11901351creuser1.mxl %UID=${SXR_USER} %PWD=${SXR_PASSWORD} \
                                    %HOST=${SXR_DBHOST}
export SXR_ESSCMD='ESSCMD'


# 2. Created filter
export SXR_ESSCMD='essmsh'
sxr esscmd ddbg11901351creflt.xml   %UID=${SXR_USER} %PWD=${SXR_PASSWORD} \
                                    %HOST=${SXR_DBHOST}
export SXR_ESSCMD='ESSCMD'


# 3. Grant permission
export SXR_ESSCMD='essmsh'
sxr esscmd ddbg11901351grtflt.xml   %UID=${SXR_USER} %PWD=${SXR_PASSWORD} \
                                    %HOST=${SXR_DBHOST}
export SXR_ESSCMD='ESSCMD'


# 4. Load data file with empty cell and with rule file:
export SXR_ESSCMD='essmsh'
sxr esscmd ddbg11901351loaddata.mxl %HOST=${SXR_DBHOST}
export SXR_ESSCMD='ESSCMD'

reset_db $APP $DB

# 5. Load data file with actual data and with rule file:
export SXR_ESSCMD='essmsh'
sxr esscmd ddbg11901351loaddata1.mxl %HOST=${SXR_DBHOST}
export SXR_ESSCMD='ESSCMD'

# 6. Make a full export  for comparison:
sxr esscmd msxxexport.scr %HOST=${SXR_DBHOST} %UID=${SXR_USER} \
                          %PWD=${SXR_PASSWORD} %APP=${APP} %DB=${DB} \
                          %FNAME=${FILE}_6.out %OPT="1"

# 8. Move exported data by para import for verifying the correctness:
mv $ARBORPATH/app/${FILE}_6.out  $SXR_WORK/ddbg11901351_6.out

#reset_db $APP $DB
compare_result ddbg11901351_1.out ddbg11901351_1.bas
compare_result ddbg11901351_2.out ddbg11901351_2.bas
compare_result ddbg11901351_3.out ddbg11901351_3.bas
compare_result ddbg11901351_4.out ddbg11901351_4.bas
compare_result ddbg11901351_5.out ddbg11901351_5.bas
compare_result ddbg11901351_6.out ddbg11901351_6.bas

# Cleaning..

# Delete user
export SXR_ESSCMD='essmsh'
sxr esscmd agsymddeluser1.mxl %1=mduser1
export SXR_ESSCMD='ESSCMD'

# Delete filter
export SXR_ESSCMD='essmsh'
sxr esscmd agsymddelfilt.mxl  %1=agsymddelfiltMDX1.out %2=$APP %3=$DB \
                              %4=F1
export SXR_ESSCMD='ESSCMD'

#Delete Application
delete_app $APP





