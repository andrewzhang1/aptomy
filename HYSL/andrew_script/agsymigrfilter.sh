#################################
# Created by : Bao Nguyen	      #
# Date 	     : 5/11/03	 	      #
# Filename   : agsymigrfilter.sh#
# Time	     : 			#
# Updated by: Andrew Zhang         #
#             6/12/03             #
#################################

# Description: migration from filter

# Running from command line:
# sxr sh agsymigrfilter.sh 6.5:6.5.3.0/ga   zephyr:276

 # Test:  list filter, get filters,
# output file: agsymigrfilter_listfil.out agsymigrfilter_gettfil.out



# Variable
APP=Migfil
DB=Basic
OTL=agsyunicode
COUNT=51

sxr agtctl stop

#-----------------------#
# refresh older version #
#-----------------------#
echo "download older version refresh:${1}"
refresh ${1}

cp `sxr which -data msxxnull.sec` ${ARBORPATH}/bin/essbase.sec

sxr agtctl start

if [ $? -ne 0 ]
then
	echo "Failed to start Essbase !!ERROR ABORTED!!"
	exit 1
fi

sxr newapp -force ${APP}
sxr newdb -otl ${OTL}.otl ${APP} ${DB}

#-------------------------#
# create filter on app/db #
#-------------------------#
FILTER=Single
let i=1
while [ ${i} -lt ${COUNT} ]
do
sxr esscmd -q aqtcrefilter01.scr %OUT="${FILTER}${i}.out" %HOST=${SXR_DBHOST} \
		%USER=${SXR_USER} %PWD=${SXR_PASSWORD} %APP=${APP} %DB=${DB} \
		%FILTER=${FILTER}${i} \
		%MEM="Year,Measures,Product,Market,Scenario" %ACC="0"
let i=${i}+1
done

FILTER=Double
let i=1
while [ ${i} -lt ${COUNT} ]
do
sxr esscmd -q aqtcrefilter02.scr %OUT="${FILTER}${i}.out" %HOST=${SXR_DBHOST} \
                %USER=${SXR_USER} %PWD=${SXR_PASSWORD} %APP=${APP} %DB=${DB} \
                %FILTER=${FILTER}${i} \
		%MEM1="Qtr1,Qtr2,Qtr3,Qtr4" %ACC1="0" \
		%MEM2="Profit" %ACC2="1"
let i=${i}+1
done

FILTER=Triple
let i=1
while [ ${i} -lt ${COUNT} ]
do
sxr esscmd -q aqtcrefilter03.scr %OUT="${FILTER}${i}.out" %HOST=${SXR_DBHOST} \
                %USER=${SXR_USER} %PWD=${SXR_PASSWORD} %APP=${APP} %DB=${DB} \
                %FILTER=${FILTER}${i} \
		%MEM1="Product" %ACC1="0" \
                %MEM2="Year" %ACC2="1" \
		%MEM3="Measures" %ACC3="2"
let i=${i}+1
done

FILTER=Qtuplet
let i=1
while [ ${i} -lt ${COUNT} ]
do
sxr esscmd -q aqtcrefilter04.scr %OUT="${FILTER}${i}.out" %HOST=${SXR_DBHOST} \
                %USER=${SXR_USER} %PWD=${SXR_PASSWORD} %APP=${APP} %DB=${DB} \
                %FILTER=${FILTER}${i} \
                %MEM1="Qtr1,Jan" %ACC1="0" \
                %MEM2="Qtr2,May,Jun" %ACC2="1" \
                %MEM3="Qtr3,Jul,Aug,Sep" %ACC3="2" \
		%MEM4="Qtr4,Oct,Nov,Dec" %ACC4="2"
let i=${i}+1
done

sxr agtctl stop

if [ $? -ne 0 ]
then
	echo "Failed to stop Essbase !!ERROR ABORTED!!"
	exit 1
fi

#------------------------#
# refresh latest version #
#------------------------#

echo "update to new version refresh:${2}"
 refresh ${2}

sxr agtctl start

if [ $? -ne 0 ]
then
        echo "Failed to start Essbase !!ERROR ABORTED!!"
        exit 1
fi


#------------------#
# list filter      #
#------------------#

sxr esscmd -q aqtlistfilter_mg.scr %OUT=agsymigrfilter_listfil.out %HOST=${SXR_DBHOST} \
		%UID=${SXR_USER} %PWD=${SXR_PASSWORD}

#------------------#
# get fitlers      #
#------------------#

sxr esscmd -q aqtgetfilter_mg.scr %OUT=agsymigrfilter_getfil.out %HOST=${SXR_DBHOST} \
		%UID=${SXR_USER} %PWD=${SXR_PASSWORD}


sxr diff agsymigrfilter_listfil.out agsymigrfilter_listfil.bas
sxr diff agsymigrfilter_getfil.out  agsymigrfilter_getfil.bas

# clean app
echo "Delete application..."


sxr esscmd -q msxxdeleteapp.scr   %HOST=${SXR_DBHOST} %UID=${SXR_USER} \
                 %PWD=${SXR_PASSWORD} %APP=$APP %DB=${DB}


sxr agtctl stop
