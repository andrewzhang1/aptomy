###############################################################cv   ##################
# Test for Single sign-on for JDK 1.4.3 for 32 bits Essbase
# Test Script:           agsycss_J14_new_CIS_930.sh (updated for beckett release)
# Purposes: 		 Test Single Sing-on.
# Created By:		 Andrew Zhang
# Date:			 July, 2003
#
# Files Called: 1. agsyuserCSS.mxl            # Create external users.
#               2. agsygruserCSS.mxl          # Grant access permissions.
#               3. lohinbytoken*.scr          # Created on run time
#               4. agsyloginbytoken1_j13.sh   # Login by token (expectesd to succeed).
#             	5. agsyloginbytoken2_J13.sh   # Login by token (expectesd to fail after the token expired).
#               6. agsyloginbypassword_J13.sh # Test for Login By password, always successful even token expired.
#               7. agsyloginbytoken_J13_err.sh  # (addtional 3 error case are at the end of this main script.)
#
# Expected suc files:	 61
#
# Total Time reqired: 25 minutes  (NT)
# Updated:  Aug. 29, 2003
#           Oct. 1, 2003   (Update the file due to common installer change) 
#           Oct. 20, 2003  (updated file css-2_0_7.jar --> css-2_0_8.jar)
#           Nov. 7, 2003 Update:
#
#                        Now the default HYPERION_HOME --> C:\hyperion\common
#                        Please make sure your jvm location is in the correct locationi on Windows!!
#           Dec. 30, 2003 
#                
#            Set CLASS path under HYPERION_HOME in order not to change anytthing to run CSS, as long as 
#            the $HYPERION_HOME and $ARBORPATH are set correctly.
#   
#
#	   Jan. 26, 2004 Update for 701, 71, and 66, 656, etc:
#			 css-2_0_8.jar --> css-2_5_1.jar
#
#    	   Apr. 1, 2004 update for 71:
#		1) css-2_5_1.jar  --> css-2_5_2.jari
#		2) Common installer for Unix
#
#	  
#	  June 7 Update: css-2_5_2.jar --> css-2_5_3.jar
# 
#	  Oct. 27, 2004 Andrew Zhang
#	        1) Update css-2_5_3.jar --> css-2.6.0.jar 
#		2) Update Java 1.4.1  --> Java 1.4.2
#		3) Added "localhost" before file system for NT only for css2.6.0,
#		   otherwise, it will be failed to get token.
#		
#	Dec. 17, 2004, Andrew Zhang
#                update: css2.6.0 --> css2.6.0.1
#
#	03/11/2005, Andrew Zhang
#		  update: css2.6.0.1 --> css2.7.0
#
#       04/14/2005, Andrew Zhang
#                 update: css2.7.0 --> css3.0.0
#
#	06/29/2005, Andrew Zhang
#		Update: after joyce_beta3, the xml file must be pointed to Hub:
#		"AuthenticationModule css http://stnti9:58080/interop/framework/getCSSConfigFile" 
#		
#       08/25/2005, Andrew Zhang
#                       Updated as per Vinod's recommendation: in order for developers to run this script
#                       without special settings, such running: "sxr sh agtpsetup.sh", which requires
#                       a $LOGNAME.cfg to be pre-checked into the /vobs/essexer/base/data; however,
#                       in order to run this script, you need to have a valid essbase.cfg, which means you need
#                       to be able to start Essbase successfully before running this test.
#
#	09/13/2005, Andrew Zhang
#	Added: CLASSPATH to $HYPERION_HOME/common/SharedServices/9.0.0/lib/commons-httpclient.jar"
#
#	Justifiaction:
#
# 	CSS Hub client in drop 33 requires the commons-httpclient.jar to resolve the css xml file path
# 	when HSS runs on https. We need to make sure either webapp or the classpath contains the 
#	<HYPERION_HOME>/common/SharedServices/9.0.0/client/lib/commons-httpclient.jar.
#
#       11/15/2005, Andrew Zhang
#       Updated for London, added:
#       New CLASSPATH:
#       $HYPERION_HOME/common/CSS/3.0.1/lib/ldapbp.jar
#       and updated css-3_0_0 to css-3_0_1
# 
#	04/12/2006, Andrew Zhang
#	Updated for Conrade, added:
#	
#	06/05/2006, Andrew Zhang
#	Updated for Beckett, css-3_0_1 -->  css-9_3_0    
#     			     JRE version 1.4.2 --> 1.5.0
#
#
#	08/04/2006, Andrew Zhang
# 	Updated for Beckett start from build 204:
#		1) commons-httpclient --> commons-httpclient-3.0.jar
#		2) Added commons-codec-1.3.jar (needed to added to the CLASSPATH)
#
#       06/04/2007, Andrew Zhang#      
#	UPdated for Barnes (9.3.1.0.0)
#		1) css-9_3_0 --> css-9_3_1
#		2) HSS (barnes release)  is on stnti9  
# 	06/26/2007, updated HSS to drop 8 on bnguyen3
#	01/14/2009, Andrew Zhang
#               Updated URL for HSS from bnguyen3 to vmazhang4 (VM iamge) permanently 
########################################################################################	

