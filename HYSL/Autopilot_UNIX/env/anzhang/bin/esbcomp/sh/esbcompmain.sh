# Filename: esbcompmain.sh
# Author: Rumitkar Kumar
# Description: Main script that checks essbase file structure

if [ $# != 2 ]; then 
	echo "Usage: sxr sh esbcompmain.sh [version] [server|client|all]"
	exit
elif [ $1 != "7.1.5.0" ] && [ $1 != "london" ]; then
	echo "Version image is currently Unavailable"
	exit
elif [ $2 != server ] && [ $2 != client ] && [ $2 != all ]; then
	echo "Unrecognized Selection"	
	exit
else
	export BASE=$1
	export SELECT=$2
fi

#export ARBORPATH=/vol1/rukumar/london

# Expand all jar files in Installation
esbcompjar.sh $ARBORPATH
esbcompjar.sh $ARBORPATH


# Create image of File Structure
esbcompimg.sh $ARBORPATH > $SXR_WORK/cur_image.img


# Compare files that are in Current Image and not in Base Image
#esbcompdiff.sh $SXR_WORK/cur_image.img $SXR_VIEWHOME/log/${BASE}_${SELECT}.bas > $SXR_WORK/addition.dif

# Compare files that are in Base Image and not in Current Image
esbcompdiff.sh $SXR_VIEWHOME/log/${BASE}_${SELECT}.bas $SXR_WORK/cur_image.img > $SXR_WORK/missing.dif



