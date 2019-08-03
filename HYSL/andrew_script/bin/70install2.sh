#Start 70regress.sh
BOX=$(uname)
BUILDNAME="$1"
INSTLOPTION="$2"
TARFILE="esb7000"
REGISTRATION_NUMBER="009999 063A211A-014 BB647BAC"

#KILL ESSBASE process, if there is any
ps -fu $LOGNAME  | grep -i esscmd > processID
ps -fu $LOGNAME  | grep -i ESSSVR >> processID
ps -fu $LOGNAME  | grep -i ESSBASE >> processID

cat processID  |
        while read line
        do
                set $line
                echo $2
                sleep 1
                kill -9 $2
        done
rm processID



#Get Build_location 
testbranch=${BUILDNAME%:*}
 echo  "testbranch is $testbranch"
testversion=${BUILDNAME#*:}
 echo  "testversion is $testversion"
if ( test "$testbranch" != "$(ls $BUILD_ROOT | fgrep -x "$testbranch" )" )
then
  echo "1:Missing or invalid build tree, exiting"
  echo "check first part of the argument and BUILD_ROOT value"
  exit 2
else
  BRANCH="$testbranch"
fi

if ( test -n "$testversion")
then
    if ( test "$testversion" != "$(ls $BUILD_ROOT/$BRANCH | fgrep -x "$testversion" )" )
    then
       echo "Unrecognized build version, exiting"
       echo "check second part of the argument and presense of a colon"
VERSION="$testversion"
    else
       VERSION="$testversion"
	echo "test is $testversion"
    fi
else
    echo "Missing or nonspecified build version, using LATEST"
    VERSION=latest
fi

BUILD_LOCATION="$BUILD_ROOT/$BRANCH/$VERSION"
echo $BUILD_LOCATION




#Refresh to get the ESSCMDQ ESSCMDG
cd $ARBORPATH
rm -rf *
echo $BUILDNAME 
if [ $BOX = Linux ]
then
      refreshl $BUILDNAME
	echo "here"
else
      refresh $BUILDNAME
fi

mv bin bin_r
rm -rf app
rm -rf java
rm -rf locale

#Install from BUILD_ROOT
mkdir tar
if [ $BOX = AIX ]
then
     CD_LOCATION="aix"
     TRFILE=${TARFILE}a
     echo $TARFILE
elif [ $BOX = HP-UX ]
then
     CD_LOCATION="hpux"
	TRFILE=${TARFILE}h
      echo $TARFILE
elif [ $BOX = SunOS ]
then
        CD_LOCATION="solaris"
	TRFILE=${TARFILE}s
      echo $TARFILE
elif [ $BOX = Linux ]
then
 echo $CD_LOCATION
         CD_LOCATION="linux"
	TRFILE=${TARFILE}l
      echo $TARFILE
fi


if  [ $INSTLOPTION = 1 ]
then
	echo "Installing Runtime"
	echo $ARBORPATH
	#cd $BUILD_LOCATION/cd/$CD_LOCATION/runtime
       cp $BUILD_LOCATION/cd.zip/${TRFILE}r.tar $ARBORPATH/tar/.
        cd $ARBORPATH/tar
        tar xvf *tar
      echo $ARBORPATH
        echo "10019435063A619A-064FA6A7A4E"
	./essinst

elif [ $INSTLOPTION = 2 ]
then
	echo "Installing API"
	#cd $BUILD_LOCATION/cd/$CD_LOCATION/api
       cp $BUILD_LOCATION/cd.zip/${TRFILE}a.tar $ARBORPATH/tar/.
        cd $ARBORPATH/tar
        tar xvf *tar
      echo $ARBORPATH
        echo "10019435063A619A-064FA6A7A4E"

	./essinst


elif [ $INSTLOPTION = 3 ]
then 
	echo "Installing server"
	
	#cd  $BUILD_LOCATION/cd/$CD_LOCATION/server
	cp $BUILD_LOCATION/cd.zip/${TRFILE}s.tar $ARBORPATH/tar/.
	cd $ARBORPATH/tar
	tar xvf *tar
      echo $ARBORPATH
        echo "10019435063A619A-064FA6A7A4E"

	./essinst
fi	

#Install from BUILD_ROOT
#cd $BUILD_LOCATION/cd
#echo $ARBORPATH
#echo "10019435063A619A-064FA6A7A4E"
#./setup.sh 

cd $ARBORPATH
#cp $HOME/essbase.cfg bin/.
cp bin_r/ESSCMDG bin/.
cp bin_r/ESSCMDQ bin/.
echo "Agentport 2208" >> $ARBORPATH/bin/essbase.cfg
 
if [ $BOX = AIX ]
then
#   cp $HOME/aix_essbase.sec bin/essbase.sec
   echo  "Copying aix_essbase.sec"

elif [ $BOX = HP-UX ]
then  
  cp $HOME/hp_essbase.sec bin/essbase.sec
   echo "copying hp_essbase.sec"
elif [ $BOX = SunOS ]
then 
#  cp $HOME/sun_essbase.sec bin/essbase.sec
   echo "copying sun_essbase.sec"

elif [ $BOX = Linux ]
then
   cp $HOME/linux_essbase.sec bin/essbase.sec
   echo "copying linux_essbase.sec"
else
	echo "no sec file is copied"
fi

#Starting ESSBASE
#ESSBASE password -b &

#Test Samples
#ESSCMD $HOME/samples.scr

cd $ARBORPATH