echo ############################################
echo #
echo #        Test for Single Sign-on
echo #
echo ############################################

HOST=${SXR_DBHOST}
USER=${SXR_USER}
PASSWD=${SXR_PASSWORD}
WORK=${SXR_WORK}
VIEW=${SXR_VIEWHOME}

APP01=AgsyCSS1

DB01=Basic

DATA=Agsytxt.txt

#####################################################
# Preparation functions
#####################################################
create_app ()
{
# ApplicationName
sxr newapp -force $1
}

create_db ()
{
# OutlineName ApplicationName DatabaseName
sxr newdb  -otl $1 $2 $3
}

load_data ()
{
# ApplicationName DatabaseName DataLoadFileName
sxr esscmd msxxloaddataserver.scr  %HOST=$SXR_DBHOST %USER=$SXR_USER %PASSWD=$SXR_PASSWORD \
				   %APPNAME=$1 %DBNAME=$2 %LOADDATA=$3
}

unload_app ()
{
# ApplicationName
sxr esscmd msxxunap.scr	%HOST=$SXR_DBHOST %USER=$SXR_USER %PASSWD=$SXR_PASSWORD \
			%APP=$1
}

delete_app ()
{
# ApplicationName
sxr esscmd msxxrmap.scr 	%HOST=$SXR_DBHOST %USER=$SXR_USER %PASSWD=$SXR_PASSWORD \
				%APP=$1
}


echo_css_location ()
{

echo ""
echo "The css-9_3_1.jar is localted at:"
echo ""
ls -l $HYPERION_HOME/common/CSS/9.3.1/lib/css-9_3_1.jar

if [ $? = 0 ]
then
        echo "\nHYPERION_HOME is set correctly! \n"
else
        echo "\n Please set HYPERION_HOME properly befor you run this CSS test! \n"
        exit
fi

}



##########################################################################################
# Define external users:
#
#  For iPlanet:
# #########################################################
#
# UID1=azhang      -> PWD1=password    -> agsytoken_IP_azhang.out -> agsytoken1.suc / agsytoken1.dif
# UID2=Jeff        -> PWD2=Jeff        -> agsytoken_IP_Jeff.out   -> agsytoken2.suc / agsytoken2.dif
# UID3=Susan       -> PWD3=Susan       -> agsytoken_IP_Susan.out  -> agsytoken3.suc / agsytoken3.dif
# UID4="Prem Gaur" -> PWD4=mypassword  -> agsytoken_IP_Prem.out   -> agsytoken4.suc / agsytoken4.dif
#
#  For MSAD:
# #########################################################
#
# UID5="Andrew G. Zhang" -> PWD5=password    -> agsytoken_AD_Andrew.out   -> agsytoken5.suc/agsytoken6.dif
# UID6="Bao Nguyen"      -> PWD6=password    -> agsytoken_AD_Bao.out      -> agsytoken6.suc/agsytoken7.dif
# UID7="Jeff A. Lee"     -> PWD7=password    -> agsytoken_AD_Jeff.out     -> agsytoken7.suc/agsytoken8.dif
# UID8="John Doe"        -> PWD8="Doe, John" -> agsytoken_AD_John.out     -> agsytoken8.suc/agsytoken10.dif
#
# UID9=anguyen_AD        -> PWD9=password    -> agsytoken_AD_anguyen.out  -> agsytoken9.suc/agsytoken9.dif
# UID10=bnguyen_AD       -> PWD10=password   -> agsytoken_AD_bnguyen.out  -> agsytoken10.suc/agsytoken10.dif
# UID11=cnguyen_AD       -> PWD11=password   -> agsytoken_AD_cnguyen.out  -> agsytoken11.suc/agsytoken11.dif
# UID12=anguyen_AD       -> PWD12=password   -> agsytoken_AD_enguyen.out  -> agsytoken12.suc/agsytoken12.dif
# UID13=hnguyen_AD       -> PWD13=password   -> agsytoken_AD_hnguyen.out  -> agsytoken13.suc/agsytoken13.dif
#
# URL_PATH=$ARBORPATH/bin/sample.xml
############################################################################################


