#: Script: dmbg16222309.sh
#: Authors: Andrew Zhang
#: Date: 04/29/2013 
#: Purpose:   Automation of Bug #16222309: 
#             16222309 - ESSBASE CALCULATIONS HANG AFTER UPGRADING GLIBC ON LINUX    
#  Test cases: UTF8 app, Calc, export 
#: Component/Sub Comp: Data load/BSO
#: Owned by: Andrew Zhang
#: Tag: Bug NORMR
#: Dependencies: esscmd.func
#: Runnable: true
#: Arguments: none
#: Customer name: VTB CAPITAL,CJSC
#: Memory/Disk: 200MB/200MB
#: Execution Time (minutes): 2
#: SUC: 1
#: Created for: 11.1.2.0.000  (Baseline is based on this release)
#: Retired for:
#: Test time: 3 minutes 
#: History: 
# 
#  
#  Have not checked in yet
#
###############################################

#  Start agent if not already started

sxr agtctl start

###############################################
# Include shared functions section
. `sxr which -sh esscmd.func`

#########################
#Variable Section: 
#########################

APP=Dmbg16222309utf8
DB=PLAN1
OTL=PLAN1
CALC=ddbg16222309.csc
FILE=Dmbg16222309

# Create the application/db
#--------------------------

# For creating Unicode enabled app, as the otl file is utf-8 enabled.

export SXR_MLCAPP=1
export ESSCMDQ_UTF8MODE=1

sxr agtctl start
#  create_app $APP
   sxr newapp -utf8  ${APP}
   sxr newdb  -otl ${OTL}.otl ${APP} ${DB}
 
   copy_file_to_db `sxr which -csc $CALC` $APP $DB

   # Run each calc for exporting data
     runcalc_custom $APP $DB ${CALC}

# If successfully done in a minute, do an full export to compare the result

   sxr esscmd msxxexport.scr %HOST=${SXR_DBHOST} %UID=${SXR_USER} \
                          %PWD=${SXR_PASSWORD} %APP=${APP} %DB=${DB} \
                          %FNAME=${FILE}.out %OPT="1"

#  Move exported data by para import for verifying the correctness:
   mv $ARBORPATH/app/${FILE}.out  $SXR_WORK
	
# Compare result
   sxr diff ${FILE}.out ${FILE}.bas

# Clear data
   reset_db $APP $DB

#-------------------------------------
# Check for other errors and clean up.
#-------------------------------------

# Get application log file.
applog_copy $APP ${APP}.log

# Check for any error in the app log file.
grep -ie "xcp" -ie "abnormal" -ie "fatal" ${APP}.log
if [ $? -eq 0 ]
then
	echo "*** Error in app log!" | tee -a ${TestFile}.log | tee -a ${TestFile}.dif
    #Unload app
    unload_app $APP
else
   echo "*** App log verification passed!" | tee -a ${TestFile}.log
    # Delete app
  delete_app $APP
fi


