#:Script: agsyportulog.sh
#:Authors: Andrew Zhang 
#:Reviewers:
#:Date:   05/13/2002
#:Purpose: Test "Port Usage Log Time Interval"  by setting the time (miniutes) 
#:         inside the essbase.cfg. 
#:        
#:Owned by: Andrew Zhang
#:Tag: FEATURE
#:Component: SRVRADMN
#:Subcomponents: Server
# Dependencies: None
#:Runnable: true
#:Arguments: none
#:Customer name: none
#:Memory/Disk: 10M/10M
#:Execution Time(min): 60
#:SUC: 3
#:Created for: Essbase 9.0
#:History:
# Midified:    vgee - 3/19/2008, Removed ARBORPATH references.
#:07/12/2013 Andrew Zhang - Modified header 

########################################################################
#
# Test Case One: test "PortUsageLogInterval  2" - update every 2 minutes
#
########################################################################
sxr agtctl start

#  Save essbase.cfg if one exist 
sxr esscmd -q msxxcopycfgfile.scr %HOST=${SXR_DBHOST} %UID=${SXR_USER} \
                           %PWD=${SXR_PASSWORD} %OLDFILE=essbase.cfg \
                           %NEWFILE=essbase.cfg.sxr
echo "PortUsageLogInterval  2" > essbase.sxr
sxr esscmd -q msxxsendcfgfile.scr %HOST=${SXR_DBHOST} %UID=${SXR_USER} \
                           %PWD=${SXR_PASSWORD} %CFGFILE=essbase.sxr

sxr esscmd msxxdellog.scr  %HOST=${SXR_DBHOST} %UID=${SXR_USER} \
                           %PWD=${SXR_PASSWORD} %APP=""
sxr agtctl stop
sleep 15
sxr agtctl start

echo ""
echo ""
echo "##############################################"
echo "#"
echo "#  Testing PortUsageLogInterval - Part One." 
echo "#  It takes about 10 minutes..."
echo "#"
echo "############################################## "
echo "" 
 
sxr esscmd -q agsyportulog1.scr	%HOST=$SXR_DBHOST %USER=$SXR_USER \ 						%PWD=$SXR_PASSWORD \

# 1-1 count process
####################

let count=0

sxr esscmd -q msxxgetlog.scr %HOST=${SXR_DBHOST} %UID=${SXR_USER} \
                           %PWD=${SXR_PASSWORD} %APP=NULL \
                           %LOG=agsyportulog.log
grep -i "\[4\] ports in use" agsyportulog.log |
while read line
        do
          let count=count+1 
	  echo updated $count times in 10 minutes > agsyportulog1.out
	done

echo PortLog updates for $count timeis in 10 minutes.
sleep 2

# 1-2  compare the results
###########################

sxr diff agsyportulog1.out agsyportulog1.bas
     
# 1-3 Cleaning jobs
#####################

#  Replace New cfg with old cfg
sxr esscmd -q msxxrenamecfgfile.scr %HOST=${SXR_DBHOST} %UID=${SXR_USER} \
                           %PWD=${SXR_PASSWORD} %OLDFILE=essbase.cfg.sxr \
                           %NEWFILE=essbase.cfg

###########################################################################
#
# Test Case Two: test "PortUsageLogInterval  5" - update every 5 minutes
#
##########################################################################

#  Save essbase.cfg if one exist 
sxr esscmd -q msxxcopycfgfile.scr %HOST=${SXR_DBHOST} %UID=${SXR_USER} \
                           %PWD=${SXR_PASSWORD} %OLDFILE=essbase.cfg \
                           %NEWFILE=essbase.cfg.sxr
echo "PortUsageLogInterval  5" > essbase.sxr
sxr esscmd -q msxxsendcfgfile.scr %HOST=${SXR_DBHOST} %UID=${SXR_USER} \
                           %PWD=${SXR_PASSWORD} %CFGFILE=essbase.sxr

