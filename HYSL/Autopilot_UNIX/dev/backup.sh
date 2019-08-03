#!/bin/ksh
# Results back up program from autopilot central place
# File:	backup.sh
# Auther:	Yukio Kono
#
# History:
# 2010/09/02	YKono	First edition
# 2011/05/12	YKono	Change the Autopilot center repository location
#

# Register scheduled task execution.
# Use crontab command to reg/edit/list
# crontab -e > Edit scheduled task for this user
# crontab -l > List the scheduled tasks
# crontab -r > Discard all scheduled tasks for this user

backup_loc=/mnt/TachyonRaid/results_archive
# 2011/05/12 YK Move autopilot framework to the Utah and change the mount location.
# OLD: autopilot_loc=/net/nar200/vol/vol3/essbasesxr/regressions/Autopilot_UNIX
autopilot_loc=/mnt1/essbasesxr/regressions/Autopilot_UNIX

crrlst=$backup_loc/crr.txt
reslst=$backup_loc/res.txt
log=$backup_loc/`date +%Y%m%d_%H%M%S`.log

[ -f "$crrlst" ] && rm -rf "$crrlst"
[ -f "$reslst" ] && rm -rf "$reslst"
[ -f "$log" ] && rm -rf "$log"
cd $backup_loc
if [ -d "BACKUP" ]; then
	cd BACKUP
else
	mkdir BACKUP
	chmod 777 BACKUP
	cd BACKUP
fi
ls > $crrlst

cd $autopilot_loc
cd res
ls > $reslst

cd $backup_loc
diff $crrlst $reslst > back.dif

mode=none
while read line; do
	case $line in
		[0-9]*a*)
			mode=add
			;;
		[0-9]c*)
			mode=change
			;;
		[0-9]d*)
			mode=delete
			;;
		\>*) 
			if [ "$mode" = "add" ]; then
				echo "`date +%D_%T`:Backup ${line#* }" >> $log
				cp $autopilot_loc/res/${line#* } BACKUP
				sts=$?
				if [ $sts -ne 0 ]; then
					echo "`date +%D_%T`:Failed to backup ${line#* }($sts)." >> $log
				fi
				chmod 777 BACKUP/${line#* }
			fi
			;;
		*)	;;
	esac
done < back.dif