URL_PATH1=http://vmazhang4:28080/interop/framework/getCSSConfigFile 

#After joyce beta2, the xml file must be pointed to Hub
#
#URL_PATH1=$ARBORPATH/bin/sample.xml
#URL_PATH2=http://stnti5/xml_dir/sample.xml
#URL_PATH3=$ARBORPATH/sample.xml


 UID1=azhang
 PWD1=password
 UID2=Jeff
 PWD2=Jeff
 UID3=Susan
 PWD3=Susan
 UID4="Prem Gaur"
 PWD4=mypassword

 UID5="Andrew G. Zhang"
 PWD5=password
 UID6="Bao Nguyen"
 PWD6=password
 UID7="Jeff A. Lee"
 PWD7=password
 UID8="John Doe"
 PWD8="doe, john"

 UID9=anguyen_AD
 PWD9=password
 UID10=bnguyen_AD
 PWD10=password
 UID11=cnguyen_AD
 PWD11=password
 UID12=enguyen_AD
 PWD12=password
 UID13=hnguyen_AD
 PWD13=password

 sxr agtctl stop


mv $ARBORPATH/bin/essbase.sec $ARBORPATH/bin/essbase.sec.bak
cp $(sxr which -data  agsysecAD.sec) $ARBORPATH/bin/essbase.sec
chmod 777  $ARBORPATH/bin/essbase.sec

# 08/25/2005 Azhang 
#mv $ARBORPATH/bin/essbase.cfg $ARBORPATH/bin/essbase.cfg.bak
#cp $(sxr which -data $LOGNAME.cfg) $ARBORPATH/bin/essbase.cfg

cp $ARBORPATH/bin/essbase.cfg $ARBORPATH/bin/essbase.cfg.bak
cat '$(sxr which -data $LOGNAME.cfg)' >> $ARBORPATH/bin/essbase.cfg

chmod 777  $ARBORPATH/bin/essbase.cfg



##################################################################
# Set environment
##################################################################

# After CIS for Unix

export CLASSPATH=".:$HYPERION_HOME/common:\
$HYPERION_HOME/common/CSS/9.3.1/lib/css-9_3_1.jar:\
$HYPERION_HOME/common/CSS/9.3.1/lib/ldapbp.jar:\
$HYPERION_HOME/common/loggers/Log4j/1.2.8/lib/log4j-1.2.8.jar:\
$HYPERION_HOME/common/XML/JDOM/0.8.0/jdom.jar:\
$HYPERION_HOME/common/XML/JAXP/1.2.2/dom.jar:\
$HYPERION_HOME/common/XML/JAXP/1.2.2/jaxp-api.jar:\
$HYPERION_HOME/common/XML/JAXP/1.2.2/sax.jar:\
$HYPERION_HOME/common/XML/JAXP/1.2.2/xsltc.jar:\
$HYPERION_HOME/common/XML/JAXP/1.2.2/xalan.jar:\
$HYPERION_HOME/common/XML/JAXP/1.2.2/xercesImpl.jar:\
$HYPERION_HOME/common/SharedServices/9.3.1/lib/commons-codec-1.3.jar:\
$HYPERION_HOME/common/SharedServices/9.3.1/lib/commons-httpclient-3.0.jar"

uname > setjave.out
BOX=`cat $SXR_WORK/setjave.out`

echo $BOX
if [ $BOX = Windows_NT ]
then

# Check css*jar location

echo_css_location

export JAVAHOME="$HYPERION_HOME/common/JRE/Sun/1.5.0"

