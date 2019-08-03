##################################################################################
# Test for error cases for single sign-on
#Test Script: 		agsyloginbytoken_J13_err.sh
# Purposes: 			1.
#
# Files Called:    1. agsyloginbytoken.scr
#
# Updated:  Feb 24
##################################################################################

HOST=${SXR_DBHOST}
USER=${SXR_USER}
PASSWD=${SXR_PASSWORD}
WORK=${SXR_WORK}
VIEW=${SXR_VIEWHOME}


sxr agtctl stop

##################################################################
# Set environment
##################################################################

mv $ARBORPATH/bin/essbase.cfg $ARBORPATH/bin/essbase.cfg.bak
cp $(sxr which -data $LOGNAME.cfg) $ARBORPATH/bin/essbase.cfg

ARBORPATH=`cat dummy.cfg`
echo "AuthenticationModule css file://$ARBORPATH/bin/sample.xml" >> $ARBORPATH/bin/essbase.cfg
cp $(sxr which -data sample.xml) $ARBORPATH/bin

###########################################################################
#
#  Case 1: change css protocol in the essbase.cfg to css1
#
###########################################################################

mv  $ARBORPATH/Essbase.log    $ARBORPATH/Essbase.log_main

mv  $ARBORPATH/bin/essbase.cfg $ARBORPATH/bin/essbase.cfg_good

sed  's/css/Css1/' $ARBORPATH/bin/essbase.cfg_good >  $ARBORPATH/bin/essbase.cfg



####################################################################
#
# This is to fix HP problem for jre1.4 only
#
####################################################################

if  [ $BOX = HP-UX ]
then
export LD_PRELOAD="/opt/java1.4/jre/lib/PA_RISC2.0/server/libjsig.sl:\
/opt/java1.4/jre/lib/PA_RISC2.0/server/libjvm.sl"

ESSBASE password -b &
unset LD_PRELOAD

else

        sxr agtctl start
fi




sxr agtctl stop

mv $ARBORPATH/Essbase.log   loginbytoken_err-1.out
grep -i "Loading Fails." loginbytoken_err-1.out

if [ $? = 0 ]
then
	echo "\n External Authentication Server Module [css] Loading Fails - Expected! \n"
	touch loginbytoken_err-1.suc
else
	echo "\n External Authentication Server Module [css] Loading Succeed - Not Expected!\n"
	touch loginbytoken_err-1.dif
fi

mv $ARBORPATH/bin/essbase.cfg_good $ARBORPATH/bin/essbase.cfg
mv  $ARBORPATH/Essbase.log    $ARBORPATH/Essbase.log_error_case1

###########################################################################
#
#  Case 2: change local protocol type from "file" to file1
#
###########################################################################

mv  $ARBORPATH/bin/essbase.cfg $ARBORPATH/bin/essbase.cfg_good

sed  's/file/file1/' $ARBORPATH/bin/essbase.cfg_good >  $ARBORPATH/bin/essbase.cfg



####################################################################
#
# This is to fix HP problem for jre1.4 only
#
####################################################################

if  [ $BOX = HP-UX ]
then
export LD_PRELOAD="/opt/java1.4/jre/lib/PA_RISC2.0/server/libjsig.sl:\
/opt/java1.4/jre/lib/PA_RISC2.0/server/libjvm.sl"

ESSBASE password -b &
unset LD_PRELOAD

else

        sxr agtctl start
fi

sxr agtctl stop

mv $ARBORPATH/Essbase.log   loginbytoken_err-2.out

grep -i "Single Sign-On Initialization Failed !"   loginbytoken_err-2.out

if [ $? = 0 ]
then
	echo "\n Single Sign-On Initialization Failed  - Expected! \n"
	touch loginbytoken_err-2.suc
else
	echo "\n Single Sign-On Initialization succeed  - Not Expected!\n"
	touch loginbytoken_err-2.dif
fi

mv  $ARBORPATH/bin/essbase.cfg_good $ARBORPATH/bin/essbase.cfg

###########################################################################
#
#  Case 3: change sample.xml part 1: wrong MSAD URL name: stnti5 --> stnti6
#  
# Note: This case caused hang on Unix Platforms, I commented this case 
#       tesmporily
###########################################################################

# mv $ARBORPATH/bin/sample.xml $ARBORPATH/bin/sample.xml_good

# sed  's/stnti5/stnti6/' $ARBORPATH/bin/sample.xml_good >  $ARBORPATH/bin/sample.xml

URL_PATH1=$ARBORPATH/bin/sample.xml

######################
#  Function
#####################
get_token ()
{
echo ""
echo "Getting token for user $1 now. Please wait for a few seconds...\n"
echo "java CSSAuthenticateForEssbase $1 $2 $3 > $4 \n"

java CSSAuthenticateForEssbase "$1" "$2" $3 > $4
echo "\n The original token for $1 is: \n"
cat $4
if [ $? = 0 ]
then
	echo "\n Geting Token was successful! \n"
	touch $5
else
	echo "\n Getting token failed! \n"
	touch $6

fi
}

#get_token  "bnguyen_AD" "password" "$URL_PATH1"  loginbytoken_err-3.out

#grep -i "Failed to connect to the directory server"  loginbytoken_err-3.out
if [ $? = 0 ]
then
	echo "\n GetTokin Fails - Expected! \n"
	touch loginbytoken_err-3.suc
else
	echo "\n Gettoken Succeed - Not Expected!\n"
	touch loginbytoken_err-3.dif
fi

#mv $ARBORPATH/bin/sample.xml_good $ARBORPATH/bin/sample.xml

###########################################################################
#
#  Case 4: Rename an Essbase internal user to CSS user: fail to create
#  Currently we do not have a tool esscmdq or maxl to change user from internal to external,
#  vice versa.
#
###########################################################################


###########################################################################
#
#  Case 5: Set time out = 0 the token created will be not able to login again
#                       = -1 (not supported, CSS gruoup adviced)
###########################################################################


