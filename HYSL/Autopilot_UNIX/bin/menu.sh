#! /usr/bin/ksh

echo "**************************"
echo "Architecture Setup Menu"
echo "**************************"


PS3='Choose your architecture? '
select arch in "64 bit" "32 bit"; do
	if [ -n "$arch" ]; then
		_mode=`echo $arch | awk '{print $1}'`
		if [ "$_mode" = "32" -o "$_mode" = "64" ]; then
			echo "Setting ARCH to $_mode"
			export ARCH=$_mode
			break			
		fi
	fi
done