export CLASSPATH=".;$HYPERION_HOME/common;\
$HYPERION_HOME/common/CSS/9.3.1/lib/css-9_3_1.jar;\
$HYPERION_HOME/common/CSS/9.3.1/lib/ldapbp.jar;\
$HYPERION_HOME/common/loggers/Log4j/1.2.8/lib/log4j-1.2.8.jar;\
$HYPERION_HOME/common/XML/Jdom/0.8.0/jdom.jar;\
$HYPERION_HOME/common/XML/Jaxp/1.2.2/dom.jar;\
$HYPERION_HOME/common/XML/Jaxp/1.2.2/jaxp-api.jar;\
$HYPERION_HOME/common/XML/Jaxp/1.2.2/sax.jar;\
$HYPERION_HOME/common/XML/Jaxp/1.2.2/jaxp-api.jar;\
$HYPERION_HOME/common/XML/JAXP/1.2.2/xsltc.jar;\
$HYPERION_HOME/common/XML/JAXP/1.2.2/xalan.jar;\
$HYPERION_HOME/common/XML/Jaxp/1.2.2/xercesImpl.jar;\
$HYPERION_HOME/common/SharedServices/9.3.1/lib/commons-codec-1.3.jar;\
$HYPERION_HOME/common/SharedServices/9.3.1/lib/commons-httpclient-3.0.jar"

export PATH="$JAVAHOME/bin/server;$JAVAHOME/bin;$PATH"

echo "JvmModulelocation $HYPERION_HOME/common/JRE/Sun/1.5.0/bin/server/jvm.dll" >> $ARBORPATH/bin/essbase.cfg

echo $ARBORPATH > dummy.cfg

elif [ $BOX = HP-UX ]
then

# Check css*jar location

echo_css_location

export JAVAHOME="$HYPERION_HOME/common/JRE/HP/1.5.0"
export CLASSPATH
export SHLIB_PATH="$JAVAHOME/lib/PA_RISC2.0/server:$JAVAHOME/lib/PA_RISC2.0:$SHLIB_PATH"
export PATH="$JAVAHOME/bin:$PATH"

echo "JVMmodulelocation   $JAVAHOME/lib/PA_RISC2.0/server/libjvm.sl" >> $ARBORPATH/bin/essbase.cfg
echo  $ARBORPATH > dummy.cfg

elif [ $BOX = SunOS ]
then

echo_css_location


export JAVAHOME="$HYPERION_HOME/common/JRE/Sun/1.5.0"
export CLASSPATH
export LD_LIBRARY_PATH="$JAVAHOME/lib/sparc/server:$JAVAHOME/lib/sparc:$LD_LIBRARY_PATH"
export PATH="$JAVAHOME/bin:$PATH"
export ESS_JVM_OPTION2=-Xusealtsigs

echo "JVMmodulelocation   $JAVAHOME/lib/sparc/server/libjvm.so" >> $ARBORPATH/bin/essbase.cfg

echo $ARBORPATH > dummy.cfg

elif [ $BOX = AIX ]
then

# Check css*jar location

echo_css_location

export JAVAHOME="$HYPERION_HOME/common/JRE/IBM/1.5.0"
export CLASSPATH
export LIBPATH="$JAVAHOME/bin/classic:$JAVAHOME/bin:$LIBPATH"

export PATH="$JAVAHOME/bin:$PATH"

echo "JVMmodulelocation    $JAVAHOME/bin/classic/libjvm.a" >> $ARBORPATH/bin/essbase.cfg

echo $ARBORPATH > dummy.cfg

elif [ $BOX = Linux ]

then

# Check css*jar location

echo_css_location

export JRE_HOME="$HYPERION_HOME/common/JRE/Sun/1.5.0"
export CLASSPATH
export LD_LIBRARY_PATH="$JRE_HOME/lib/i386/server:$JRE_HOME/lib/i386:$LD_LIBRARY_PATH"

# For execute java class only:
export PATH="$JRE_HOME/bin:$PATH"

echo "JVMmodulelocation $JRE_HOME/lib/i386/server/libjvm.so" >> $ARBORPATH/bin/essbase.cfg

echo $ARBORPATH > dummy.cfg

fi

# set proper format of PATH of sample.xml file in the essbase.cfg file

ARBORPATH=`cat dummy.cfg`
echo "AuthenticationModule css http://vmazhang4:28080/interop/framework/getCSSConfigFile" >> $ARBORPATH/bin/essbase.cfg
cp $(sxr which -data sample.xml) $ARBORPATH/bin

chmod 777 $ARBORPATH/bin/sample.xml


echo ""
echo "Java version is:"
echo ""
echo " `java -version`"
echo ""
sleep 3

####################################################################
#
# This is to fix the JRE on HP problem only
#
######################################################################

if  [ $BOX = HP-UX ]
then
export LD_PRELOAD="$JAVAHOME/lib/PA_RISC2.0/server/libjsig.sl:\
$JAVAHOME/lib/PA_RISC2.0/server/libjvm.sl"


ESSBASE password -b &
unset LD_PRELOAD

