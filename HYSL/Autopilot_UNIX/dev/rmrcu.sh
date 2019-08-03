#!/usr/bin/ksh

target=
while [ $# -ne 0 ]; do
	case $1 in
		*)
			target=$1
			;;
	esac
	shift
done
if [ -z "$target" ]; then
	echo "Please define deletion target."
	exit 1
fi

rcu="C:/rcu7/bin/rcu.bat"

bihost="slc03jnm"
biport="1521"
bisid="bi1"
biusr="SYS"
bipwd="password"
birole="SYSDBA"

# echo "Execute $rcu -silent -dropRepository "
# echo " -connectString \"$bihost:$biport:$bisid\""
# echo " -dbRole $birole"
# echo " -dbUser $biusr"
# echo " -schemaPrefix $target"
# echo " -component BIPLATFORM"
# echo " -cimponent MDS"
# echo "with $bipwd"
echo $bipwd | $rcu -silent -dropRepository \
	-connectString "$bihost:$biport:$bisid" \
	-dbRole $birole \
	-dbUser $biusr \
	-schemaPrefix $target \
	-component BIPLATFORM \
	-component MDS
echo "# $sts=$?"



