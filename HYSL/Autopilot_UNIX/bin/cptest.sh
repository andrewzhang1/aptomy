# Copy test from SXR framework.

if [ -n "$AP_SNAPROOT" ]; then
	echo "Use \$AP_SNAPROOT($AP_SNAPROOT)"
	snaproot=$AP_SNAPROOT
else
	snaproot=$AUTOPILOT/../..
fi
echo "cp $snaproot/talleyrand/vobs/essexer/base/data/xmsua2.txt \$HOME"
echo "-r--r--r--   1 regress    sxrdev     280028010 Jul  9  2009 xmsua2.txt"
time cp $snaproot/talleyrand/vobs/essexer/base/data/xmsua2.txt $HOME

