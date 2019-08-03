DIR=$1
cd $DIR
CWB="`pwd`"


echo "DIR ARBORPATH${CWB#$ARBORPATH}"

lssort | while read line; do
	if [ -d $line ]; then
		esbcompimg.sh $line
	else
		echo "REG ARBORPATH${CWB#$ARBORPATH}/$line"
	fi
done
		
