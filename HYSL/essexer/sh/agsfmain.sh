#!/bin/ksh

#: Authors: Pardha Saradhi
#: Reviewers: Govi Rajagopal
#: Date: 04/25/2010
#: Purpose: Fusion security automation main script 
#: Owned by: Pardha Saradhi Chinta
#: GTLF_testunit: Fusion_Security_mode
#: Tag: DS100M,  SY
#: Dependencies: esscmd.func, 
#       Also make sure the oracle schema which contains the FND security stored procedures is accessible for FND filter test case execution. 
#       For FND schema details refer to 'agsf_FusionEnv.txt'
#       Also the GL database should be up and running before script execution 
#: Runnable: true
#: Arguments: none
#: Memory/Disk: 200MB / 1GB
#: Execution Time (minutes): 50 min
#: SUC: 307
#: History:
#     July 11 ' 2011 (added new scritps for restructure / mdx query concurrency tests)
#     Oct 10' 2011 (updating the script to resolve execution issues after placing scritps in clearcase.)
#     Aug 05' 2012 - Updated the script as per review comments, also handled user/group creation and map/key crdeation for FND security in this script to integrate this script with main regression
#     Jun 13' 2013 - Removed the code to construct ORACLE_HOME, WL_HOME based on essbase.cfg settings. Instead of that added code to construct these variables based on HYPERION_HOME variable which is available from SXR as well as autopilot frameworks.
#-----------------------------------------------------------------------------

#-----------------------------------------------------------------------------
# Pre-requisite:
# -- Before running the script make sure essbase.cfg additional log entries for eg. LoginFailureMessageDetailed TRUE, AgentLogMessageLevel DEBUG, Event 64 are NOT set.
#-----------------------------------------------------------------------------

. `sxr which -sh essbase.func`
. `sxr which -sh esscmd.func`


diff_output()
{

#-----------------------------------------------------------------------------
# Currently there are some issues with baselines that some of the them are in dos format. Need to update the baselines in clearcase and once done the following lines can be removed
#-----------------------------------------------------------------------------
sxr fcopy -in $(sxr which -log $1.bas) -out $SXR_WORK/../log
chmod 777 $SXR_WORK/../log/$1.bas
dos2unix $SXR_WORK/../log/$1.bas

sxr diff -ignore $SXR_USER -ignore $SXR_PASSWORD -ignore $ffltusr1 -ignore $ffltpwd1 -ignore $ffltusr2 -ignore $ffltpwd2 -ignore $ffltusr3 -ignore $ffltpwd3 -ignore $SXR_DBHOST -ignore $ffltgrp1 -ignore ".*process id .*" -ignore ".*SSL initialization .*" -ignore $fadmgrp1 -ignore $fadmusr1 -ignore $fadmpwd1 -ignore $fusr_noGroup -ignore $fusr_noGroup_pwd -ignore $fUsr_sameAS_Grp1 -ignore $fUsr_sameAS_Grp_pwd1 -ignore $fGrp_sameAS_Usr1 -ignore $fUsr_sameAS_Grp2 -ignore $fUsr_sameAS_Grp_pwd2 -ignore $fGrp_sameAS_Usr2 $1.out $1.bas
}

sxr agtctl start

#-----------------------------------------------------------------------------
# -- This part of code sets the required environment variables at runtime as per the variables/values that are set in $FusionEnv file. $FusionEnv is set in .sxrrc file.
#-----------------------------------------------------------------------------

for x in `cat $(sxr which -data agsf_FusionEnv.txt)|grep -v '#'`
do
    echo "export $x " >> agsf_setEnv.sh
done
chmod 777 agsf_setEnv.sh
. ./agsf_setEnv.sh
# ----------------------------------------------------------------------

echo "HYPERION_HOME=" $HYPERION_HOME

if [ -z "$ORACLE_HOME" ]
then
    export ORACLE_HOME=$HYPERION_HOME
    echo "ORACLE_HOME=" $ORACLE_HOME
