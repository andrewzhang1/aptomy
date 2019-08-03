set -x


if [ -z $1 ]
then
    echo provide filenames
    read $FILENAMES
else
    FILENAMES="$@"
fi

echo the following filenames have been provided: $FILENAMES
for i in $FILENAMES
do
    #cp $i $HOME
    touch $i
 
done

