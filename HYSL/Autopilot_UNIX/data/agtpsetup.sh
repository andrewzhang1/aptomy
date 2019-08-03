# Set the agent and server ports
# Author:	Eric Meyerhuber
# Date Started: 11.21.2001
#
# History
# 02.01.2002 EMeyerhuber Added chmod commands to handle situations
# where current user cannot write to *.cfg files, used chmod 777.
#

# Mar. 16, 2004  Andrew Zhang
# This script will be failed on Aix5L box due the ksh limitation with the 
# the essexer platform if the parameters is more than 5 for the "fcopy".
# Fixed by seperating the fcopy command if we have a long parameter. 


# Aug. 2, 2008 Modified by Yukio Kono
# Add modification which doesn't over-write existed essbase.cfg file
# when there is no currentUser.cfg in the data folder.

# Turn on debugging
set -x

# Remove all data files because this may cause problems if we rerun
# this script more than once in the same view.
cd ${SXR_VIEWHOME}/data
chmod 777 *
rm *.*

# We need to stop the agent before bringing in a new essbase.cfg file
# because a current agent for the current user may be running on a 
# different port from that read from $SXR_BASE/data. We also need to
# ensure essbase.cfg is reread to become effective by stopping and 
# starting agent.
sxr agtctl stop

# The current essbase.cfg needs to be writable 
# because we will write to it
chmod 777 $ARBORPATH/bin/essbase.cfg
chmod 777 $ARBORPATH/bin/$LOGNAME.cfg

currentUser=$LOGNAME
# Get the port ids for the current user that is stored in $SXR_BASE/data 
# directory. It will be placed in the $ARBORPATH/bin directory so that
# the agent and server ports will use them. Each user will have their own
# ports assigned but we will not enforce this programmatically.

# 2 Aug., 2008 YK
cfgexist=`sxr which -data $currentUser.cfg`
if [ $? -eq 0 ]; then
    sxr fcopy -in -data $currentUser.cfg -out $ARBORPATH/bin
    cp $ARBORPATH/bin/$currentUser.cfg $ARBORPATH/bin/essbase.cfg
    chmod 777 $ARBORPATH/bin/essbase.cfg
else
    if [ -f "$ARBORPATH/bin/essbase.cfg" ]; then
        current_agentport=`egrep -i agentport $ARBORPATH/bin/essbase.cfg`
        if [ -z "$current_agetport" -a -n "$AP_AGENTPORT" ]; then
            echo "AgentPort $AP_AGENTPORT" >> $ARBORPATH/bin/essbase.cfg
        fi
    else
        if [ -n "$AP_AGENTPORT" ]; then
            echo "AgentPort  $AP_AGENTPORT" > $ARBORPATH/bin/essbase.cfg
        fi
    fi
fi

# Append the license key setting
echo  "DeploymentID PN5453" >> $ARBORPATH/bin/essbase.cfg

if test $? -ne 0 
then 
   echo "File essbase.cfg could not be copied to the $ARBORPATH/bin directory."
   echo "Aborting the regression run."
   exit 1
fi
# Restart agent with new essbase.cfg file
sxr agtctl start

# Copy all text and configuration files that are written to essbase.cfg file
# because we need to ensure that all newly created essbase.cfg files use the same agent
# and server ports initialized above.


#sxr fcopy -in -data "*cfg*" "sdop*.cfg" "dmpcpdl*.txt" dmcccon.txt dmcccoff.txt "*old*" \
#-out ${SXR_VIEWHOME}/data

#sxr fcopy -in -data "*cfg*" "dmpcpdl*.txt"  \
#-out ${SXR_VIEWHOME}/data

#sxr fcopy -in -data dmcccon.txt dmcccoff.txt "*old*" \
#-out ${SXR_VIEWHOME}/data
for i in $SXR_BASE/data/*cfg*; do cp $i ${SXR_VIEWHOME}/data; done
for i in $SXR_BASE/data/dmcccon.txt dmcccoff.txt *old* dmpcpdl*.txt; do cp $i ${SXR_VIEWHOME}/data; done


# Append agent and server port values to all files in the local data directory
cd ${SXR_VIEWHOME}/data
chmod 777 *

for i in *
do
	# Write a newline because some config files don't have newline at the
	# the end of the line that causes problem reading agent port.
	print "\n" >> ${i}
	cat "$ARBORPATH/bin/essbase.cfg" >> ${i}
done

cd ${SXR_WORK}

# Ensure essbase.cfg is reread to become effective
sxr agtctl stop
sxr agtctl start
