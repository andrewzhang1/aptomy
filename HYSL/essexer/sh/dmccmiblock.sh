#:
#: Purpose:  This test is to use a new SET calculator command to test
#:           the prevention of #Missing blocks to be created
#:           when DataCopy (dense copy=partial copy) command is executed
#:
#: Author:           Andrew Zhang
#: Date created:     July 22, 2002
#: Tag:
#: Dependencies:     dmccmiblock1.scr, dmccmiblock2.scr, dmccmiblock3.scr
#: Runnable:         true
#: Arguments:        none
#: Test Information:
#:    Estimate run-time -        30 sec.
#:    Memory/Disk space -        5M
#:    Number of suc files -       4
#:
#: Modification History:
#:    02/08/2008 Andrew Zhang - Updated for the common log of kennedy feature
#:    03/17/2008 Andrew Zhang - Updated for the common log of kennedy feature
#:                              with API call to get application log
#:    04/01/2008 Andrew Zhang - Erase the empty line for the output as it may
#:                              generate difs if HYPERION_HOME and ARBORPATH
#:                              is not in the same directory regarding the
#:                              common log files 
#:    11/08/2012 vgee - Fixed hard coded user/password in baseline.
#:
#--------------------------------------------------------------

APP=Dmccmibk
DB=Basic
OTL="dmccmibk.otl"
CSC1="dmccmi1"   # Set CopyMissingBlock ON;
CSC2="dmccmi2"   # Clear block partial block;
CSC3="dmccmi3"   # Set CopyMissingBlock OFF;
DBA="dmccmibk.txt"

sxr agtctl start

sxr newapp -force $APP
sxr newdb -otl $OTL $APP $DB

sxr fcopy -in -csc $CSC1.csc $CSC2.csc $CSC3.csc -out !$APP!$DB!
sxr fcopy -in -data $DBA -out !$APP!$DB!

# load data
sxr esscmd agsyloaddata.scr %HOST=${SXR_DBHOST} %USER=${SXR_USER} \
                            %PASSWD=${SXR_PASSWORD} %APPNAME=${APP} \
                            %DBNAME=${DB} %LOADDATA=${DBA}


# Run default calc with Set CopyMissingBlock ON;

sxr esscmd  dmccmiblock1.scr %HOST=${SXR_DBHOST} %USER=${SXR_USER} \
           %PASSWD=${SXR_PASSWORD} %APPNAME=${APP} %DBNAME=${DB} %CALC=${CSC1} 

# Clear partial block for the preparation of the main test;


sxr esscmd  dmccmiblock2.scr %HOST=${SXR_DBHOST} %USER=${SXR_USER} \
           %PASSWD=${SXR_PASSWORD} %APPNAME=${APP} %DBNAME=${DB} %CALC=${CSC2}

# Run Calc CopyData but "Get away #missing block"

sxr esscmd  dmccmiblock3.scr %HOST=${SXR_DBHOST} %USER=${SXR_USER} \
           %PASSWD=${SXR_PASSWORD} %APPNAME=${APP} %DBNAME=${DB} %CALC=${CSC3}

# Check from App Log file

# Get log message from the app log

sxr esscmd -q msxxgetlog.scr  %HOST=${SXR_DBHOST} %UID=${SXR_USER} \
                              %PWD=${SXR_PASSWORD} %APP=${APP} \
                              %LOG=${APP}.log

grep "CopyMissingBlock OFF"  Dmccmibk.log > dmccmiblock4.out

# Erase the empty line for the output 
awk '($0 !~ /^ *$/) {print $0}' dmccmiblock1.out  > dmccmiblock1.out1
awk '($0 !~ /^ *$/) {print $0}' dmccmiblock2.out  > dmccmiblock2.out1
awk '($0 !~ /^ *$/) {print $0}' dmccmiblock3.out  > dmccmiblock3.out1
awk '($0 !~ /^ *$/) {print $0}' dmccmiblock4.out  > dmccmiblock4.out1

sxr diff  -ignore '\[... .*$' -ignore '\[... .*$' -ignore 'Last login .*$' \
          -ignore 'process id .*$' \
          -ignore "Block Compress.*$" \
          -ignore 'Total Calc Elapsed Time .*$' \
          -ignore '\[... .*$' -ignore 'Logging out .*$' \
	  -ignore 'Average Fragmentation Quotient .*$' \
          -ignore "essexer" \
          -ignore "$SXR_USER" \
          dmccmiblock1.out1 dmccmiblock1.bas

sxr diff  -ignore '\[... .*$' -ignore '\[... .*$' -ignore 'Last login .*$' \
          -ignore 'process id .*$' \
          -ignore "Block Compress.*$" \
          -ignore 'Total Calc Elapsed Time .*$' \
          -ignore '\[... .*$' -ignore 'Logging out .*$' \
          -ignore 'Average Fragmentation Quotient .*$' \
          -ignore "essexer" \
          -ignore "$SXR_USER" \
          dmccmiblock2.out1 dmccmiblock2.bas

sxr diff  -ignore '\[... .*$' -ignore '\[... .*$' -ignore 'Last login .*$' \
          -ignore 'process id .*$' \
          -ignore "Block Compress.*$" \
          -ignore 'Total Calc Elapsed Time .*$' \
          -ignore '\[... .*$' -ignore 'Logging out .*$' \
	  -ignore 'Average Fragmentation Quotient .*$' \
          -ignore "essexer" \
          -ignore "$SXR_USER" \
       	 dmccmiblock3.out1 dmccmiblock3.bas

sxr diff dmccmiblock4.out1 dmccmiblock4.bas

sxr esscmd msxxresetdb.scr   %HOST=${SXR_DBHOST} %UID=${SXR_USER} \
          %PWD=${SXR_PASSWORD} \
          %APP=${APP} %DB=${DB}

sxr esscmd msxxdeleteapp.scr %HOST=${SXR_DBHOST} %UID=${SXR_USER} \
          %PWD=${SXR_PASSWORD} \
          %APP=${APP};

