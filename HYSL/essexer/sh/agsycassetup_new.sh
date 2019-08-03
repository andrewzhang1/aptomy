# setup application for testing
# 09/18/2012 Andrew Zhang
#    added starting essbase
# 3/17/3013 bao nguyen
#    added to rebuild all app

sxr agtctl start

. `sxr which -sh esscmd.func`


SXR_USER=admin

#sxr esscmd -q msxxcapp.scr %HOST=${SXR_DBHOST} %USER=${SXR_USER} \
#	%PASSWD=${SXR_PASSWORD} %APP=DMDemo
sxr newapp -force Demo
sxr newdb -otl agsycasD.otl Demo Basic
sxr fcopy -in -data "agsycasD.txt" -out ${SXR_WORK}
mv ${SXR_WORK}/agsycasD.txt ${SXR_VIEWHOME}/data/Data.txt
sxr fcopy -in -data "Data.txt" -out !Demo!Basic!
sxr msh agsycassetup.msh ${SXR_USER} ${SXR_PASSWORD} ${SXR_DBHOST}
sxr newapp -force Samppart
sxr newdb -otl Basic.otl Samppart Company
sxr newapp -force Sampeast
sxr newdb -otl Basic.otl Sampeast East
sxr msh msxxcreasoapp.msh ${SXR_USER} ${SXR_PASSWORD} ${SXR_DBHOST} ASOsamp
cp `sxr which -data agsycasA.otl` ${SXR_VIEWHOME}/data
chmod 777 ${SXR_VIEWHOME}/data/agsycasA.otl
if [ $? -ne 0 ]
then
    echo "Fail to copy file" > $(basename $0 .sh).dif
    exit 1;
fi
sxr newdb -otl agsycasA.otl ASOsamp Sample
sxr fcopy -in -data "agsycasA.txt" -out ${SXR_WORK}
sxr fcopy -in -data "agsycasA.rul" -out ${SXR_WORK}
mv ${SXR_WORK}/agsycasA.txt ${SXR_VIEWHOME}/data/dataload.txt
mv ${SXR_WORK}/agsycasA.rul ${SXR_VIEWHOME}/data/dataload.rul
sxr fcopy -in -data "dataload.txt" -out !ASOsamp!Sample!
sxr fcopy -in -data "dataload.rul" -out !ASOsamp!Sample!
sxr msh msxxcreapp.msh "dso" ${SXR_USER} ${SXR_PASSWORD} ${SXR_DBHOST} "DMDemo"

sxr newapp -force Sample
sxr newdb -otl Basic.otl Sample Basic
sxr newdb -otl Interntl.otl Sample Interntl
sxr newdb -otl Xchgrate.otl Sample Xchgrate
sxr fcopy -in -data "Calcdat.txt" -out !Sample!Basic!

delete_app Microacc
for app in Sample Demo Sample_U ASOsamp Samppart Sampeast DMDemo
do
unload_app ${app}
done
