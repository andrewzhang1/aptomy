# 2014.03 Test to export data by multi-threads
#  on the command line: "tp_export_multiTh.sh NumberOfThreads"

rm $ARBORPATH/app/*.txt

echo "login \"localhost\" \"admin\" \"password\";" >tptest.scr
echo "unloadapp \"13073332\";" >> tptest.scr
echo "loadapp \"13073332\";" >> tptest.scr
echo "select \"13073332\" \"HRM\";" >> tptest.scr
echo "PAREXPORT -threads $1 ps3exp$1thread.txt 1 1;" >> tptest.scr
chmod 777 *scr

ESSCMD tptest.scr

