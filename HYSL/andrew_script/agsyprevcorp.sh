#:Script: agsyprevcorp.sh
#:Authors: Andrew Zhang 
#:Reviewers:
#:Date:   05/02/2002
#:Purpose: Prevent security file corruption by periodically backup 
#:         the security file in order to prevent a sudden security file corruption 
#:        
#:Owned by: Andrew Zhang
#:Tag: FEATURE
#:Component: Agent
#:Subcomponents: Security
# Dependencies: None
#:Runnable: true
#:Arguments: none
#:Customer name: none
#:Memory/Disk: 10M/10M
#:Execution Time(min): 6
#:SUC: 3
#:Created for: Essbase 9.0
#:History:
# Midified:    08/30/2010 by Andrew Zhang
#              Bug 10010334
#              As part of the sec file corruption feature in talleyrand_sp1,
#              we changed the nomenclature of  the back up files to be of the
#              format essbase_<timestamp>.bak (by using function 'copy_backup'.
#
#:07/12/2013 Andrew Zhang - Modified header

sxr agtctl stop

cp $ARBORPATH/bin/essbase.cfg  $ARBORPATH/bin/essbase.cfg_bak_1
cp $ARBORPATH/bin/essbase.sec  $ARBORPATH/bin/essbase.sec_bak_1

sxr agtctl start

# preparation for the a kill process
kill_process ()
{
	cat processID  |
	while read line
	do
        	set $line
        	echo $2
        	sleep 1 
        	kill -9 $2
	done
}

# New Back up process:
copy_backup () 
 { 
     BAKFILE=`ls -t $ARBORPATH/bin/essbase_*.bak | head -1` 
     echo "Using $BAKFILE" 
     #cp $ARBORPATH/bin/essbase.bak $ARBORPATH/bin/essbase.sec 
     cp $BAKFILE $ARBORPATH/bin/essbase.sec 
 } 

echo "###############################################################"
echo "#"
echo "#  Now start to test preventing security file corruption....".
echo "#"
echo "###############################################################"
echo " "

###############################################
# Test Case One: Create a simple app|db 
# and tes the Updating of the security file  
################################################

# 1-1 Create App | DB, 
sxr esscmd  agsycreate1.scr	%HOST=$SXR_DBHOST %USER=$SXR_USER \ 						%PWD=$SXR_PASSWORD \

# 1-2 Update essbase.bak file
sxr esscmd updatebakfile.scr   	%HOST=$SXR_DBHOST %USER=$SXR_USER \ 						%PWD=$SXR_PASSWORD \

# 1-3 Get the first ouptput before deleting the security file for the comparison
sxr esscmd  agsyprevcorp1.scr	%HOST=$SXR_DBHOST %USER=$SXR_USER \ 						%PWD=$SXR_PASSWORD \

# Move this output as a base line
   mv $SXR_WORK/agsyprevcorp1.out1 $SXR_VIEWHOME/log

# 1-4 Delet and copy back the essbase.sec

     rm $ARBORPATH/bin/essbase.sec
     ps -fu $LOGNAME | grep -iw esscmd | grep -v 'grep -iw esscmd' > processID
     ps -fu $LOGNAME | grep -iw essmsh | grep -v 'grep -iw essmsh' >> processID
     ps -fu $LOGNAME | grep -iw esssvr | grep -v 'grep -iw esssvr' >> processID
     ps -fu $LOGNAME | grep -iw essbase | grep -v 'grep -iw essbase' >> processID

# 1-5 Run kill process to simulate the essbase crash (powerdown)
    kill_process

# 1-5 Get the second ouptput after restart the agent for the comparison
        #cp $ARBORPATH/bin/essbase.bak $ARBORPATH/bin/essbase.sec
	
        copy_backup
        sxr agtctl start
	sxr esscmd  agsyprevcorp1-1.scr	%HOST=$SXR_DBHOST %USER=$SXR_USER \ 						%PWD=$SXR_PASSWORD \

# 1-6  compare the result
	# sxr sh  agsyprevcorp.ksh agsyprevcorp2.out1 agsyprevcorp1.out1 
#   cp $SXR_WORK/agsyprevcorp1.out1 $SXR_VIEWHOME/log

     sxr diff  agsyprevcorp1.out2 agsyprevcorp1.out1
     
rm processID
rm $SXR_VIEWHOME/log/agsyprevcorp1.out1
# sxr agtctl stop

#cp $ARBORPATH/bin/essbase.cfg_bak_1 $ARBORPATH/bin/essbase.cfg
#cp $ARBORPATH/bin/essbase.sec_bak_1 $ARBORPATH/bin/essbase.sec

