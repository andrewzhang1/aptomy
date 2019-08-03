# This test load data with multi-threads:
# on the command line: # This test load data with multi-threads:
# on the command line: ./tpld.sh Number_threads (./tpld.sh 8)

rm $ARBORPATH/app/13073332/HRM/*.txt

# Move exported files back to the server
mv $ARBORPATH/app/*txt $ARBORPATH/app/13073332/HRM

echo "login \"localhost\" \"admin\" \"password\";" >tptestLD.scr
echo "unloadapp \"13073332\";" >> tptestLD.scr
echo "loadapp \"13073332\";" >> tptestLD.scr
echo "select \"13073332\" \"HRM\";" >> tptestLD.scr
#echo "PAREXPORT -threads $1 ps3exp$1thread.txt 1 1;" >> tptestLD.scr

echo "ResetDB;" >> tptestLD.scr
echo "PARLOADDATA -threads $1 2 \"ps3exp$1thread*.txt\";" >> tptestLD.scr

chmod 777 *scr

ESSCMD tptestLD.scr

sleep 1

mv $ARBORPATH/app/13073332/HRM/*.txt $ARBORPATH/app/13073332/HRM/data_folder
 


