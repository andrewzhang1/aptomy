# Tuan¡¯s running infinitive loop: dctp02_aso_loop.sh 
keeplooping=1;

while [ $keeplooping -eq 1 ] ; do
    if [ -a $VIEW_PATH/$SXR_INVIEW/work/*.dif ] ; then
       echo "There are difs in work folder..."
       keeplooping=0
    else
        sxr sh dctp02_aso.sh
    fi
done

