#-------------------------------------------------------------------------
# File:          agsbmain.sh
# Auther:        Jock Chau
# Date Created:  8/21/2012
# History:
#		 11/16/2012  added agsb_cleanup.sh to cleanup apps after
#		             test is done
#                12/17/2012  added agsb_deleteAllApps.sh to delete all
#                            applications left over from other tests
#
# Purpose:       main script for bi security test automation
# Runnable:      True (sxr sh agsbmain.sh)
# Test time:     < 30 minutes
# Memory/Disk space requirement:
# Number of suc file(s): 110
#-------------------------------------------------------------------------
sxr sh agsb_deleteAllApps.sh
sxr sh agsb_managePassword.sh
sxr sh agsb_appman.sh
sxr sh agsb_dbman.sh
sxr sh agsb_manageCalc.sh
sxr sh agsb_manageFilter.sh
sxr sh agsb_read.sh
sxr sh agsb_restart.sh
sxr sh agsb_write.sh
sxr sh agsb_creator.sh
sxr sh agsb_grouptest1.sh
sxr sh agsb_grouptest2.sh
sxr sh agsb_grouptest3.sh
sxr sh agsb_grouptest4.sh
sxr sh agsb_grouptest5.sh
sxr sh agsb_grouptest6.sh
sxr sh agsb_grouptest7.sh
sxr sh agsb_cleanup.sh
