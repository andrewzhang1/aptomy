#: Authors: Andrew Zhang
#: Reviewers: 
#: Date: 06/05/06
#: Purpose: 	Test export data by using conditional test
#: Test cases: 
#    	Case(calc) Number	Condition placed on 	With ReplaceALL
#	    -------------------------------------------------------------------
#	    ddxi5011.csc	Column dense member only	No
#	    ddxi5012.csc	Column dense member only	Yes
#	    ddxi5013.csc	Row member only			No
#	    ddxi5014.csc	Row member only			Yes
#	    ddxi5015.csc	Sparse dimension	 	No
#	    ddxi5016.csc	Sparse dimension		Yes
#
#: Component/Sub Comp: Calculator/Calc
#: Owned by: Andrew Zhang
#: Tag: NORMR 
#: Dependencies: esscmd.func
#: Runnable: true
#: Arguments: none
#: Memory/Disk: 200MB/200MB
#: SUC: 6
#: Created for: beckett
#: Retired for:
#: Test time: 3 minutes
#: History:

#-------------------------
# Include shared functions
#-------------------------

 . `sxr which -sh esscmd.func`

#-----------------------
#Constants and Variables
#-----------------------
APP=Ddxic501
DB=Basic
OTL=agsymd
DATA=agsymd.txt

CALC=ddxi501 	     # variable name for the first part of the calc script
TestFile=ddxicalc501 # variable name for the error output


compare_result ()
{
# OutputFileName BaselineFileName (by pair)
sxr diff  $1  $2

if [ $? -eq 0 ]
     then
                         echo ""
       echo Success comparing $1
     else
                         echo ""
       echo Failure comparing $1
fi
}

sxr agtctl start

# Create the application/db
#--------------------------

create_app $APP
create_db $OTL.otl $APP $DB

#Load data to database
#----------------------

copy_file_to_db `sxr which -data $DATA` $APP $DB
load_data $APP $DB $DATA
runcalc_default $APP $DB

# Run export by calc at three options
#--------------------------------------

#Using the loop to control the options of feature

for id in 1 2 3 4 5 6
do
	#copy_file_to_db `sxr which -csc ddxi1011.csc` $APP $DB
	copy_file_to_db `sxr which -csc $CALC${id}.csc` $APP $DB
	chmod 755 $ARBORPATH/app/$APP/$DB/*csc

	# Run each calc for exporting data
	runcalc_custom $APP $DB $CALC${id}.csc

	# The output by calc will be compared by baseline
	mv $ARBORPATH/app/$CALC${id}.out $SXR_WORK

	# The output by calc will be compared by baseline
	compare_result $CALC${id}.out  $CALC${id}.bas

done


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


