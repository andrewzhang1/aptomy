#!/bin/ksh

##############################################################################
#
# Script Name: dircomp.sh
# Script Duty: to compare the directory tree structure of two different 
#              releases/builds of Essbase, EAS, EDS, and SVP 
# Author: Tuan M. Mai
# Date: 07/05/2006
# Collaborator: Rumitkar Kumar, as author of the jar extraction, 
#               image making, and tree comparison scripts.
#
##############################################################################


if [ $# -ge 6 -o $# -le 7 ] ; then echo "\nStarting DirComp..."
else
	echo "\n\nYou must enter exactly the proper number of arguments to the command..."
	exit 1;
fi

export STARTING_DIR=`pwd`
echo $STARTING_DIR

#Run compdir profile
. unixCompDirProfile.sh

#Run cleantemp.sh
. cleantemp.sh

export PRODUCT=$1
export PRODUCT_ONE_BRANCH=$2
export PRODUCT_ONE_BUILD=$3
export PRODUCT_TWO_BRANCH=$4
export PRODUCT_TWO_BUILD=$5
export HYPERIONCOMP_HOME=$6
export JARORNOT=$7
if [ "$JARORNOT" = "extractjar" ] ; then
	export SOLARISAIX=$8
else
	export SOLARISAIX=$7
fi

export PRODUCT_ONE_IMG="$PRODUCT"_"$PRODUCT_ONE_BRANCH"_"$PRODUCT_ONE_BUILD"_img
echo "PRODUCT_ONE_IMG: $PRODUCT_ONE_IMG"
export PRODUCT_TWO_IMG="$PRODUCT"_"$PRODUCT_TWO_BRANCH"_"$PRODUCT_TWO_BUILD"_img
echo "PRODUCT_TWO_IMG: $PRODUCT_TWO_IMG"
export PRODUCT_ONE_TWO_DIFF="$PRODUCT"_"$PRODUCT_ONE_BRANCH"_"$PRODUCT_ONE_BUILD"_"$PRODUCT_TWO_BRANCH"_"$PRODUCT_TWO_BUILD"_diff
echo "PRODUCT_ONE_TWO_DIFF: $PRODUCT_ONE_TWO_DIFF"
export PRODUCT_TWO_ONE_DIFF="$PRODUCT"_"$PRODUCT_TWO_BRANCH"_"$PRODUCT_TWO_BUILD"_"$PRODUCT_ONE_BRANCH"_"$PRODUCT_ONE_BUILD"_diff
echo "PRODUCT_TWO_ONE_DIFF: $PRODUCT_TWO_ONE_DIFF"

CLEANUP_FOLDER=dircomp_"$PRODUCT"_"$PRODUCT_ONE_BRANCH"_"$PRODUCT_ONE_BUILD"_"$PRODUCT_TWO_BRANCH"_"$PRODUCT_TWO_BUILD"
echo "CLEANUP_FOLDER: $CLEANUP_FOLDER"
HYPERIONCOMP_PRODUCT_ONE=$HYPERIONCOMP_HOME/Hyperion_"$PRODUCT"_"$PRODUCT_ONE_BRANCH"_"$PRODUCT_ONE_BUILD"
echo "Product One directory: $HYPERIONCOMP_PRODUCT_ONE"
HYPERIONCOMP_PRODUCT_TWO=$HYPERIONCOMP_HOME/Hyperion_"$PRODUCT"_"$PRODUCT_TWO_BRANCH"_"$PRODUCT_TWO_BUILD"
echo "PRODUCT Two directory: $HYPERIONCOMP_PRODUCT_TWO"


############################################################################

#Un-comment the line below to use Win64 machines
#export PROCESSOR_ARCHITECTURE=IA64

##### Get OS Platform #####
OSP=`uname`
export PROCESSOR=`uname -m`

typeset -l OSP=$OSP

case $OSP in
	linux	)	;;
	aix	) 	if [ "$SOLARISAIX" = "64bitaixsol" ] ; then
				OSP="aix64"
			fi
			;;	
	hpux	)	;;
	hp-ux	)	if [ "$PROCESSOR" = "ia64" ] ; then OSP="hpux64" 
			else OSP="hpux" ; fi
			;;
	hpux64	) 	;;	
	solaris	)	if [ "$SOLARISAIX" = "64bitaixsol" ] ; then
				OSP="solaris64"
			fi
			;;	
	sunos	)	OSP="solaris" 
			if [ "$SOLARISAIX" = "64bitaixsol" ] ; then
				OSP="solaris64"
			fi
			;;
	windows_nt)	touch isitia64
			echo $PROCESSOR_IDENTIFIER >> isitia64
	
			if grep "ia64" isitia64 ; then OSP='win64'
			else OSP='win32' ; fi
			rm isitia64
			;;
	*	)	echo "\nIncorrect Platform Indicated."
			exit ;;
