#: Authors: Andrew Zhang
#: Date: 08/29/12 
#: Purpose:   Automation of Bug #13883641: DATAEXPORT COMMAND IN CALC CHANGES MEMBER NAME IN EXPORT FILE 
#  Test cases:  
#: Component/Sub Comp: Calc/export
#: Owned by: Andrew Zhang
#: Tag: Bug
#: Dependencies: esscmd.func
#: Runnable: true
#: Arguments: none
#: Memory/Disk: 200MB/200MB
#: SUC: 6
#: Created for: 11.1.2.2.500 (Baseline is based on this release)
#: Retired for:
#: Test time:  
#: History:
# 
# Note: The test generate 2 dif currently due the the bug is still at open status
#       I will modify the test when the bug is fixed.#
#  
# 02/19 Andrew Zhang, the bug 13883641 was fixed, modify the test so it
#                     show two suc files.
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

APP=13883641
DB=13883641
OTL=13883641
#DATA=dmbg13883641
DATA=dmbg13883641.txt
DATA1=dmbg13883641_export1.txt
CALC=dmbg13883641.csc

# Create the application/db
#--------------------------

create_app $APP
create_db $OTL.otl $APP $DB

  copy_file_to_db `sxr which -data $DATA` $APP $DB
	copy_file_to_db `sxr which -csc $CALC` $APP $DB

#  chmod 755 $ARBORPATH/app/$APP/$DB/*csc

#Load data to database
#----------------------
load_data $APP $DB ${DATA}


	# Run each calc for exporting data
	runcalc_custom $APP $DB ${CALC}

	# The output by calc will be compared by baseline
	cp $ARBORPATH/app/dmbg13883641_export.out $SXR_VIEWHOME/data/dmbg13883641_export1.txt
	
	copy_file_to_db `sxr which -data $DATA1` $APP $DB
  
  mv $ARBORPATH/app/dmbg13883641_export.out $SXR_WORK/dmbg13883641_export1.out
	
	
	# Compare result
	sxr diff dmbg13883641_export1.out  dmbg13883641_export.bas


  # Clear data
  reset_db $APP $DB


# reload data exported by the calc script:

load_data $APP $DB ${DATA1}
	
#	exit

# If successfully load from above step, it will re-export:
  
	runcalc_custom $APP $DB ${CALC}

	mv $ARBORPATH/app/dmbg13883641_export.out $SXR_WORK/dmbg13883641_export2.out

	sxr diff dmbg13883641_export2.out  dmbg13883641_export.bas


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
    #Delete app
    delete_app $APP
fi


