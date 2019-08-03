#!/usr/bin/ksh
# Get free size  in KB
# syntax1: get_free.sh <dir>
#   Get free size of <dir>
# syntax2: get_free.sh <dir> 1
#   Get mount point of the <dir>

if [ -z "$AP_DEFVAR" ]; then . apinc.sh;fi

# ^^^^ <- mount point
# ~~~~ <- free size

# Windows_NT (MKS) : df -k
# S:/ (//nar200/essbasesxr) 189281668/734003200
# ^^^                       ~~~~~~~~~ free

# SunOS : df 0k . | tail -1
# /dev/dsk/c1t1d0s7 35007716 20592928 14064711 60% /vol1
#                                     ~~~~~~~~     ^^^^^

# AIX : df -k . | tail -1
# /dev/lv00        51380224  17152044   67%   374180    47% /vol1
#                            ~~~~~~~~ free                  ^^^^^

# HP-UX : df -k . | grep free
# 1715110 free allocated Kb
# ~~~~~~~
# df -k . | head -1 | 
# /mnt/stublnx1          (stublnx1.hyperion.com:/vol4) : 547244888 total allocated Kb
# ^^^^^^^^^^^^^

# Linux : dk -k .
# Filesystem           1K-blocks       Used Avaliable Use% Mounted on
# /dev/vol1              8353460    4520268   3408848  58% /vol1
#                                             ~~~~~~~      ^^^^^

if [ $# -eq 2 ];then
	case `uname` in
		Windows_NT)
			df -k "$1" | awk '{print $1}'
			;;
		AIX)
			df -k "$1" | tail -1 | awk '{print $7}'
			;;
		SunOS)
			df -k "$1" | tail -1 | awk '{print $6}'
			;;
		HP-UX)
			df -k "$1" | head -1 | awk '{print $1}'
			;;
		Linux)
			df -kP "$1" | tail -1 | awk '{print $6}'
			;;
		*)
			echo 0
			;;
	esac
elif [ $# -eq 1 ]; then
	case `uname` in
		Windows_NT)
			df -k "$1" | awk '{print $3}' | sed "s/\// /g" | awk '{print $1}'
			;;
		AIX)
			df -k "$1" | tail -1 | awk '{print $3}'
			;;
		SunOS)
			df -k "$1" | tail -1 | awk '{print $4}'
			;;
		HP-UX)
			df -k "$1" | grep free | tail -1 | awk '{print $1}'
			;;
		Linux)
			df -kP "$1" | tail -1 | awk '{print $4}'
			;;
		*)
			echo 0
			;;
	esac
else
	echo 0
fi