fi
if [ -z "$WL_HOME" ]
then
    export WL_HOME=${HYPERION_HOME%/*}/wlserver_10.3
    echo "WL_HOME=" $WL_HOME
fi


case "$SXR_PLATFORM" in
nti | nta | win95 )

# ----------------------------------------------------------------------
# Create the required test users and groups in weblogic ldap which are required for test
# ----------------------------------------------------------------------
sxr sh agsf_createusrgrp.sh $(sxr which -data agsf_user_groups_win.py) $SXR_USER $SXR_PASSWORD $(sxr which -data agsf_usrgrp.properties)

# ----------------------------------------------------------------------
# Crate map/key entries in Credential store - which are required for FND Security Credential store test case execution
# ----------------------------------------------------------------------
sxr sh agsf_create_map_key.cmd $(sxr which -data agsf_map_key.py) $SXR_USER $SXR_PASSWORD $fnd_ora_user $fnd_ora_pwd
;;

solarisx86 | solaris | hpux | aix | linux )
# ----------------------------------------------------------------------
# Create the required test users and groups in weblogic ldap which are required for test
# ----------------------------------------------------------------------
sxr sh agsf_createusrgrp.sh $(sxr which -data agsf_user_groups.py) $SXR_USER $SXR_PASSWORD $(sxr which -data agsf_usrgrp.properties)

# ----------------------------------------------------------------------
# Crate map/key entries in Credential store - which are required for FND Security Credential store test case execution
# ----------------------------------------------------------------------
sxr sh agsf_createmap_key.sh $(sxr which -data agsf_map_key.py) $SXR_USER $SXR_PASSWORD $fnd_ora_user $fnd_ora_pwd
;;
esac



#----------------------------------------------------------------------------
# -- Creation of Fusion test apps - aso and BSO apps --
#-----------------------------------------------------------------------------


export facxap1=facxap1
export facxdb1=facxdb1
export facxotl1=facxotl1.otl

# creation of BSO application facxap1 (this application is same as Essbase sample application 'sample-basic')
sxr newapp -force $facxap1
sxr newdb -force -otl $facxotl1 $facxap1 $facxdb1

sxr fcopy -in -data $(sxr which -data facxotl2.otl) -out $SXR_WORK/../data
chmod 777 $SXR_WORK/../data/facxotl2.otl
export facxap2=facxap2
export facxdb2=facxdb2
export facxotl2=facxotl2.otl

# creation of aso application facxap2 (this application is same as Essbase sample application 'asosamp-sample')
sxr newapp -force -strapp aso $facxap2
sxr newdb -force -otl $facxotl2 $facxap2 $facxdb2


#-----------------------------------------------------------------------------
# There are some issues like the value of parameter %UID is not getting passed to .mxl script, when the script is called as 
# sxr msh create_app_validate.mxl %HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD
# Until these script issues are resolved, copying the .mxl file to locally and running the tests. Once above mentioned issue is resolved, copy .mxl (sxr fcopy..) from below statements will be removed.
#-----------------------------------------------------------------------------
export SXR_ESSCMD='essmsh'
# sxr msh create_app_validate.mxl ${SXR_USER} ${SXR_PASSWORD} ${SXR_DBHOST}
sxr fcopy -in $(sxr which -msh create_app_validate.mxl) -out $SXR_WORK/../scr
#sxr fcopy -in $(sxr which -msh "*.mxl") -out $SXR_WORK/../scr
#dos2unix $SXR_WORK/../scr/*
sxr esscmd create_app_validate.mxl %HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD
export SXR_ESSCMD='ESSCMD'

diff_output create_app_result


#-----------------------------------------------------------------------------
# -- create application facxap3 as a copy of facxap2(asosamp) application --
#-----------------------------------------------------------------------------

export SXR_ESSCMD='essmsh'
sxr fcopy -in $(sxr which -msh create_copyapp.mxl) -out $SXR_WORK/../scr
sxr esscmd create_copyapp.mxl %HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD
export SXR_ESSCMD='ESSCMD'

diff_output create_copyapp

#-----------------------------------------------------------------------------
# -- test set minimum permission with facxap3 application --
# This test cases covers automation of CR # 8491891	FUSION: ALTER APPLICATION..SET MINIMUM PERMISSION.SHOULDN'T BE ALLOWED IN FUSION
#-----------------------------------------------------------------------------
export SXR_ESSCMD='essmsh'
sxr fcopy -in $(sxr which -msh alter_app_set_min_perm.mxl) -out $SXR_WORK/../scr
sxr esscmd alter_app_set_min_perm.mxl %HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD
diff_output alter_app_set_min_perm

#-----------------------------------------------------------------------------
# -- test rename of an application --
# This test cases covers automation of CR # 8372189 - FUSION: RENAME APPLICATION FROM MAXL FAILS
#-----------------------------------------------------------------------------
sxr fcopy -in $(sxr which -msh rename_app.mxl) -out $SXR_WORK/../scr
sxr esscmd rename_app.mxl %HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD
diff_output rename_app

#----------------------------------------------------------------------------------------------------------------------------------
# For this test case to validate successfully a user should be part of specified group. Please refer to .sxrrc->$FusionEnv file for details.
# This test cases covers automation of CR # 9462122	REVOKE FILTER ON A GROUP IS NOT WORKING PROPERLY
#----------------------------------------------------------------------------------------------------------------------------------
export SXR_ESSCMD='essmsh'
sxr fcopy -in $(sxr which -msh revoke_filter.mxl) -out $SXR_WORK/../scr
sxr esscmd revoke_filter.mxl %HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD
export SXR_ESSCMD='ESSCMD'

diff_output revoke_filter

#----------------------------------------------------------------------------------------------------------------------------------
# -- drop application facxap3 created as a copy of facxap2(asosamp) application and check that the app is dropped successfully - CR # 9244342 coverage
#----------------------------------------------------------------------------------------------------------------------------------
export SXR_ESSCMD='essmsh'
sxr fcopy -in $(sxr which -msh drop_copyapp.mxl) -out $SXR_WORK/../scr
sxr esscmd drop_copyapp.mxl %HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD
export SXR_ESSCMD='ESSCMD'

diff_output drop_copyapp

#-----------------------------------------------------------------------------------------------------------------------------------------------------------
# -- create static filters on facxap2 (same as asosamp) application, grant the same to filter users. Please refer to $FusionEnv file for filter user details.
#-----------------------------------------------------------------------------------------------------------------------------------------------------------
export SXR_ESSCMD='essmsh'
sxr fcopy -in $(sxr which -msh create_filter.mxl) -out $SXR_WORK/../scr
sxr esscmd create_filter.mxl %HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD
export SXR_ESSCMD='ESSCMD'

diff_output create_filter_result

#-----------------------------------------------------------------------------------------------------------------------------------------------------------
# -- Validate the filter execution with filter users. Please refer to $FusionEnv file for filter user details. --
#-----------------------------------------------------------------------------------------------------------------------------------------------------------
export SXR_ESSCMD='essmsh'
sxr fcopy -in $(sxr which -msh execute_filter.mxl) -out $SXR_WORK/../scr
sxr esscmd execute_filter.mxl %HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD
export SXR_ESSCMD='ESSCMD'

export SXR_ESSCMD='essmsh'

diff_output execute_filter_result

#-----------------------------------------------------------------------------
# -- test set minimum permission with a user having filter permissions on facxap4 application --
#-----------------------------------------------------------------------------
# creation of aso application facxap4 (this application is same as Essbase sample application 'asosamp-sample')
sxr newapp -force -strapp aso facxap4
sxr newdb -force -otl facxotl2.otl facxap4 facxdb4
export SXR_ESSCMD='essmsh'
sxr fcopy -in $(sxr which -msh fltuser_alter_app_setmin_perm.mxl) -out $SXR_WORK/../scr
sxr esscmd fltuser_alter_app_setmin_perm.mxl %HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD
diff_output fltuser_alter_app_setmin_perm

#-----------------------------------------------------------------------------
# -- Try renaming an app with a filter user --
#-----------------------------------------------------------------------------
sxr fcopy -in $(sxr which -msh fltuser_rename_app.mxl) -out $SXR_WORK/../scr
sxr esscmd fltuser_rename_app.mxl %HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD
diff_output fltuser_rename_app

#-----------------------------------------------------------------------------
# -- Try alter application reregister with an admin user --
# This test cases covers automation of CR # 8488269 - FUSION: NEED TO DEPRECATE COMMAND 'ALTER APPLICATION..REREGISTER' IN FUSION MODE
#-----------------------------------------------------------------------------
sxr fcopy -in $(sxr which -msh alter_app_reregister.mxl) -out $SXR_WORK/../scr
sxr esscmd alter_app_reregister.mxl %HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD
diff_output alter_app_reregister

#-----------------------------------------------------------------------------
# -- Rename db with an admin user --
#-----------------------------------------------------------------------------
sxr fcopy -in $(sxr which -msh rename_db.mxl) -out $SXR_WORK/../scr
sxr esscmd rename_db.mxl %HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD
diff_output rename_db

# Dec'14th - 2010
#-----------------------------------------------------------------------------
# -- Modify filter definition 'add 'read' followed by 'no_access' and validate the same with filter user --
#-----------------------------------------------------------------------------

sxr fcopy -in $(sxr which -msh modify_filter_read_noaccess.mxl) -out $SXR_WORK/../scr
sxr esscmd modify_filter_read_noaccess.mxl %HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD
diff_output modify_filter_read_noaccess

#-----------------------------------------------------------------------------
# -- Modify filter definition 'add 'no_access' followed by 'read' and validate the same with filter user --
#-----------------------------------------------------------------------------
sxr fcopy -in $(sxr which -msh modify_filter_noaccess_read.mxl) -out $SXR_WORK/../scr
sxr esscmd modify_filter_noaccess_read.mxl %HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD
diff_output modify_filter_noaccess_read

#-----------------------------------------------------------------------------
# -- alter group with admin user -- few cases should fail with approriate error. 
# Causes a dif due to CR #10322490. Baseline may need to be modified after this issue is fixed.
#-----------------------------------------------------------------------------
# sxr fcopy -in $(sxr which -msh alter_group.mxl) -out $SXR_WORK/../scr
#sxr esscmd alter_group.mxl %HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD
#diff_output alter_group

#-----------------------------------------------------------------------------
# -- alter system with admin user -- few cases should fail with approriate error. Currently it causes a dif due to CR #10322515. 
# CR #10322737 is covered which is fixed in RC10 Essbase build 269 and baseline captured accordingly. 
# This test cases covers automation of CR # 8447718 - FUSION: UNLOAD ESSBASE APPLICATION HANGS DUE TO JAVA VERSION
#-----------------------------------------------------------------------------
# creation of aso application facxap5 (this application is same as Essbase sample application 'asosamp-sample')
sxr newapp -force -strapp aso facxap5
sxr newdb -force -otl facxotl2.otl facxap5 facxdb5
sxr fcopy -in $(sxr which -msh alter_system.mxl) -out $SXR_WORK/../scr
sxr esscmd alter_system.mxl %HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD
diff_output alter_system

#-----------------------------------------------------------------------------
# -- Test enable/disable unicode mode for essbase -- 
#-----------------------------------------------------------------------------
sxr fcopy -in $(sxr which -msh enable_disable_unicode.mxl) -out $SXR_WORK/../scr
sxr esscmd enable_disable_unicode.mxl %HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD
diff_output enable_disable_unicode

#-----------------------------------------------------------------------------
# -- Test alter user commands with essbase admin user. 
# This test cases covers automation of CR 8524022	FUSION: ALTER USER..SET SSS_MODE SHOWS MESSAGE 'USER DOESN'T EXIST'
# This test cases covers automation of CR 8523955	FUSION: AGENT CRASH WITH 'ALTER USER ALL SYNC SECURITY WITH ALL APPLICATION'
#-----------------------------------------------------------------------------
sxr fcopy -in $(sxr which -msh alter_user.mxl) -out $SXR_WORK/../scr
sxr esscmd alter_user.mxl %HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD
diff_output alter_user_1
diff_output alter_user_2

#-----------------------------------------------------------------------------
# -- Create application from an existing BSO app - facxap1 (same as 'Sample'). 
#-----------------------------------------------------------------------------
sxr fcopy -in $(sxr which -msh create_copyapp_bso.mxl) -out $SXR_WORK/../scr
sxr esscmd create_copyapp_bso.mxl %HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD
diff_output create_copyapp_bso

#-----------------------------------------------------------------------------
# -- Create or replace application from an existing app - aso and BSO
# This test cases covers automation of CR # 8447718 - FUSION: UNLOAD ESSBASE APPLICATION HANGS DUE TO JAVA VERSION
#-----------------------------------------------------------------------------
sxr fcopy -in $(sxr which -msh create_replace_app.mxl) -out $SXR_WORK/../scr
sxr esscmd create_replace_app.mxl %HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD
diff_output create_replace_app

#-----------------------------------------------------------------------------
# -- Create / replace database from an existing db - BSO. 
# Note: You cannot create an aggregate storage database as a copy of another aggregate storage database
#-----------------------------------------------------------------------------
sxr fcopy -in $(sxr which -msh create_db.mxl) -out $SXR_WORK/../scr
sxr esscmd create_db.mxl %HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD
diff_output create_db
diff_output create_replace_db

#-----------------------------------------------------------------------------
# -- Create or replace filter with filter name of length - 30 chars & more than 30 chars.
#-----------------------------------------------------------------------------
sxr fcopy -in $(sxr which -msh create_filtname_30chars.mxl) -out $SXR_WORK/../scr
sxr esscmd create_filtname_30chars.mxl %HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD
diff_output create_filtname_30chars

#-----------------------------------------------------------------------------
# -- Create group commands - Not supported in Fusion mode.
# This test cases covers automation of CR # 8395617 - FUSION:'CREATE USER' SHOWS MESSAGE 'USER ALREADY EXISTS' THOUGH THE USER DOESN'T 
# This test cases covers automation of CR # 9258127	ERROR MESSAGE SHOWN WHILE CREATING A GROUP IN FUSION MODE NEEDS MODIFICATION
#-----------------------------------------------------------------------------
sxr fcopy -in $(sxr which -msh create_group.mxl) -out $SXR_WORK/../scr
sxr esscmd create_group.mxl %HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD
diff_output create_group

#-----------------------------------------------------------------------------
# -- Create user commands - Not supported in Fusion mode.
# This test cases covers automation of CR # 8395617 - FUSION:'CREATE USER' SHOWS MESSAGE 'USER ALREADY EXISTS' THOUGH THE USER DOESN'T 
# This test cases covers automation of CR # 9258127	ERROR MESSAGE SHOWN WHILE CREATING A GROUP IN FUSION MODE NEEDS MODIFICATION
#-----------------------------------------------------------------------------
sxr fcopy -in $(sxr which -msh create_user.mxl) -out $SXR_WORK/../scr
sxr esscmd create_user.mxl %HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD
diff_output create_user

#-----------------------------------------------------------------------------
# ****-- display app - with both admin and filter user. -- incomplete..Have few issues with baselines..Need to be resolved.
#-----------------------------------------------------------------------------
sxr fcopy -in $(sxr which -msh display_app.mxl) -out $SXR_WORK/../scr
sxr esscmd display_app.mxl %HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD
#diff_output display_app

#-----------------------------------------------------------------------------
# ****-- display filter - with both admin and filter user. -- There are few dif's. Need to check with DEV and raise CR.
# This test cases covers automation of CR # 11692981 - 'DISPLAY FILTER ON DATABASE' SHOULD RETURN ERROR WHEN USER DON'T HAVE ACCESS
# This test cases covers automation of CR # 11066854 - FILTER USER IS NOT ABLE TO DISPLAY ITS OWN FILTER
#-----------------------------------------------------------------------------
sxr fcopy -in $(sxr which -msh display_filter.mxl) -out $SXR_WORK/../scr
sxr esscmd display_filter.mxl %HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD
diff_output display_filter_admin
diff_output display_filter_fltusr_CR11692981

#-----------------------------------------------------------------------------
# -- display group - with both admin and filter user. -- 
#-----------------------------------------------------------------------------
sxr fcopy -in $(sxr which -msh display_group.mxl) -out $SXR_WORK/../scr
sxr esscmd display_group.mxl %HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD
diff_output display_group_admin
diff_output display_group_fltusr

#-----------------------------------------------------------------------------
# ****-- display privilege - with both admin and filter user. -- incomplete..Have few issues with baselines..Need to be resolved..hence the 'diff' part is commented.
# This test cases covers automation of CR # 8724679	FUSION: AGENT CRASH WHEN TRYING TO DROP USER , DISPLAY PRIVILEGE
# ****-- The baselines for below two CRs are perfect and working fine....
# This test cases covers automation of CR # 8802985	FUSION: DISPLAY PRIVILEGE SHOWS DETAILS INCORRECTLY AS 'FILTER WAS DROPPED'
# This test cases covers automation of CR # 8593045 - FUSION: DISPLAY PRIVILEGE IS NOT SHOWING THE PRIVILEGES OF A USER
# This test cases covers automation of CR # 8469289 - FUSION: AGENT CRASH WHEN A USER WITH FILTER ACCESS EXECUTE 'DISPLAY PRIVILIGE...
#-----------------------------------------------------------------------------
sxr fcopy -in $(sxr which -msh display_privilege.mxl) -out $SXR_WORK/../scr
sxr esscmd display_privilege.mxl %HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD
#diff_output display_privilege_admin
#diff_output display_privilege_fltusr
# diff_output display_privilege_admin_CR8593045

grep -i 'administrator' $SXR_WORK/display_privilege_admin_CR8593045.out
if [ $? -eq 0 ]
then
   echo "Showing admin privilege correctly" | tee -a display_privilege_admin_CR8593045.suc
else
   echo "Showing admin privilege incorrectly" | tee -a display_privilege_admin_CR8593045.dif
fi


grep -i 'filter was dropped' $SXR_WORK/display_privilege_fltusr_CR8802985_1.out > $SXR_WORK/display_privilege_fltusr_CR8802985.out
if test -s $SXR_WORK/display_privilege_fltusr_CR8802985.out 
then 
   mv $SXR_WORK/display_privilege_fltusr_CR8802985.out $SXR_WORK/display_privilege_fltusr_CR8802985.dif
else
   mv $SXR_WORK/display_privilege_fltusr_CR8802985.out $SXR_WORK/display_privilege_fltusr_CR8802985.suc
fi


#-----------------------------------------------------------------------------
# ****-- display user - with and admin user. Result in a dif due to a minor bug, CR need to be raised.
#-----------------------------------------------------------------------------
sxr fcopy -in $(sxr which -msh display_user.mxl) -out $SXR_WORK/../scr
sxr esscmd display_user.mxl %HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD
# diff_output display_user

#-----------------------------------------------------------------------------
# -- drop functionality - with and admin user. Result in a dif due to a minor bug??, CR need to be raised??
# This test cases covers automation of CR # 8724679	FUSION: AGENT CRASH WHEN TRYING TO DROP USER , DISPLAY PRIVILEGE
#-----------------------------------------------------------------------------
sxr fcopy -in $(sxr which -msh drop_functionality.mxl) -out $SXR_WORK/../scr
sxr esscmd drop_functionality.mxl %HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD
diff_output drop_application
diff_output drop_db
#diff_output drop_user_group
diff_output drop_filter

#-----------------------------------------------------------------------------
# -- grant functionality - with both admin & filter users. Result is a dif due to a minor bug, CR need to be raised
# This test cases covers automation of CR 11692459 - GRANT FILTER TO ESSBASE ADMIN GROUP IN FUSION MODE EXPECTED TO FAIL BUT SUCCEEDS
# This test cases covers automation of CR 8593084 - FUSION:GRANT FILTER TO AN ADMIN USER SHOWS SUCCESS THOUGH IT IS EXPECTED TO FAIL
# This test cases covers automation of CR 8499593 - FUSION:MAXL 'GRANT ADMINISTRATOR...' SHOWS SUCCESS THOUGH IT IS EXPECTED TO FAIL
#-----------------------------------------------------------------------------
sxr fcopy -in $(sxr which -msh grant_functionality.mxl) -out $SXR_WORK/../scr
sxr esscmd grant_functionality.mxl %HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD
# diff_output grant_functionality

#-----------------------------------------------------------------------------
# -- 'login as another user' functionality - tested with both admin & filter users
#-----------------------------------------------------------------------------
sxr fcopy -in $(sxr which -msh login_as.mxl) -out $SXR_WORK/../scr
sxr esscmd login_as.mxl %HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD
diff_output login_as

#-----------------------------------------------------------------------------
# -- This use case when trying to grant filter using 'grant filter..' and if a user and group with same name exists.
# -- CR 12363487 - GRANT FILTER TO A USER/GROUP IS FAILING WHEN A GROUP/USER WITH SAME NAME EXISTS
# This case can't be executed with weblogic native authentication as it doesn't allows users and groups with same name. However this case can't be executed with OID authentication where users and groups with same name are allowed
#-----------------------------------------------------------------------------
#export SXR_ESSCMD='essmsh'
sxr fcopy -in $(sxr which -msh UsrName_sameas_Grp_CR12363487.mxl) -out $SXR_WORK/../scr
#sxr esscmd UsrName_sameas_Grp_CR12363487.mxl %HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD
#diff_output UsrName_sameas_Grp_CR12363487

#-----------------------------------------------------------------------------
# -- This use case is to test agent hang issue when trying with 'listfilters' with a filter user.
# -- CR 11845590 - LISTFILTERS IS HANGING DUE TO MEMORY CORRUPTION IN RC11 ESSBASE 
# -- CR 11832675 - REQUEST FOR RC11 PATCH FOR BUG 11731019
# -- CR 11731019 - EPMAP ESSBASE HANG
#-----------------------------------------------------------------------------
export SXR_ESSCMD='essmsh'
sxr fcopy -in $(sxr which -msh listfilters_CR11845590.mxl) -out $SXR_WORK/../scr
sxr esscmd listfilters_CR11845590.mxl %HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD
diff_output listfilters_CR11845590_mxl
export SXR_ESSCMD='ESSCMDQ'
export OUT_FILE1=listfilters_CR11845590_scr.out
sxr esscmd listfilters_CR11845590.scr %HOST=$SXR_DBHOST %UID=$ffltusr1_esscmd %PWD=$ffltpwd1_esscmd %OUT_FILE=$OUT_FILE1
diff_output listfilters_CR11845590_scr

#-----------------------------------------------------------------------------
# This test cases covers automation of CR # 10388681 - AGENT CRASH WITH FUSION MATS EXECUTION AFTER PATCHING D8B4A RC10 ESSBASE B.269
# This test cases covers automation of CR # 9244342 - FUSION: DROP ESSBASE APPLICATION IS ALSO DROPPING THE FUSION APP ID CONTEXT
#-----------------------------------------------------------------------------
export SXR_ESSCMD='essmsh'
sxr fcopy -in $(sxr which -msh deleteapp_CR10388681.mxl) -out $SXR_WORK/../scr
sxr esscmd deleteapp_CR10388681.mxl %HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD
diff_output deleteapp_CR10388681

#-----------------------------------------------------------------------------
# This test cases covers automation of CR # 8373107	FUSION: ESSCMDQ->QGETTOKENFROMUSERNAME IS NOT RETURNING EXPECTED RESULTS.
# This test cases covers automation of CR # 10301287	QGETTOKENFROMUSERNAME FAILS WITH USER DOESN'T EXIST ERROR THOUGH USER EXISTS.
#-----------------------------------------------------------------------------
export SXR_ESSCMD='ESSCMDQ'
sxr esscmd qgettokenfromusrname_CR10301287.scr %HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD
sed -n 's/.*\(This request is not supported in Fusion mode\).*/\1/p' qgettokenfromusrname_CR10301287_1.out > qgettokenfromusrname_CR10301287.out
sed -n 's/.*\(Command Failed. Return Status = 1051677\).*/\1/p' qgettokenfromusrname_CR10301287_1.out >> qgettokenfromusrname_CR10301287.out
sxr fcopy -in $(sxr which -log qgettokenfromusrname_CR10301287.bas) -out $SXR_WORK/../log
dos2unix $SXR_WORK/../log/qgettokenfromusrname_CR10301287.bas
sxr diff qgettokenfromusrname_CR10301287.out qgettokenfromusrname_CR10301287.bas

#-----------------------------------------------------------------------------
# This test cases covers automation of CR # 12370617	QGETTOKENFROMUSERNAME SHOWS SEGMENTATION FAULT WHEN TRIED BEFORE USER LOGIN.
# The following code has few issues. Need to be fixed and then include in execution.
#-----------------------------------------------------------------------------
# export SXR_ESSCMD='ESSCMDQ'
# sxr esscmd qgettokenfromusrname_CR12370617.scr %HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD
# sed -n 's/.*\(Please Login first before using this command\).*/\1/p' qgettokenfromusrname_CR12370617_1.out > qgettokenfromusrname_CR12370617.out
# sxr diff qgettokenfromusrname_CR12370617.out qgettokenfromusrname_CR12370617.bas

#-----------------------------------------------------------------------------
# This test cases covers automation of CR # 9462563	FILTER DEFINITION ACCEPTS ANY CHARACTERS AFTER 'CHI...' SHOULD CHECK CHILDREN.
#-----------------------------------------------------------------------------
export SXR_ESSCMD='essmsh'
sxr fcopy -in $(sxr which -msh createfilter_Chi_CR9462563.mxl) -out $SXR_WORK/../scr
sxr esscmd createfilter_Chi_CR9462563.mxl %HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD
# diff_output createfilter_Chi_CR9462563

#-----------------------------------------------------------------------------
# This test cases covers automation of CR # 9462029	GRANT NO_ACCESS SHOWS MESSAGE AS NOT SUPPORTED BUT DROPS THE FILTER ON USER.
#-----------------------------------------------------------------------------
export SXR_ESSCMD='essmsh'
sxr fcopy -in $(sxr which -msh grant_noaccess_CR9462029.mxl) -out $SXR_WORK/../scr
sxr esscmd grant_noaccess_CR9462029.mxl %HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD
diff_output grant_noaccess_CR9462029

#-----------------------------------------------------------------------------
# This test cases covers automation of CR # 8515255 - FUSION: MAXL TIMES OUT WHEN TRYING TO DISPLAY USERS IN GROUP ALL_USERS_GROUPS
# This test cases covers automation of CR # 9068682 - FUSION: MAXL TIMES OUT WHEN TRYING TO DISPLAY USERS IN GROUP ALL_USERS_GROUPS (duplicate of CR # 8515255)
#-----------------------------------------------------------------------------
export SXR_ESSCMD='essmsh'
sxr fcopy -in $(sxr which -msh display_user_CR8515255.mxl) -out $SXR_WORK/../scr
sxr fcopy -in $(sxr which -log display_user_CR8515255.bas) -out $SXR_WORK/../log
dos2unix $SXR_WORK/../log/display_user_CR8515255.bas
sxr esscmd display_user_CR8515255.mxl %HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD
sxr diff display_user_CR8515255.out display_user_CR8515255.bas

#-----------------------------------------------------------------------------
# This test cases covers automation of CR # 8715567 - FUSION: DATALOAD FROM MAXL CRASHES AGENT PROCESS
#-----------------------------------------------------------------------------
export SXR_ESSCMD='essmsh'
sxr fcopy -in $(sxr which -msh dataload_CR8715567.mxl) -out $SXR_WORK/../scr
sxr fcopy -in $(sxr which -log dataload_CR8715567.bas) -out $SXR_WORK/../log
dos2unix $SXR_WORK/../log/dataload_CR8715567.bas
sxr esscmd dataload_CR8715567.mxl %FNAME1=$(sxr which -data facxdata2.txt) %FNAME2=$(sxr which -data facxrul2.rul) %HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD
sxr diff dataload_CR8715567.out dataload_CR8715567.bas


#-----------------------------------------------------------------------------------------------------------------------------------------------------------
# FND Security - Creation of POC application. For FND security testing, unicode mode should be enabled for Essbase which is covered in the script execution..
#-----------------------------------------------------------------------------------------------------------------------------------------------------------

# Enable unicode mode for essbase
export SXR_ESSCMD='essmsh'
sxr fcopy -in $(sxr which -msh set_esb_unicode.mxl) -out $SXR_WORK/../scr
sxr esscmd set_esb_unicode.mxl %HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD
export SXR_ESSCMD='ESSCMD'

# Creation of FND security POC application
sxr fcopy -in -data $(sxr which -data fnddb1.otl) -out $SXR_WORK/../data
chmod 777 $SXR_WORK/../data/fnddb1.otl
export fndap1=fndap1
export fnddb1=fnddb1
export fndotl1=fnddb1.otl
sxr newapp -force -utf8 -strapp aso $fndap1
sxr newdb -force -otl $fndotl1 $fndap1 $fnddb1

fltdef="'@EvalSQLFilterProc(\"<CONNECTION> <HOST>$fnd_ora_host</HOST> <PORT>$fnd_ora_port</PORT> <SID>$fnd_ora_sid</SID>  <UID>$fnd_ora_user</UID> <PWD>$fnd_ora_pwd</PWD> <ENCRYPTION>none</ENCRYPTION> </CONNECTION>\",\"$fnd_ora_sp\",\"<DATASECURITY> <CUBE>$fndap1</CUBE> <DIMENSION>  <DIMENSIONNAME>LEDGER</DIMENSIONNAME> <DAS>LEDGERS</DAS> </DIMENSION> <DIMENSION> <DIMENSIONNAME>COMPANY</DIMENSIONNAME> <DAS>BALANCINGSEGMENTS</DAS> </DIMENSION> <DIMENSION>  <DIMENSIONNAME>DEPARTMENT</DIMENSIONNAME> <DAS>MANAGEMENTSEGMENTS</DAS> </DIMENSION> </DATASECURITY>\")'"
export fltdef

export SXR_ESSCMD='essmsh'
sxr fcopy -in $(sxr which -msh create_fnd_filter.mxl) -out $SXR_WORK/../scr
sxr esscmd create_fnd_filter.mxl %HOST=$SXR_DBHOST %UID=$SXR_USER %PWD=$SXR_PASSWORD
export SXR_ESSCMD='ESSCMD'

sxr fcopy -in $(sxr which -log create_fnd_filter.bas) -out $SXR_WORK/../log
dos2unix $SXR_WORK/../log/create_fnd_filter.bas
sxr diff -ignore $fnd_ora_host -ignore $fnd_ora_port -ignore $fnd_ora_sid -ignore $fnd_ora_user -ignore $fnd_ora_pwd -ignore $fnd_ora_sp -ignore $ffndusr1 -ignore $ffndusr2 -ignore $ffndusr3 -ignore $fndflt1_read -ignore $fndflt1_write -ignore $fndflt1_noaccess -ignore ".*SSL initialization .*" create_fnd_filter.out create_fnd_filter.bas

export SXR_ESSCMD='essmsh'
sxr fcopy -in $(sxr which -msh execute_fnd_filter.mxl) -out $SXR_WORK/../scr
sxr esscmd execute_fnd_filter.mxl %HOST=$SXR_DBHOST %UID=$ffndusr1 %PWD=$ffndpwd1
export SXR_ESSCMD='ESSCMD'


sxr fcopy -in $(sxr which -log execute_fnd_filter.bas) -out $SXR_WORK/../log
dos2unix $SXR_WORK/../log/execute_fnd_filter.bas
sxr diff -ignore $ffndusr1 -ignore $ffndpwd1 -ignore $ffndusr2 -ignore ffndpwd2 -ignore $ffndusr3 -ignore ffndpwd3 -ignore $SXR_DBHOST -ignore ".*SSL initialization .*" execute_fnd_filter.out execute_fnd_filter.bas

#-----------------------------------------------------------------------------------------------------------------------------------------------------------
# -- Optional test cases -- The following script (set of cases) may need to be commented out based on target environment 
#-----------------------------------------------------------------------------------------------------------------------------------------------------------
sxr sh agsf_jps_sec11.sh

#-----------------------------------------------------------------------------------------------------------------------------------------------------------
# Execution of FND security acceptance
#-----------------------------------------------------------------------------------------------------------------------------------------------------------
sxr sh agsf_fnd_sec.sh

#-----------------------------------------------------------------------------------------------------------------------------------------------------------
# Execution of japi acceptance
#-----------------------------------------------------------------------------------------------------------------------------------------------------------
# sxr sh agsf_apjvaccmain.sh
# suppress the dif - apjvdqe2.dif after checking it's content is expected
# cp -f apjvdqe2.dif apjvdqe2_temp.out
# sxr diff apjvdqe2_temp.out apjvdqe2_fusion.bas

# if [ $? -eq 0 ]
# then
#    mv apjvdqe2.dif apjvdqe2.suc
#    rm -f apjvdqe2_temp.suc
# fi

# mv apjvdqe2.dif apjvdqe2.suc
# mv apjvdse2.dif apjvdse2.dif_toberesolved
# mv apjvmde2.dif apjvmde2.dif_toberesolved

# Remove the apps that are created by above test cases
sxr esscmd msxxrmap.scr %HOST=$SXR_DBHOST %USER=$SXR_USER %APP=listflts %PASSWD=$SXR_PASSWORD
sxr esscmd msxxrmap.scr %HOST=$SXR_DBHOST %USER=$SXR_USER %APP=Facxap4 %PASSWD=$SXR_PASSWORD

#-----------------------------------------------------------------------------------------------------------------------------------------------------------
# -- create and validate GL apps creation. These application are picked from location - \\nar200\essbasesxr\Fusion-Data\GL_Apps
#-----------------------------------------------------------------------------------------------------------------------------------------------------------
sxr sh agsf_create_GLapps.sh

#-----------------------------------------------------------------------------------------------------------------------------------------------------------
# Execution of GL_Allocations acceptance
#-----------------------------------------------------------------------------------------------------------------------------------------------------------
sxr sh agsf_glalloc_accx.sh

#-----------------------------------------------------------------------------------------------------------------------------------------------------------
# This test cases covers automation of CRs: 12556536, 12622762
#-----------------------------------------------------------------------------------------------------------------------------------------------------------
# sxr sh restruct_conc_CRs12556536_12622762.sh
