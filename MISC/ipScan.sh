#!/usr/bin/env bash

BASE_IP=172.16.36

#IP=130


# ping $BASE_IP.

ping 172.16.36.157

exit

for IP in {150..160}
do
        echo  "$BASE_IP.$IP"
        ping "$BASE_IP.$IP"
        sleep 2
        wait

        if [ $? -eq 0 ]; then
        echo "This is the live IP: "$BASE_IP.$IP" for vmlxu2"
        exit
        fi
done
exit 0

#if [ $? -eq 0 ];then
#elif
#fi
