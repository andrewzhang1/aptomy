#!/usr/bin/ksh

svhost="nar200"
mntlist="$mntlist AUTOPILOT:/vol/vol3/essbasesxr:/regressions/Autopilot_UNIX"
mntlist="$mntlist BUILD_ROOT:/vol/vol2/pre_rel:/essbase/builds"
mntlist="$mntlist HIT_ROOT:/vol/vol3/hit:/"

unset hit pre_rel essbasesxr
case `uname` in
	Windows_NT)	;;
	AIX)	cmd="mount | grep \"^${svhost}\" | grep \$vnm"
		nth=3
		;;

	SunOS)	cmd="/sbin/mount | grep \"${svhost}:\" | grep \$vnm"
		nth=1
		;;
	
	HP-UX)	cmd="/usr/sbin/mount | grep $svhost: | grep \$vnm"
		nth=1
		;;
	Linux)	cmd="mount | grep $svhost: | grep \$vnm"
		nth=3
		;;
	*)
		echo "Not implement yet."
		exit 1
		;;
esac

if [ "`uname`" != "Windows_NT" ]; then
	for i in $mntlist; do
		mt=${i#*:}
		mt=${mt%%:*}
		vnm=${mt##*/}
		var=${i%%:*}
		lc=${i##*:}
		[ "$lc" = "/" ] && lc=
		val="`eval echo \\$$var`"
		if [ -z "$val" ]; then
			echo "$var not defined."
		elif [ ! -d "$val" ]; then
			echo "Find $var def but cannot access $val."
			val=
		else
			echo "$var=$val OK."
		fi
		if [ -z "$val" ]; then
			str="$cmd | tail -1 | awk '{print \$$nth}'"
			dtmp=`eval $cmd`
			[ $? -eq 0 ] && eval $vnm="`eval $str`" || eval $vnm=
			if [ -n "`eval echo \\$$vnm`" ]; then
				echo "  Find `eval echo \\$$vnm` is mounted."
				echo "  Define $var to `eval echo \\$$vnm`$lc."
				eval export $var="`eval echo \$$vnm`$lc"
			else
				ws="`which sudo 2> /dev/null`"
				if [ -z "$ws" -o "${ws#no}" != "$ws" ]; then	# No sudo
					echo "  Please mount ${svhost}:$mt to some location."
					echo "  And define $var=<loc>$lc"
				else
					if [ -d "/net" ]; then
						mp="/net/$svhost$mt"
					elif [ -d "/mnt" ]; then
						mp="/mnt/$svhost$mt"
					else
						mp="/net/$svhost$mt"
					fi
					echo "  Found sudo."
					echo "  Please mount ${svhost}:$mt to some location."
					echo "  And define $var=$mt/$lc"
					echo "mkddir.sh $mp"
					echo "$mntcmd $svhost:$mt $mp"
				fi
			fi
		fi
	done
else
	ftmp=~/cktmp
	rm -rf "$ftmp" 2> /dev/null
	net use | grep ":" > "$ftmp"
	cmd="cat \"$ftmp\" 2> /dev/null | grep \"$svhost\" | grep \"$vnm \""
	for i in $mntlist; do
		mt=${i#*:}
		mt=${mt%%:*}
		vnm=${mt##*/}
		var=${i%%:*}
		lc=${i##*:}
		[ "$lc" = "/" ] && lc=
		dtmp=`eval $cmd`
		if [ $? -eq 0 ]; then
			ecal $vnm=`eval $cmd | tail -1 | awk '{print $2}'`
		fi
		# dtmp=`grep "$svhost" "$ftmp" | grep "$vnm "`
		# [ -n "$dtmp" ] && eval $vnm="`echo $dtmp | awk '{print $2}'`${lc}"
	done
	rm -rf "$ftmp" 2> /dev/null
fi

for i in hit pre_rel essbasesxr; do
	val=`eval "echo \\${$i}"`
	echo "$i=$val"
done

