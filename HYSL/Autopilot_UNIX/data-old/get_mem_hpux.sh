
rm top_interval.result
rm *out*
i=0
while :
do
   i=`expr ${i} + 1`
   echo "Now it is $i th time."
   date

# Clean up

   top -s30 -f top_interval.out${i}
grep avg    top_interval.out${i} >> top_interval.result
grep ESSBASE top_interval.out${i} >> top_interval.result
grep Memory top_interval.out${i} >> top_interval.result
grep ESSSVR top_interval.out${i} >> top_interval.result

rm top_interval.out${i}

done



