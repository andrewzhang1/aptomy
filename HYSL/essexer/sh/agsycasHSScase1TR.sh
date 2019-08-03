#: Script: agsycasHSScase1TR.sh
#: Authors: bao nguyen
#: Reviewers: Jock Chau
#: Date:
#: Purpose: user with global roles starting from CAS mode security
#       HSSc1_u1 -- admin
#       HSSc1_u2 -- create_user
#       HSSc1_u3 -- app_create user
#       HSSc1_u4 -- no_access
#       HSSc1_u5 -- admin disable user
#: Owned by: bao nguyen
#: Tag: FEATURE
#: Component: AGNT
#: Subcomponents: SEC
#: Dependencies: None
#: Runnable: true
#: Arguments: none
#: Customer name: None
#: Memory/Disk: 100MB/50MB
#: Execution Time (minutes): 6
#: Machine for Statistics: aix64 (12cpu and 8gb RAM)
#: SUC: 7
#: Created for: Essbase
#: Retired for:
#: Test cases: User provisioning
#: History:
# -- modify so it run in Talleyrand and later
#: 6/07/13  bao nguyen          add header
#########################################################################

# common function
. `sxr which -sh esscmd.func`

# variable
FILE=agsycasHSSc1
USER=admin

# local function
delete_entity ()
{
sxr esscmd -q agsydelentity.scr %HOST=${SXR_DBHOST} %UID=${1} \
        %PWD=${SXR_PASSWORD} %ENAME="${2}" %ETYPE=${3}
}

app_unload ()
{
# AppName
sxr esscmd msxxunloadapp.scr %HOST=$SXR_DBHOST %UID="$1" %PWD=$SXR_PASSWORD %APP=$2
}

#----------------------------------MAIN-------------------------------------#
sxr agtctl start

#sxr msh agsycascvmode.msh pwd_pwd ${USER} ${SXR_PASSWORD} ${SXR_DBHOST} ${FILE}_cvmode.out

sxr msh agsycasHSSc1_a.msh ${USER} ${SXR_PASSWORD} ${SXR_DBHOST} \
	${FILE}_aTR.out

sxr diff ${FILE}_aTR.out
if [ -f ${FILE}_aTR.dif ]
then
for u in u1 u2 u3 u4 u5 grp1u1 grp2u1 grp3u1 grp4u1 grp5u1
do
delete_entity $USER "HSSc1_${u}" "2"
done

for g in grp1 grp2 grp3 grp4 grp5
do
delete_entity ${USER} "HSSc1_${g}" "1"
done
app_unload ${USER} Sample
    sxr msh ${FILE}_dTR.msh ${USER} ${SXR_PASSWORD} ${SXR_DBHOST}
    exit 1
fi

sxr msh ${FILE}_b.msh ${FILE}_bTR.out ${SXR_DBHOST}
sxr diff -ignore "password on.*$" -ignore "Last login .*$" -ignore "native:\/\/.*$" -ignore "process id .*$" -ignore "Network Info.*$" -ignore "TRUE" -ignore "FALSE" -ignore "10240" -ignore "20480" ${FILE}_bTR.out

sxr msh ${FILE}_e.msh ${USER} ${SXR_PASSWORD} ${SXR_DBHOST} ${FILE}_eTR.out
sxr diff ${FILE}_eTR.out

sxr msh ${FILE}_c.msh ${USER} ${SXR_PASSWORD} ${SXR_DBHOST} ${FILE}_cTR.out
sxr diff -ignore "\[Cannot find .*\]" ${FILE}_cTR.out

sxr msh agsycasresync.msh system_sync ${USER} ${SXR_PASSWORD} ${SXR_DBHOST}
sxr msh ${FILE}_b.msh ${FILE}_b01TR.out ${SXR_DBHOST}
sxr diff -ignore "password on.*$" -ignore "Last login .*$" -ignore "native:\/\/.*$" -ignore "process id .*$" -ignore "Network Info.*$" -ignore "TRUE" -ignore "FALSE" -ignore "10240" -ignore "20480" ${FILE}_b01TR.out

sxr msh ${FILE}_f.msh ${FILE}_fTR.out ${SXR_DBHOST}
sxr diff -ignore "password on.*$" -ignore "Last login .*$" -ignore "native:\/\/.*$" -ignore "process id .*$" -ignore "Network Info.*$" -ignore "TRUE" -ignore "FALSE" -ignore "10240" -ignore "20480" ${FILE}_fTR.out

for u in u1 u2 u3 u4 u5 grp1u1 grp2u1 grp3u1 grp4u1 grp5u1 
do
delete_entity $USER "HSSc1_${u}" "2"
done

for g in grp1 grp2 grp3 grp4 grp5
do
delete_entity ${USER} "HSSc1_${g}" "1"
done
app_unload ${USER} Sample

sxr msh ${FILE}_dTR.msh ${USER} ${SXR_PASSWORD} ${SXR_DBHOST} ${FILE}_dTR.out
sxr diff ${FILE}_dTR.out

