if [ $# != 2 ]
then
	echo "chk_licmode.sh <ver> <bld>"
	echo "  lic:license file"
	echo "  reg:registry.properties files"
	echo "  none:after oracle"
	exit 1
fi

case $1 in
	9.2.1.0.0)
		_licmode="reg"
		;;
	7.1.6.6)
		_licmode="none"
		;;
	5*|6*|7*| \
	london|joyce|joyce_dobuild|tide| \
	zephyr|tsunami|woodstock|9.0*|9.2*)
		_licmode="lic"
		;;
	9.3.1.0.0)
		if [ $2 -lt 118 ]; then
			_licmode="lic"
		elif [ $2 -lt 182 ]; then
			_licmode="reg"
		else
			_licmode="none"
		fi
		;;
	kennedy|9.5.0.0.0)
		if [ $2 -lt 200 ]; then
			_licmode="reg"
		else
			_licmode="none"
		fi
		;;
	*)	# default
		_licmode="none"
		;;
esac

echo $_licmode