else

	sxr agtctl start
fi

####################################################################################
# Function 3: compare_result
#####################################################################################

compare_result ()
{
# OutputFileName BaselineFileName (by pair)
sxr diff -ignore "Average Clust.*$" -ignore "Average Fragment.*$" \
	 -ignore '\[... .*$' -ignore '\[... .*$' -ignore 'Last login .*$' \
         -ignore 'process id .*$' \
         -ignore 'Total Calc Elapsed Time .*$' \
         -ignore '\[... .*$' -ignore 'Logging out .*$' \
	 -ignore 'Average Fragmentation Quotient .*$' \
	 -ignore '.Time.*$' \
	 $1  $2

if [ $? -eq 0 ]
     then
       echo Success comparing $1
     else
       echo Failure comparing $1
fi
}


##################################
#  create app|db and load data
##################################


create_app $APP01
create_db basic.otl $APP01 $DB01
sxr fcopy -in -data $DATA -out !$APP01!$DB01!
load_data  $APP01 $DB01 $DATA

########################################################
# Create external user
########################################################

export SXR_ESSCMD='essmsh'
sxr esscmd agsycreuserCSS.mxl
export SXR_ESSCMD='ESSCMD'

########################################################
# Grant access permission to users
########################################################

export SXR_ESSCMD='essmsh'
sxr esscmd agsygruserCSS.mxl

export SXR_ESSCMD='ESSCMD'


compare_result 	   agsycreuserCSS.out agsycreuserCSS.bas

compare_result      agsygruserCSS.out  agsygruserCSS.bas


# Get the Java executable file created by Gaurav

sxr fcopy -in -data  CSSAuthenticateForEssbase.class
sxr fcopy -in -data AppContract.class




############################################################################################
# Function 1: To get Token  (combined two Java programs created by Gaurav)
#
# Format:  java CSSAuthenticateForEssbase azhang password  $ARBORPATH/bin/sample.xml > output
#
# Excecution format:  get_token $1 $2 $3 $4 $5 $6
# $1: User Name
# $2: Password
# $3: URL_Path
# $4: Token output files (will be needed to be processed to erase the two spaces:
# $5: suc file if successful
# $6: dif file if failed
#
# E.g:  get_token azhang password $ARBORPATH/bin/sample.xml output token1.suc token1.dif
#
# Note:	The token got from the Java program has two End-0f line char, so need call function 2
#         to eliminate the space for the authentication by ESSCMDQ (LoginByToken)
#
############################################################################################