sxr esscmd msxxdellog.scr  %HOST=${SXR_DBHOST} %UID=${SXR_USER} \
                           %PWD=${SXR_PASSWORD} %APP=""
sxr agtctl stop
sleep 15
sxr agtctl start

echo ""
echo ""
echo ""
echo "##############################################"
echo "#"
echo "#  Testing PortUsageLogInterval - Part Two."
echo "#  It takes about 16 minutes..."
echo "#"
echo "############################################## "
echo ""

sxr esscmd -q agsyportulog2.scr %HOST=$SXR_DBHOST %USER=$SXR_USER \
                           %PWD=$SXR_PASSWORD

# 2-1 count process
#######################

let count=0
sxr esscmd -q msxxgetlog.scr %HOST=${SXR_DBHOST} %UID=${SXR_USER} \
                           %PWD=${SXR_PASSWORD} %APP=NULL \
                           %LOG=agsyportulog.log
grep -i "\[5\] ports in use" agsyportulog.log |
while read line
        do

             let count=count+1
        	echo updated $count times in 16 minutes > agsyportulog2.out
	done
echo PortLog updates for $count timeis in 16 minutes.
sleep 2

# 2-2  compare the results
##############################

sxr diff agsyportulog2.out agsyportulog2.bas

# 3-3 Cleaning jobs
######################

#  Replace New cfg with old cfg
sxr esscmd -q msxxrenamecfgfile.scr %HOST=${SXR_DBHOST} %UID=${SXR_USER} \
                           %PWD=${SXR_PASSWORD} %OLDFILE=essbase.cfg.sxr \
                           %NEWFILE=essbase.cfg

########################################################################
#
# Test Case Three: test "PortUsageLogInterval 9" - update every 9 minutes
#
########################################################################

#  Save essbase.cfg if one exist 
sxr esscmd -q msxxcopycfgfile.scr %HOST=${SXR_DBHOST} %UID=${SXR_USER} \
                           %PWD=${SXR_PASSWORD} %OLDFILE=essbase.cfg \
                           %NEWFILE=essbase.cfg.sxr
echo "PortUsageLogInterval  9" > essbase.sxr
sxr esscmd -q msxxsendcfgfile.scr %HOST=${SXR_DBHOST} %UID=${SXR_USER} \
                           %PWD=${SXR_PASSWORD} %CFGFILE=essbase.sxr

sxr esscmd msxxdellog.scr  %HOST=${SXR_DBHOST} %UID=${SXR_USER} \
                           %PWD=${SXR_PASSWORD} %APP=""
sxr agtctl stop
sleep 15
sxr agtctl start

echo ""
echo ""
echo ""
echo "##############################################"
echo "#"
echo "#  Testing PortUsageLogInterval - Part Three."
echo "#  It takes about 20 minutes..."
echo "#"
echo "############################################## "
echo ""
sleep 3

sxr esscmd -q agsyportulog3.scr %HOST=$SXR_DBHOST %USER=$SXR_USER \
                           %PWD=$SXR_PASSWORD

# 3-1 count process
########################

let count=0
sxr esscmd -q msxxgetlog.scr %HOST=${SXR_DBHOST} %UID=${SXR_USER} \
                           %PWD=${SXR_PASSWORD} %APP=NULL \
                           %LOG=agsyportulog.log
grep -i "\[6\] ports in use" agsyportulog.log |
while read line
        do
                let count=count+1
	echo updated $count times in 20 minutes > agsyportulog3.out
	done
echo PortLog updates for $count timeis in 20 minutes.
sleep 2

# 3-2  compare the results
############################

sxr diff agsyportulog3.out agsyportulog3.bas

# 3-3 Cleaning jobs
#####################

#  Replace New cfg with old cfg
sxr esscmd -q msxxrenamecfgfile.scr %HOST=${SXR_DBHOST} %UID=${SXR_USER} \
                           %PWD=${SXR_PASSWORD} %OLDFILE=essbase.cfg.sxr \
                           %NEWFILE=essbase.cfg

sxr agtctl stop
