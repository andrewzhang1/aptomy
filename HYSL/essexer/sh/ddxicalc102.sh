#: Authors: Andrew Zhang
#: Reviewers: 
#: Date: 03/01/06
#: Purpose: Export data from calc. 
#: Component/Sub Comp: Calculator/Calc
#: Owned by: Andrew Zhang
#: Tag: NORMR 
#: Dependencies: esscmd.func
#: Runnable: true
#: Arguments: none
#: Memory/Disk: 200MB/200MB
#: SUC: 7
#: Created for: beckett
#: Retired for:
#: Test cases: Test the various formats of delimiters and 
#              Fix statement and set DataExportColFormat on. 
#: Test time: 3 minutes
#: History:

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


#-------------------------
# Include shared functions
#-------------------------

 . `sxr which -sh esscmd.func`

#-----------------------
#Constants and Variables
#-----------------------
APP=Ddxic102
DB=Basic
OTL=agsymd
DATA=agsymd.txt


CALC=ddxi102 # variable for the first part of the calc script
TestFile=ddxicalc102  # variable name for the error output

compare_result ()
{
# OutputFileName BaselineFileName (by pair)
sxr diff -ignore "Average Clust.*$" -ignore "Average Fragment.*$" \
	 -ignore '\[... .*$' -ignore '\[... .*$' -ignore 'Last login .*$' \
         -ignore 'process id .*$' \
         -ignore 'Total Calc Elapsed Time .*$' \
         -ignore '\[... .*$' -ignore 'Logging out .*$' \
	 -ignore 'Average Fragmentation Quotient .*$' \
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
for id in 1 2 3 4 5 6 7
do
	copy_file_to_db `sxr which -csc $CALC${id}.csc` $APP $DB
	chmod 755 $ARBORPATH/app/$APP/$DB/*csc

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
    #Delete app
    delete_app $APP
fi


