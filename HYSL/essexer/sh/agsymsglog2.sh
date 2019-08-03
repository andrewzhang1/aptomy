################################################################################
# Create by : 	Andrew Zhang
# Date:         Oct. 23, 2002
# Filename: 	agsymsglog2.sh
# Time:	  2 minutes.
# Purpose :	Enhancement to the old functionality for message logging
#		1) AGENTLOGMESSAGELEVEL  WARNING
#
# Expected *suc: 4
# agsymsglog2-1.suc - Successful NOT log Info to Essbase.log without 
#                     setting (default setting)
# agsymsglog2-2.suc - Successful to log Warning to Essbase.log without 
#                     setting (default setting)
# agsymsglog2-3.suc - Successful to log Error to Essbase.log without 
#                     setting (default setting)
# agsymsglog2-4.suc - Successful to expected msg to Essbase.log without 
#                     setting (default setting)
#
#	06/15/2007 Andrew Zhang
#	Ffixed one test issue for linux platform.
#
#       11/12/2007, 02/04/2008 Andrew Zhang
#       Updated for Kennedy feature: "common log"
#       02/12/2008, Van Gee
#       Removed references to ARBORPATH
#
################################################################################

################
# Files called:
################

#
# Define host, variables, functions, names
#

HOST=${SXR_DBHOST}
USER=${SXR_USER}
PWD=${SXR_PASSWORD}
WORK=${SXR_WORK}
VIEW=${SXR_VIEWHOME}

APP01=Agtmesg3

DB01=Basic

create_db ()
{
# OtlineName ApplicationName DatabaseName
sxr newdb -otl `sxr which -data $1` $2 $3
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
	 $1 `sxr which -log $2`

if [ $? -eq 0 ]
     then
       echo Success comparing $1
     else
       echo Failure comparing $1
fi
}

sxr agtctl start

#  Save essbase.cfg if one exist and append cfg setting
sxr esscmd -q msxxcopycfgfile.scr %HOST=${SXR_DBHOST} %UID=${SXR_USER} \
                              %PWD=${SXR_PASSWORD} %OLDFILE=essbase.cfg \
                              %NEWFILE=essbase.cfg.sxr

echo "AGENTLOGMESSAGELEVEL WARNING" > essbase.sxr
sxr esscmd -q msxxsendcfgfile.scr %HOST=${SXR_DBHOST} %UID=${SXR_USER} \
                              %PWD=${SXR_PASSWORD} %CFGFILE=essbase.sxr

sxr agtctl stop

###     !!!!!!!!!!!!!!!!!!!!!     ###############################

echo "Now display:   $ARBRORPATH/bin/essbase.cfg "
cat  $ARBORPATH/bin/essbase.cfg
sleep 5


######################################################################
# Part One:
# Test default settings for AGENTLOGMESSAGELEVEL (without setting anything
######################################################################

# Start the agent again
sxr agtctl start

sxr esscmd -q msxxdellog.scr  %HOST=${SXR_DBHOST} %UID=${SXR_USER} \
                              %PWD=${SXR_PASSWORD} %APP=""

sxr newapp -force $APP01

# create_db basic.otl $APP01 $DB01

##############################################################
# 1-1 load a non-existed application to get all 3 level messages
##############################################################

export SXR_ESSCMD=essmsh
        sxr esscmd  agsymsglog_loadapp.mxl %3=$HOST %1=$USER %2=$PWD \
                        %4=Non-exist
export SXR_ESSCMD=ESSCMD

##############################################################
# 1-2 search for expected messages
##############################################################

sxr esscmd -q msxxgetlog.scr  %HOST=${SXR_DBHOST} %UID=${SXR_USER} \
                              %PWD=${SXR_PASSWORD} %APP=NULL \
                              %LOG=agsymsglog2.log

grep Info agsymsglog2.log

if [ $? = 1 ]
then
   echo "\n Info is NOT loged into Essbase.log! \n"
   touch agsymsglog2-1.suc
else
   echo "Info messages are logged into Essbase.log, should only have WARNING!" \
        > agsymsglog2-1.dif
fi

grep Warning agsymsglog2.log

if [ $? = 0 ]
then
   echo "\n Warning is login into Essbase.log! \n"
   touch agsymsglog2-2.suc
else
   echo "Warning messages have failed to log into Essbase.log!" \
        > agsymsglog2-2.dif
fi

grep Error agsymsglog2.log

if [ $? = 0 ]
then
   echo "\n Error is login into Essbase.log! \n"
   touch agsymsglog2-3.suc
else
   echo "Error messages have failed to log into Essbase.log!" \
        > agsymsglog2-3.dif
fi

grep -i "Application Agtmesg3 does not exist" \
        agsymsglog2.log > agsymsglog2-4.out
# grep -i "Error 1053003 processing request \[List Objects\] - disconnecting" \
#        agsymsglog2.log  >> agsymsglog2-4.out
grep -i "Error 1051030 processing request \[MaxL: Execute\] - disconnecting" \
        agsymsglog2.log  >> agsymsglog2-4.out
grep -i "Application Non-exist does not exist" \
        agsymsglog2.log  >> agsymsglog2-4.out

#
#  Compare report's results
#
compare_result agsymsglog2-4.out agsymsglog2-4.bas

#
#  Cleanup
sxr esscmd msxxrmap.scr %HOST=$HOST %USER=$SXR_USER %PASSWD=$SXR_PASSWORD \
			%APP=$APP01

# Cleaning job...

#  Replace New cfg with old cfg
sxr esscmd -q msxxrenamecfgfile.scr %HOST=${SXR_DBHOST} %UID=${SXR_USER} \
                           %PWD=${SXR_PASSWORD} %OLDFILE=essbase.cfg.sxr \
                           %NEWFILE=essbase.cfg

sxr agtctl stop
