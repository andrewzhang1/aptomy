#!/bin/ksh

echo 'Running Unix compdir profile.'
#set -o vi
# set default access to read write execute for all newly created directories.
umask 000

# Set some user related variables

export HOME=~

export BUILD_ROOT=/net/nar200/vol/vol2/pre_rel

export HYPERION_HOME=/vol1/dircompare/Hyperion

export ARBORPATH=$HYPERION_HOME/AnalyticServices
export EASPATH=$HYPERION_HOME/AdminServices
export EAS_HOME=$HYPERION_HOME/AdminServices
export EDS_HOME=$HYPERION_HOME/AvailabilityServices
export APS_HOME=$HYPERION_HOME/AnalyticProviderSmartView
export SVP_HOME=$HYPERION_HOME/SmartView

# Increase shell max limits
# Set max number of file descriptors to 1024
ulimit -n 1024
export EDITOR=vi
export AD_EXPIRY_WARN=FALSE
