# Retrieve application log files
# 06/10/2011	YKono	First edition

cd $VIEW_PATH
cd autoregress
cd work

scr=get_applogs.tmp.scr
applst=get_applogs.tmp.lst

rm -f $scr > /dev/null 2>&1
rm -f $applst > /dev/null 2>&1
rm -rf applogs > /dev/null 2>&1
mkdir applogs

echo "# Retrieve application log files"
echo "SXR_DBHOST  :$SXR_DBHOST"
echo "SXR_USER    :$SXR_USER"
echo "SXR_PASSWORD:$SXR_PASSWORD"

echo "Login \"$SXR_DBHOST\" \"$SXR_USER\" \"$SXR_PASSWORD\";" > $scr
echo "Output 1 \"$applst\";" >> $scr
echo "listapp;" >> $scr
echo "Output 3;" >> $scr
echo "exit;" >> $scr

ESSCMDQ $scr

stline=`grep -n "Applications available:" $applst`
edline=`grep -n "Output:" $applst`
let stline=${stline%%:*}
let edline=${edline%%:*}
let lines=edline-stline-2
let edline=edline-2

rm -f $scr > /dev/null 2>&1
echo "Login \"$SXR_DBHOST\" \"$SXR_USER\" \"$SXR_PASSWORD\";" > $scr
head -$edline $applst | tail -$lines | while read app; do
	echo "getLog \"$app\" \"applogs/$app.log\";" >> $scr
done
echo "exit;" >> $scr

ESSCMDQ $scr

rm -f $scr > /dev/null 2>&1
rm -f $applst > /dev/null 2>&1
