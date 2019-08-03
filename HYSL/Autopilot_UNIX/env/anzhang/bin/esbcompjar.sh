DIR=$1
cd $DIR

lssort | while read line; do
	if [ -d $line ]; then
		esbcompjar.sh $line
	fi
done

ls *.jar | while read jarfile; do
	mkdir ${jarfile}_cont
	cp $jarfile ${jarfile}_cont
	cd ${jarfile}_cont
	jar -xvf $jarfile 
	rm -rf $jarfile
	cd ..
done


		