esac
export OSP

if [ "$OSP" = "win32" -o "$OSP" = "win64" ] ; then
	echo "Installing BIN directory to Win path..."	
	export PATH="$HOME/bin;$PATH"
else
	echo "Installing BIN directory to Unix path..."
	export PATH=$HOME/bin:$PATH
fi

######################################
######### SUPPORT FUNCTIONS ##########

clean() {

# Cleans up vpd.properties file and remove Essbase, EAS, EDS, and SVP processes

echo "Killing any Essbase, EAS, EDS, and SVP processes that cannot normally shutdown."

	ps -fu $LOGNAME | grep -i java | grep -v grep > processID
	ps -fu $LOGNAME | grep -i JDK | grep -v grep >> processID
	ps -fu $LOGNAME | grep -i startEAS | grep -v grep >> processID
	ps -fu $LOGNAME | grep -i startEDS | grep -v grep >> processID
        ps -fu $LOGNAME | grep -i server1 | grep -v grep >> processID
	ps -fu $LOGNAME | grep -i admin | grep -v grep >> processID
	if [ "$OSP" = "win32" -o "$OSP" = "win64" ] ; then 
		ps -ef | grep -i mysqld | grep -v grep >> processID
	else
		ps -fu $LOGNAME | grep -i mysql | grep -v grep >> processID
	fi
	ps -fu $LOGNAME | grep -i esscmd | grep -v grep >> processID
	ps -fu $LOGNAME | grep -i ESSSVR | grep -v grep >> processID
	ps -fu $LOGNAME | grep -i ESSBASE | grep -iv essbasesxr | grep -v grep >> processID

	cat processID | while read line
		do
			set $line
			echo $2
			sleep 1
			kill -9 $2
		done
	rm processID

	if [ "$OSP" = "win32" ] ; then
		#Remove vpd.properties in stnti19 C: Drive
		echo "Deleting vpd.properties..."
		#cd C:/
		#cd Documents*
		#cd tmai
		#cd Windows
		rm -fR C:/Documents*/tmai/Windows/vpd.properties
	fi

	if [ "$OSP" = "win64" ] ; then
		#Remove vpd.properties in emc-iant01 F: Drive
		echo "Deleting vpd.properties..."
		#cd F:/
		#cd Documents*
		#cd tmai
		#cd Windows
		rm -fR F:/Documents*/tmai/Windows/vpd.properties
		rm -fR F:/Windows/vpd.properties
	fi
		
	if [ -a $HOME/vpd.properties ] ; then
		echo "Deleting vpd.properties..."
		rm -Rf "$HOME/vpd.properties"
	fi
}
#######################################################################

PRODUCT_ONE_TWO_DIFF="$OSP"_"$PRODUCT_ONE_TWO_DIFF"
echo $PRODUCT_ONE_TWO_DIFF
PRODUCT_TWO_ONE_DIFF="$OSP"_"$PRODUCT_TWO_ONE_DIFF"
echo $PRODUCT_TWO_ONE_DIFF
CLEANUP_FOLDER="$OSP"_"$CLEANUP_FOLDER"
echo $CLEANUP_FOLDER
	
##### Create comparison directory #####
mkdir $HYPERIONCOMP_HOME
export HYPERION_HOME=$HYPERIONCOMP_HOME/Hyperion
echo $HYPERION_HOME
rm -fR ~/.hyperion.`hostname`
touch ~/.hyperion.`hostname`
echo "HYPERION_HOME=$HYPERION_HOME" >> ~/.hyperion.`hostname`

echo "\nPHASE ONE COMPLETED."
echo "\nOSP=$OSP"
#read phaseone

############### INSTALLATION OF PRODUCT #1 ##################################

#Kill all Hyperion processes.
clean 

echo "\nPHASE TWO, KILL PROCESSES PRODUCT #1, COMPLETED"
#read phasetwo

INSTALLER=installer_`echo $PRODUCT_ONE_BRANCH`.sh
$HOME/bin/installer/$INSTALLER $PRODUCT $PRODUCT_ONE_BUILD $OSP

#echo "Install First Product....Press ENTER when Done"
#read pause1

echo "\nPHASE THREE, INSTALLATION OF PRODUCT 1, COMPLETED"
#read phasethree