####################################################################
# Test Case Two: Update a security file by creating 5 users  
####################################################################

# 2-1 Create users 5 users
# get the first ouptput before deleting the security file for the comparison

# rm $ARBORPATH/bin/essbase.sec
# sxr fcopy -in -data $SECFILE.sec
# cp essbase.sec $ARBORPATH/bin
sxr agtctl start

echo "##################################################################"
echo "#"
echo "# Test Case Two: Update the security file by creating multi users"
echo "#"
echo "##################################################################"

sleep 2
sxr esscmd  agsyprevcorp2.scr	%HOST=$SXR_DBHOST %USER=$SXR_USER \ 						%PWD=$SXR_PASSWORD \

# Move the output as a base line
   mv $SXR_WORK/agsyprevcorp2.out1 $SXR_VIEWHOME/log

# 2-2 Update essbase.bak file
sxr esscmd updatebakfile.scr   	%HOST=$SXR_DBHOST %USER=$SXR_USER \ 						%PWD=$SXR_PASSWORD \

# 2-3 Delet and copy back the essbase.sec

     rm $ARBORPATH/bin/essbase.sec
     ps -fu $LOGNAME | grep -iw esscmd | grep -v 'grep -iw esscmd' > processID
     ps -fu $LOGNAME | grep -iw essmsh | grep -v 'grep -iw essmsh' >> processID
     ps -fu $LOGNAME | grep -iw esssvr | grep -v 'grep -iw esssvr' >> processID
     ps -fu $LOGNAME | grep -iw essbase | grep -v 'grep -iw essbase' >> processID

 
# 2-4 Run kill process to simulate the essbase crash (power down)
    kill_process

# 2-5 Get the second ouptput after restart the agent for the comparison
     #	cp $ARBORPATH/bin/essbase.bak $ARBORPATH/bin/essbase.sec
        
        copy_backup

	sxr agtctl start
	sxr esscmd  agsyprevcorp2-1.scr	%HOST=$SXR_DBHOST %USER=$SXR_USER \ 						%PWD=$SXR_PASSWORD \

# 2-6  compare the result

     sxr diff  agsyprevcorp2.out2 agsyprevcorp2.out1
     
 rm processID
rm $SXR_VIEWHOME/log/agsyprevcorp2.out1
sxr agtctl stop

####################################################################
# Test Case Three: Update the security file by creating multi app | db  
####################################################################

sxr agtctl start

echo "###########################################################################"
echo "#"
echo "# Test Case Three: Update the security file by creating multi app | db" 
echo "#"
echo "###########################################################################"

sleep 2

# 3-1 creating 9 app | db

sxr esscmd  agsyprevcorp3.scr	%HOST=$SXR_DBHOST %USER=$SXR_USER \ 						%PWD=$SXR_PASSWORD \

# Move the output as a base line
   mv $SXR_WORK/agsyprevcorp3.out1 $SXR_VIEWHOME/log

# 3-2 Update essbase.bak file
sxr esscmd updatebakfile.scr   	%HOST=$SXR_DBHOST %USER=$SXR_USER \ 						%PWD=$SXR_PASSWORD \

# 3-3 Delet and copy back the essbase.sec

     rm $ARBORPATH/bin/essbase.sec
     ps -fu $LOGNAME | grep -iw esscmd | grep -v 'grep -iw esscmd' > processID
     ps -fu $LOGNAME | grep -iw essmsh | grep -v 'grep -iw essmsh' >> processID
     ps -fu $LOGNAME | grep -iw esssvr | grep -v 'grep -iw esssvr' >> processID
     ps -fu $LOGNAME | grep -iw essbase | grep -v 'grep -iw essbase' >> processID
 
# 3-4 Run kill process to simulate the essbase crash (power down)
    kill_process

# 3-5 Get the second ouptput after restart the agent for the comparison
	# cp $ARBORPATH/bin/essbase.bak $ARBORPATH/bin/essbase.sec
        
       copy_backup

       sxr agtctl start
       sxr esscmd  agsyprevcorp3-1.scr	%HOST=$SXR_DBHOST %USER=$SXR_USER \ 						%PWD=$SXR_PASSWORD \

# 3-6  compare the result

     sxr diff  agsyprevcorp3.out2 agsyprevcorp3.out1
     
 rm processID
rm $SXR_VIEWHOME/log/agsyprevcorp3.out1

sxr agtctl stop

cp $ARBORPATH/bin/essbase.cfg_bak_1  $ARBORPATH/bin/essbase.cfg
cp $ARBORPATH/bin/essbase.sec_bak_1  $ARBORPATH/bin/essbase.sec

