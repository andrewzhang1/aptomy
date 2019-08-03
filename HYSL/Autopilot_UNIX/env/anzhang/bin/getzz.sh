
$HOME/bin/ckresults >zz
cat $SXR_WORK/*.sta >>zz
#$HOME/bin/listdiff.sh >>zz
cat zz|mail azhang@hyperion.com
