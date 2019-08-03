#!/bin/bash

car=("Ford", "Jaguar", "Geely", "BMW")
len=${#car[*]}  # get total elements in an array

# print it
for (( i=0; i<${len}; i++));
do
    echo "${car[$i]}"
done

exit



num=5
for i in $(seq "$num")
do
    echo $i
done

exit

