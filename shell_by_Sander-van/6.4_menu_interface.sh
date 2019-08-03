
echo 'select a directory'

select DIR in /bin /usr /etc
do
    # Only continues if the user has selected something
    if [ -n $DIR ]
    then
        DIR=$DIR
        echo you have select $DIR
        export DIR
        echo $DIR
        break #without the break, will be look forever.
    else
        echo invalid chioce
    fi
done 
