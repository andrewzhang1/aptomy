i=1
while (test $i -le 15)
do
  touch loop$i
        echo loop$i
        sleep 1
   mkdir DifDir$i
  let i=i+1
done

