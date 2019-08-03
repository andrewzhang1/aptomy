#!/usr/bin/ksh

p=${SXR_WORK%$(basename $SXR_WORK)}
if [ -n "$SXR_INVIEW" ]; then
	for one in SerialDirect parallelbuffer paralleldirect serialbuffer
	do
		suc=`ls $one/*.suc 2> /dev/null | wc -l`
		dif=`ls $one/*.dif 2> /dev/null | wc -l`
		echo "### $one : Suc $suc, Dif $dif"
		export SXR_WORK=${p}${one}
		send_result.sh
	done
else
	echo "You are not in sxr view."
	echo "Please do 'sxr goview XXX' and run this script."
fi

