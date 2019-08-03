#: Authors: Andrew Zhang
#: Reviewers: 
#: Date: 03/01/06
#: Purpose: Export data from calc to the flat files. 
#: Component/Sub Comp: Calculator/Calc
#: Owned by: Andrew Zhang
#: Tag: NORMR 
#: Dependencies: esscmd.func
#: Runnable: true
#: Arguments: none
#: Memory/Disk: 200MB/200MB
#: SUC: 40
#: Created for: beckett
#: Retired for:
#: Test cases: Export data from calc to the flat files in ASCII format
#: History:



 . `sxr which -sh esscmd.func`

compare_result ()
{
# OutputFileName BaselineFileName (by pair)
sxr diff -ignore "Average Clust.*$" -ignore "Average Fragment.*$" \
	 -ignore '\[... .*$' -ignore '\[... .*$' -ignore 'Last login .*$' \
         -ignore 'process id .*$' \
         -ignore 'Total Calc Elapsed time  .*$' \
         -ignore 'Elapsed time: .*$' \
         -ignore '\[... .*$' -ignore 'Logging out .*$' \
         -ignore 'Average Fragmentation Quotient .*$' \
         -ignore "e+0*" \
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

 sxr agtctl start

#--------------------------------------
#Constants and Variables for all parts
#--------------------------------------
APP=Ddxic101
DB=Basic
OTL=agsymd
DATA=agsymd.txt
TestFile=ddxicalc1  # For the error file output

# Create the application/db
#--------------------------
create_app $APP
create_db $OTL.otl $APP $DB

#Load data to database
#----------------------
#copy_file_to_db `sxr which -data $DATA` $APP $DB
load_data $APP $DB $DATA
runcalc_default $APP $DB

################################################################################
# Part One:
#-------------------------------------------------------------------------------
# Purpose: Test export data by using basic calc functions
# Main content:
#       1. using basic calc to make full export
#       2. Main syntax:  DATAEXPORT, column format
#       3. Expected result: All data is exported as specified by export level
#       4. The format of the target data export is: flat file
################################################################################

#--------------------------------------
#Constants and Variables for this part
#--------------------------------------

CALC1=ddxi1011.csc # export all data
CALC2=ddxi1012.csc # export level0 data
CALC3=ddxi1013.csc # export input level data
CALC=ddxi101 # variable for the first part of the calc script

# Run export by calc at three options
#--------------------------------------

#Using the loop to control the options of feature
for id in 1 2 3
do

	# Run each calc for exporting data
	runcalc_custom $APP $DB $CALC${id}.csc

	# The output by calc will be compared by that from ESSCMD
	mv $ARBORPATH/app/$CALC${id}.out $SXR_WORK

	compare_result  $CALC${id}.out  $CALC${id}.bas

done

################################################################################
# Part Two:
#-------------------------------------------------------------------------------
# Test Name: ddxicalc102.sh
# Date created:  03/01/06
# Created by:	Andrew Zhang
# Purpose: 	Test export data by using calculator
# Main content:
#	This case mainly test the various formats of delimiters and #Missing
#	with Fix  statement and set DataExportColFormat on.
#
#	Case(calc) Number	Delimiter	 #miss format
#	------------------------------------------------------------
#	ddxi1021.csc		Space 	Not specified default is: #Mi
#	ddxi1022.csc		, 	#Mi
#	ddxi1023.csc		-	#mi
#	ddxi1024.csc		/	Missing
#	ddxi1025.csc		:	#Missing
#	ddxi1025.csc		^	No data
#	ddxi1026.csc		;	?DataMising?
#	ddxi1027.csc		,	#Mi (With no Fix statement )

# Number of suc file(s): 7
# Baseline creation: The baselines were captured by manualy running calc scripts
#-------------------------------------------------------------------------------

#--------------------------------------
#Constants and Variables for this part
#--------------------------------------
CALC=ddxi102 # variable for the first part of the calc script

#Using the loop to control the options of feature
for id in 1 2 3 4 5 6 7
do

	# Run each calc for exporting data
	runcalc_custom $APP $DB $CALC${id}.csc

	# The output by calc will be compared by that from ESSCMD
	mv $ARBORPATH/app/$CALC${id}.out $SXR_WORK

	compare_result  $CALC${id}.out  $CALC${id}.bas

done

################################################################################
# Part Three:
#-------------------------------------------------------------------------------
# Main content:
#	This case fixes three dense members and two sparse members
#	with three combinations of data export levels.
# Memory/Disk space requirement: negligible
# Number of suc file(s): 3
#-------------------------------------------------------------------------------

#--------------------------------------
#Constants and Variables for this part
#--------------------------------------

CALC=ddxi103 # variable name for the first part of the calc script

# Run export by calc at three options
#--------------------------------------

#Using the loop to control the options of feature
for id in 1 2 3
do

	# Run each calc for exporting data
	runcalc_custom $APP $DB $CALC${id}.csc

	# The output by calc will be compared by that from ESSCMD
	mv $ARBORPATH/app/$CALC${id}.out $SXR_WORK

	compare_result  $CALC${id}.out  $CALC${id}.bas

done


################################################################################
# Part Four:
#-------------------------------------------------------------------------------
# Main content:
#	Test setting dense dimension as column head
# Number of suc file(s): 17
#-------------------------------------------------------------------------------

#--------------------------------------
#Constants and Variables for this part
#--------------------------------------

CALC=ddxi104 # variable name for the first part of the calc script

# Run export by calc at three options
#--------------------------------------

#Using the loop to control the options of feature
for id in 1 2 3 4 5 6
do

	# Run each calc for exporting data
	runcalc_custom $APP $DB $CALC${id}.csc

	# The output by calc will be compared by that from ESSCMD
	mv $ARBORPATH/app/$CALC${id}.out $SXR_WORK

	compare_result  $CALC${id}.out  $CALC${id}.bas

done


################################################################################
# Part Five:
#-------------------------------------------------------------------------------
# Main content:
#	Test Dry Run 
# Number of suc file(s): 3
#-------------------------------------------------------------------------------

#--------------------------------------
#Constants and Variables for this part
#--------------------------------------

CALC=ddxi10 # variable name for the first part of the calc script

# Run export by calc at three options
#--------------------------------------

#Using the loop to control the options of feature
for id in 51 52 53 54 55 56 57 58 59 \
          60 61 62 63 64 65 66 67 68
do
	#copy_file_to_db `sxr which -csc $CALC${id}.csc` $APP $DB
	#chmod 755 $ARBORPATH/app/$APP/$DB/*csc

	# Run each calc for exporting data
	runcalc_custom $APP $DB $CALC${id}.csc

	# The output by calc will be compared by that from ESSCMD
	mv $ARBORPATH/app/$CALC${id}.out $SXR_WORK

	compare_result  $CALC${id}.out  $CALC${id}.bas

done


################################################################################
# Part Six:
#-------------------------------------------------------------------------------
# Main content:
#	Test decimal and precision settings
# Number of suc file(s): 17
#-------------------------------------------------------------------------------

#--------------------------------------
#Constants and Variables for this part
#--------------------------------------

CALC=ddxi107 # variable name for the first part of the calc script

# Run export by calc at three options
#--------------------------------------

#Using the loop to control the options of feature
for id in 1 2 3 
          
do
	copy_file_to_db `sxr which -csc $CALC${id}.csc` $APP $DB
	
	# Run each calc for exporting data
	runcalc_custom $APP $DB $CALC${id}.csc

	# The output by calc will be compared by that from ESSCMD
	mv $ARBORPATH/app/$CALC${id}.out $SXR_WORK

	compare_result  $CALC${id}.out  $CALC${id}.bas

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
    # Delete applicatin
    #delete_app $APP
fi


