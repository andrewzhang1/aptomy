# !/usr/bin/ksh
# linux_ver.sh : Check the linux versions
# Description: Display linux versions.
# Note: This script should run on linux box.
# History: ############
# 2011/10/12	YKono	First edition

if [ "`uname`" != "Linux" ]; then
	echo "linux_ver.sh should run on Linux box."
	exit 1
fi
long=false
while [ $# -ne 0 ]; do
	case $1 in
		-l)	long=true;;
		*)	echo "patameter error"
			echo "linux_ver.sh [-l]"
			exit 1;;
	esac
	shift
done

ck_linux()
{
	knd="unknown"
	ver="0.0"
	if [ -f "/etc/enterprise-release" ]; then	# OEL
		knd=`cat /etc/enterprise-release 2> /dev/null | grep "Enterprise Linux"`
		knd=${knd% *}
		ver=${knd##* }
		knd=OEL
	elif [ -f "/etc/SuSE-release" ]; then		# SuSE
		knd=`cat /etc/SuSE-release 2> /dev/null | grep "VERSION = "`
		ver=${knd#*VERSION = }
		knd=`cat /etc/SuSE-release 2> /dev/null | grep "PATCHLEVEL = "`
		knd=${knd#*PATCHLEVEL = }
		ver="${ver}.${knd}"
		knd=SuSE
	elif [ -f "/etc/vine-release" ]; then		# Vine
		knd=Vine
	elif [ -f "/etc/turbolinux-release" ]; then	# Turbo Linux
		knd=Turbo
	elif [ -f "/etc/fedora-release" ]; then		# Fedora core
		knd=`cat /etc/fefora-release 2> /dev/null | grep "Fedora release"`
		knd=${knd% *}
		ver=${knd##* }
		knd=Fedora
	elif [ -f "/etc/debian_version" ]; then		# Debian
		ver=`cat /etc/debian_version`
		knd=Debian
	elif [ -f "/etc/redhat-release" ]; then		# Red Hat
		knd=`cat /etc/redhat-release 2> /dev/null | grep "CentOS"`
		if [ -n "$knd" ]; then	# CentOS
			knd=`cat /etc/redhat-release 2> /dev/null | grep "CentOS"`
			knd=${knd% *}
			ver=${knd##* }
			knd=CentOS
		else
			knd=`cat /etc/redhat-release 2> /dev/null | grep "Enterprise Linux"`
			knd=${knd% *}
			ver=${knd##* }
			knd=RedHat
		fi
	else
		if [ -f "/etc/lsb-release" ]; then
			dstrib_id=`cat /etc/lsb-release 2> /dev/null | grep "DISTRIB_ID="`
			dstrib_id=${dstrib_id#*DISTRIB_ID=}
			if [ "$dstrib_id" = "Ubuntu" ]; then
				knd=Ubuntu
				ver=`cat /etc/lsb-release 2> /dev/null | grep "DISTRIB_RELEASE="`
				ver=${ver#*DISTRIB_RELEASE=}
			fi
		fi
	fi
	echo "$knd $ver"
}

kv=`ck_linux`
k=${kv% *}
v=${kv#* }
un=`uname -a`
r=${un#* * }
r=${r%% *}
r=${r%?${r#*.*.*[.-]}}

if [ "$long" = "true" ]; then
	echo "$kv - $un"
else
	echo "$k$v $r"
fi


exit 0
