#!/usr/bin/ksh

# sts format
#	diff	BUG#[,baseline]	bld
#	diff	[new]
#

suc=`ls *.suc | wc -l`
dif=`ls *.suc | wc -l`
ttl=`expr $suc + $dif`

stsfile=${plat}_${ver}_${bld}_${test_abv}.sts

cat ${plat}_${ver}_*_${test_abv}.sts > $tmp.sts
ls *dif | while read diffile
do
	prev=`grep $diffile $tmp.sts | last -1`
done