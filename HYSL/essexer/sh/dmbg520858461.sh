#-----------------------------------------------------------------------------
# Test Name: dmbg520858461.sh
#
# Author:   Andrew Zhang
# Date created:  10/04/06
# Purpose: Automate for the bug verification on data export by calc.
#
# Instrcution:
#	1) This is a customer reported case.
#	2) Please informend, you need at least 50 GB disk space to run the
#	   the test effectively.
#	3) Kick off dmbg520858461.sh for about 40 minuts (this script just
#	   created a app and db, then load data and run a calc on one dimension);
#	   then kick off two calc script from two seperated command line:
#	   All.csc and input.csc. We will see a crash after the exported files
#	   reache to All_5.out.
#
#-----------------------------------------------------------------------------

#-------------------------
# Include shared functions
#-------------------------

 . `sxr which -sh esscmd.func`

#-----------------------
#Constants and Variables
#-----------------------
APP=FinAct
DB=FinAct
OTL=FinAct
DATA=FinAct.txt

CALC1=AggAll.csc
CALC2=All.csc
CALC3=input.csc

sxr agtctl start

#--------------------------
# Create the application/db
#--------------------------
create_app $APP
create_db $OTL.otl $APP $DB

#Load data to database
#--------------------------
load_data $APP $DB $DATA

# Run export by calc at three options

copy_file_to_db `sxr which -csc $CALC1` $APP $DB
copy_file_to_db `sxr which -csc $CALC2` $APP $DB
copy_file_to_db `sxr which -csc $CALC3` $APP $DB

# The following calc could run more than 30 hours days
runcalc_custom  $APP $DB  $CALC1

# Please kick off the All.csc and input.csc on the seperated
# command lines manually after about 40 minutes.

#runcalc_custom  $APP $DB  $CALC2
#runcalc_custom  $APP $DB  $CALC3