get_token ()
{
echo ""
echo "Getting token for user $1 now. Please wait for a few seconds... \n"
echo "java CSSAuthenticateForEssbase $1 $2 $3 > $4 \n"

#java CSSAuthenticateForEssbase "$1" "$2" localhost/$3 > $4
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

#####################################################################################
# Function 2: change_token_F ()
# Purpose:    To eliminate 2 spaces in the original token file created by the Java pragrams,
#							in order to be used by ESSCMDQ "LoginByToken"
#
# Excecution format:  change_token_F $1 #2
#                     $1: token file created by the Java program
#                     $2: Correct output token file
#####################################################################################

# cat tokenfile1.out |  # This syntax does not work on NT

change_token_F ()
{
	 token=""      # Initialize the token, otherwise the next output will be appended.
   while read line
   do
				token=$token$line
   #done
   done < $1
	 echo ""
                echo "The Good Token Format for $1 is:"
                echo ""
                echo $token
                echo $token > $2
}



#####################################################################################
# Get token from  "http://avenger"
# I combined two  Java programs created by Gaurav
#####################################################################################

echo "CLASSPATH is: \n"
echo $CLASSPATH

get_token  "$UID1" "$PWD1" "$URL_PATH1"  token_J13_IP_azhang.out  agsytoken_J13-1.suc  agsytoken_J13-1.dif
get_token  "$UID2" "$PWD2" "$URL_PATH1"  token_J13_IP_Jeff.out    agsytoken_J13-2.suc  agsytoken_J13-2.dif
get_token  "$UID3" "$PWD3" "$URL_PATH1"  token_J13_IP_Susan.out   agsytoken_J13-3.suc  agsytoken_J13-3.dif
get_token  "$UID4" "$PWD4" "$URL_PATH1"  token_J13_IP_Prem.out    agsytoken_J13-4.suc  agsytoken_J13-4.dif

get_token  "$UID5" "$PWD5" "$URL_PATH1"  token_J13_AD_Andrew.out  agsytoken_J13-5.suc  agsytoken_J13-5.dif
get_token  "$UID6" "$PWD6" "$URL_PATH1"  token_J13_AD_Bao.out     agsytoken_J13-6.suc  agsytoken_J13-6.dif
get_token  "$UID7" "$PWD7" "$URL_PATH1"  token_J13_AD_Jeff.out    agsytoken_J13-7.suc  agsytoken_J13-7.dif
get_token  "$UID8" "$PWD8" "$URL_PATH1"  token_J13_AD_John.out    agsytoken_J13-8.suc  agsytoken_J13-8.dif

get_token  "$UID9"  "$PWD9" "$URL_PATH1" token_J13_AD_anguyen.out agsytoken_J13-9.suc  agsytoken_J13-9.dif
get_token "$UID10" "$PWD10" "$URL_PATH1" token_J13_AD_bnguyen.out agsytoken_J13-10.suc agsytoken_J13-10.dif
get_token "$UID11" "$PWD11" "$URL_PATH1" token_J13_AD_cnguyen.out agsytoken_J13-11.suc agsytoken_J13-11.dif
get_token "$UID12" "$PWD12" "$URL_PATH1" token_J13_AD_enguyen.out agsytoken_J13-12.suc agsytoken_J13-12.dif
get_token "$UID13" "$PWD13" "$URL_PATH1" token_J13_AD_hnguyen.out agsytoken_J13-13.suc agsytoken_J13-13.dif

#############################
#  Change token format:
#
###############################

change_token_F  token_J13_IP_azhang.out  token_J13_IP_azhang-1.out
change_token_F  token_J13_IP_Jeff.out    token_J13_IP_Jeff-1.out
change_token_F  token_J13_IP_Susan.out   token_J13_IP_Susan-1.out
change_token_F  token_J13_IP_Prem.out    token_J13_IP_Prem-1.out

change_token_F  token_J13_AD_Andrew.out  token_J13_AD_Andrew-1.out
change_token_F  token_J13_AD_Bao.out     token_J13_AD_Bao-1.out
change_token_F  token_J13_AD_Jeff.out    token_J13_AD_Jeff-1.out
change_token_F  token_J13_AD_John.out    token_J13_AD_John-1.out

change_token_F  token_J13_AD_anguyen.out token_J13_AD_anguyen-1.out
change_token_F  token_J13_AD_bnguyen.out token_J13_AD_bnguyen-1.out
change_token_F  token_J13_AD_cnguyen.out token_J13_AD_cnguyen-1.out
change_token_F  token_J13_AD_enguyen.out token_J13_AD_enguyen-1.out
change_token_F  token_J13_AD_hnguyen.out token_J13_AD_hnguyen-1.out

##########################################################################
#  LoginByToken part 1:
#  Expected resuls: 13 suc file: (eg. loginbytoken_J13_AD_Andrew-1.suc)
##########################################################################

sxr sh agsyloginbytoken1_J13.sh


##########################################################################
#  LoginByToken part 2:
#  Expected resuls: 13 suc file: (eg. loginbypassword_AD_Andrew-2.suc)
#  After 10 minutes, the token will expire, then login by token will fail
##########################################################################

echo "Wait for 10 minutes after the token failed...."
sleep 600

sxr sh agsyloginbytoken2_J13.sh


################################################################################
# Test for Login By password, expected to be all successful even token expired
# Test Script: 		agsyloginbypassword_J13.sh
################################################################################

sxr sh agsyloginbypassword_J13.sh


################################################################################
# Test for CSS error cases
# Test Script: 		agsycss_error_J13.sh
################################################################################

$ This is handled by CSS group
# sxr sh agsyloginbytoken_J13_err.sh


######################################################################
#
# Additional correctness testing
######################################################################

############################################################################
# correctness case 1:
# Test PATH at: "AuthenticationModule css http://stnti5/xml_dir/sample.xml"
# Expected to be successful!
######################################################################

# Not needed now after Joyce beta2...


############################################################################
#  correctness case 3:
#  Test the css with different case: css is case insensitive
#  Expected to bu successful!
###########################################################################

# Not needed now after Joyce beta2...

sxr agtctl stop

#
#  Cleanup

unload_app $APP01
delete_app $APP01
sxr agtctl stop

mv $ARBORPATH/bin/essbase.cfg.bak  $ARBORPATH/bin/essbase.cfg
mv $ARBORPATH/bin/essbase.sec.bak  $ARBORPATH/bin/essbase.sec
