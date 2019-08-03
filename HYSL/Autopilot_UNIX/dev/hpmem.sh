#!/usr/bin/ksh

export UNIX95=yes

tmpf=$HOME/hpmem.tmp

while [ 1 ]; do
agpid=`ps -u ${LOGNAME} -o pid,comm | egrep -i ESSBASE | awk '{print $1}'`
agsiz=`ps -p $agpid -o vsz | tail -1`
rm -rf $tmpf
svsiz=0
apps=
ps -u ${LOGNAME} -o pid,comm | grep -i ESSSVR > $tmpf
while read pid rest; do
	siz=`ps -p $pid -o vsz,args | tail -1`
	app=`echo $siz | awk '{print $3}'`
	siz=`echo $siz | awk '{print $1}'`
	[ -z "$apps" ] && apps=$app || apps="$apps $app"
	let svsiz=svsiz+siz
done < $tmpf
let ttl=agsiz+svsiz
echo "`date +%D_%T`	$agsiz	$svsiz	$ttl"
sleep 15
	


done


