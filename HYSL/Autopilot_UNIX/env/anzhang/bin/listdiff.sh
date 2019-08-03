cd $SXR_WORK
ls *.dif > list.txt
for file in `cat list.txt`
do
echo $file >> all_diff.out
cat $file >> all_diff.out
print '*********************************' >>all_diff.out
done
mv all_diff.out ../.
cat ../all_diff.out