############### PREPARATION SECTION OF PRODUCT #1 ##################
cd $HYPERIONCOMP_HOME

#extract jar files

if [ "$JARORNOT" = "extractjar" ] ; then
	esbcompjar.sh Hyperion
	esbcompjar.sh Hyperion
else
	echo "\nSkipping jar extraction..."
fi

#create image
echo "\nCreating image..."
esbcompimg.sh Hyperion > $PRODUCT_ONE_IMG

#delete Hyperion product
echo "\nDeleting Product 1..."
rm -fR Hyperion

echo "\nPHASE FOUR, PREPARATION AND IMAGING, COMPLETED"
#read phasefour

############### INSTALLATION SECTION OF PRODUCT #2 ###############

# Kill all processes
clean 

echo "\nPHASE FIVE, CLEANING OF PROCESSES BEFORE PRODUCT #2, COMPLETED"
#read phasefive

INSTALLER=installer_`echo $PRODUCT_TWO_BRANCH`.sh
$HOME/bin/installer/$INSTALLER $PRODUCT $PRODUCT_TWO_BUILD $OSP

#echo "Install Product #2, then press ENTER"
#read pause2

echo "\nPHASE SIX, INSTALLATION OF PRODUCT 2, COMPLETED"
#read phasesix

############### PREPARATION SECTION OF PRODUCT #2 ##################

cd $HYPERIONCOMP_HOME

#extract jar files
if [ "$JARORNOT" = "extractjar" ] ; then
	esbcompjar.sh Hyperion
	esbcompjar.sh Hyperion
else
	echo "\nSkipping jar extraction"
fi

#create image
echo "\nCreating image..."
esbcompimg.sh Hyperion > $PRODUCT_TWO_IMG

#delete the second product
echo "\nDeleting Product 2..."
rm -fR Hyperion

echo "\nPHASE SEVEN, PREPARATION AND IMAGING OF PRODUCT 2, COMPLETED"
#read phaseseven

################# COPY IMAGES OFF TO $HOME ###############

mkdir $HOME/diffHYSL/$CLEANUP_FOLDER
cp $PRODUCT_ONE_IMG $HOME/diffHYSL/$CLEANUP_FOLDER
cp $PRODUCT_TWO_IMG $HOME/diffHYSL/$CLEANUP_FOLDER

################# COMPARISON SECTION #####################

echo "\nComparing the two image files, first diff..."
if [ "$OSP" = "hpux" -o "$OSP" = "hpux64" ] ; then
	esbcompdiffhp.sh $PRODUCT_ONE_IMG $PRODUCT_TWO_IMG > $PRODUCT_ONE_TWO_DIFF
else
	esbcompdiff.sh $PRODUCT_ONE_IMG $PRODUCT_TWO_IMG > $PRODUCT_ONE_TWO_DIFF
fi

echo "\nComparing the two image files, second diff..."
if [ "$OSP" = "hpux" -o "$OSP" = "hpux64" ] ; then
	esbcompdiffhp.sh $PRODUCT_TWO_IMG $PRODUCT_ONE_IMG > $PRODUCT_TWO_ONE_DIFF
else
	esbcompdiff.sh $PRODUCT_TWO_IMG $PRODUCT_ONE_IMG > $PRODUCT_TWO_ONE_DIFF
fi

echo "\nPHASE EIGHT, COMPARISON OF IMAGES, COMPLETED"
#read phaseeight

################# CLEANUP SECTION ##############################

mv $PRODUCT_ONE_TWO_DIFF $HOME/diffHYSL/$CLEANUP_FOLDER
mv $PRODUCT_TWO_ONE_DIFF $HOME/diffHYSL/$CLEANUP_FOLDER

rm -fR $PRODUCT_ONE_IMG
rm -fR $PRODUCT_TWO_IMG

cd ~
echo $HYPERIONCOMP_HOME
rm -fR $HYPERIONCOMP_HOME     

echo "\nPHASE NINE, CLEANUP OF COMPARISON FOLDERS, COMPLETED"
#read phasenine

#Run cleantemp.sh 
cd $STARTING_DIR
. cleantemp.sh


#For case when ESB is solaris and AIX for Beckett onwards, we will need to compare twice for both Solaris32 and Solaris64, and AIX and AIX64
if [ "$OSP" = "solaris" -o "$OSP" = "aix" ] ; then
	dircomp.sh $1 $2 $3 $4 $5 $6 $7 64bitaixsol
fi	

echo "\n\nDirComp Completed..."

