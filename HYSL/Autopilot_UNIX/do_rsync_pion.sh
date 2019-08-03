#!/usr/bin/ksh

umask 000
# snap=/scratch/snapshot
snap=/scratch/vraid01/snapshot	# new location
logf="$snap/update_`date +%Y%m%d_%H%M%S`.log"
# src=/mnt/essbasesxr
src=/net/nar200/vol/vol3/essbasesxr # Auto mount location
# for one in qacleanup
for one in mainline 11122200	# New from 2013
do
	if [ ! -d "$src/$one" ]; then
		echo "$src/$one not found. Please make sure that nar200:/vol/vol3/essbasesxr is mounted to $src." | tee -a $logf
		echo "### SKIP $one at `date +%D_%T`" >> $logf
	else
		[ ! -d "$snap/$one" ] && sudo mkdir $snap/$one
		echo "### START RSYNC $one at `date +%D_%T`" >>  $logf
		rsync -av /mnt/essbasesxr/$one/vobs $snap/$one 2>&1 | tee -a $logf
		echo "### DONE RSYNC $one at `date +%D_%T`" >>  $logf
	fi
done

# Run this on crontab on PION by:
# /scratch/vraid01/zhang
# (zhang@pion.us.oracle.com)>crontab -l
# 0 1 * * 1-5 /scratch/vraid01/share/do_rsync.sh

