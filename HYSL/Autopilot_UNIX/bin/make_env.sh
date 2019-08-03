#!/usr/bin/ksh

if [ "$0" = "-sh" -o "$0" = "-ksh" ]; then
	me=`which make_env.sh`
else
	me=`which $0`
fi
myloc=${me%/*}
if [ -n "$myloc" -a "$myloc" != "$me" ]; then
	crrdir=`pwd`
	cd $myloc
	myloc=`pwd`
	cd $crrdir
else
	myloc=`pwd`
fi

if [ $# -ge 1 -a "$1" = "help" ]; then
	lno=`grep -n "^#HELPCONT" "$me"`
	lno=${lno%%:*}
	ttl=`wc -l "$me" | awk '{print $1}'`
	cnt=`expr $ttl - $lno`
	tail -$cnt $me
	exit 0
fi

if [ `uname` = "Windows_NT" ]; then
	tmp_BUILD_ROOT="//nar200/pre_rel/essbase/builds"
	tmp_AUTOPILOT="//nar200/essbasesxr/regressions/Autopilot_UNIX"
	sep=";"
else
	tmp_BUILD_ROOT="/net/nar200/vol/vol2/pre_rel/essbase/builds"
	tmp_AUTOPILOT="/net/nar200/vol/vol3/essbasesxr/regressions/Autopilot_UNIX"
	sep=":"
fi

if [ ! -d "$tmp_BUILD_ROOT" -o ! -d "$tmp_AUTOPILOT" ]; then
	echo "Couldn't access nar200 on network place."
	echo "Please make sure your environment can reach there."
	exit 1
fi

echo "********************************"
echo "   Autopilot environment Setup"
echo "********************************"

# Read arguments

while [ $# -ne 0 ]; do
	v=${1%=*}
	p=${1#*=}
	if [ "$v" != "$1" -a -n "$v" ]; then
		eval export _$v=\"$p\"
		a="\$_$v"
		a=`eval echo $a`
		echo "  $v=\"$a\""
	else
		echo "Invalid definition \"$1\"."
	fi
	shift
done

# Check $HOME

if [ -n "$_HOME" ]; then
	if [ ! -d "$_HOME" ]; then
		echo "  Specified directory($_HOME) not found."
		_HOME=
	elif [ -n "$HOME" ]; then
		echo "You already defined \$HOME=\"$HOME\"."
		while [ 1 ]; do
			print -n "  Do you want to re-define it ? (y/n)"
			read ans
			case $ans in
				yes|y)
					export HOME=$_HOME
					break;;
				no|n)
					_HOME= 
					break;;
				*) ;;
			esac
		done
	fi
fi
if [ -z "$HOME" ]; then
	echo "No \$HOME environment variable defnied."
	while [ -z "$HOME" ]; do
		print -n "  Enter \$HOME location ? "
		read ans
		if [ -n "$ans" ]; then
			p=${ans#*\$}
			if [ "$p" != "$ans" ]; then
				ans=`eval echo $ans`
			fi
			if [ -d "$ans" ]; then
				export HOME=$ans
				_HOME=$ans
			else
				echo "  Couldn't find entered directory."
			fi
		fi
	done
fi

# Check BUILD_ROOT

if [ -n "$_BUILD_ROOT" ]; then
	if [ ! -d "$_BUILD_ROOT" ]; then
		echo "  Specified directory($_BUILD_ROOT) not found."
		_BUILD_ROOT=
	elif [ -n "$BUILD_ROOT" ]; then
		echo "You already defined \$BUILD_ROOT=\"$BUILD_ROOT\"."
		while [ 1 ]; do
			print -n "  Do you want to re-define it ? (y/n)"
			read ans
			case $ans in
				yes|y)
					export BUILD_ROOT=$_BUILD_ROOT
					export PATH="$BUILD_ROOT/common/bin${sep}$PATH"
					break;;
				no|n)
					_BUILD_ROOT=
					break;;
				*) ;;
			esac
		done
	fi
fi
if [ -z "$BUILD_ROOT" ]; then
	echo "No \$BUILD_ROOT environment variable defnied."
	echo "  If you use following network location, just hit enter."
	echo "  [$tmp_BUILD_ROOT]"
	while [ -z "$BUILD_ROOT" ]; do
		print -n "  Enter \$BUILD_ROOT location ?"
		read ans
		if [ -n "$ans" ]; then
			p=${ans#*\$}
			if [ "$p" != "$ans" ]; then
				ans=`eval echo $ans`
			fi
			if [ -d "$ans" ]; then
				export BUILD_ROOT=$ans
				export PATH="$BUILD_ROOT/bin${sep}$PATH"
				_BUILD_ROOT=$ans
			else
				echo "  Couldn't find entered directory."
			fi
		else
			export BUILD_ROOT=$tmp_BUILD_ROOT
			export PATH="$BUILD_ROOT/bin${sep}$PATH"
			_BUILD_ROOT=$tmp_BUILD_ROOT
		fi
	done
fi


# Check AUTOPILOT

if [ -n "$_AUTOPILOT" ]; then
	if [ ! -d "$_AUTOPILOT" ]; then
		echo "  Specified directory($_AUTOPILOT) not found."
		_AUTOPILOT=
	elif [ -n "$AUTOPILOT" ]; then
		echo "You already defined \$AUTOPILOT=\"$AUTOPILOT\"."
		while [ 1 ]; do
			print -n "  Do you want to re-define it ? (y/n)"
			read ans
			case $ans in
				yes|y)
					export AUTOPILOT=$_AUTOPILOT
					export PATH="${myloc}${sep}$PATH"
					break;;
				no|n)
					_AUTOPILOT=
					break;;
				*) ;;
			esac
		done
	fi
fi
if [ -z "$AUTOPILOT" ]; then
	echo "No \$AUTOPILOT environment variable defnied."
	echo "  If you use following network location, just hit enter."
	echo "  [$tmp_AUTOPILOT]"
	while [ -z "$AUTOPILOT" ]; do
		print -n "  Enter \$AUTOPILOT location ?"
		read ans
		if [ -n "$ans" ]; then
			p=${ans#*\$}
			if [ "$p" != "$ans" ]; then
				ans=`eval echo $ans`
			fi
			if [ -d "$ans" ]; then
				export AUTOPILOT=$ans
				export PATH="${myloc}${sep}$PATH"
				_AUTOPILOT=$ans
			else
				echo "  Couldn't find entered directory."
			fi
		else
			export AUTOPILOT=$tmp_AUTOPILOT
			export PATH="${myloc}${sep}$PATH"
			_AUTOPILOT=$tmp_AUTOPILOT
		fi
	done
fi


# Check VIEW_PATH

if [ -n "$_VIEW_PATH" ]; then
	if [ ! -d "$_VIEW_PATH" ]; then
		echo "  Specified directory($_VIEW_PATH) not found."
		_VIEW_PATH=
	elif [ -n "$VIEW_PATH" ]; then
		echo "You already defined \$VIEW_PATH=\"$VIEW_PATH\"."
		while [ 1 ]; do
			print -n "  Do you want to re-define it ? (y/n)"
			read ans
			case $ans in
				yes|y)
					export VIEW_PATH=$_VIEW_PATH
					break;;
				no|n)
					_VIEW_PATH= 
					break;;
				*) ;;
			esac
		done
	fi
fi
if [ -z "$VIEW_PATH" ]; then
	echo "No \$VIEW_PATH environment variable defnied."
	echo "  If \$VIEW_PATH is not defined, autopilot attempt to use "
	echo "  your $HOME/views folder for the regresion work."
	echo "  If you define the \$VIEW_PATH environment variable, "
	echo "  autopilot use it for the regression work folder."
	ans=
	while [ -z "$ans" ]; do
		print -n "  Do you want to define this variable ? (y|n)"
		read ans
		case $ans in
			yes|y|no|n)
				break;;
			*) ans=;;
		esac
	done
	if [ "$ans" = "y" -o "$ans" = "yes" ]; then
		while [ -z "$VIEW_PATH" ]; do
			print -n "  Enter \$VIEW_PATH location ? "
			read ans
			if [ -n "$ans" ]; then
				p=${ans#*\$}
				if [ "$p" != "$ans" ]; then
					ans=`eval echo $ans`
				fi
				if [ -d "$ans" ]; then
					export VIEW_PATH=$ans
					_VIEW_PATH=$ans
				else
					echo "  Couldn't find entered directory."
				fi
			fi
		done
	fi
fi


# Check PROD_ROOT and HYPERION)HOME

if [ -z "$HYPERION_HOME" ]; then
	echo "No \$HYPERION_HOME environment variable defined."
	if [ -n "$_PROD_ROOT" ]; then
		if [ ! -d "$_PROD_ROOT" ]; then
			echo "  Specified directory($_PROD_ROOT) not found."
			_PROD_ROOT=
		elif [ -n "$PROD_ROOT" ]; then
			echo "You already defined \$PROD_ROOT=\"$PROD_ROOT\"."
			while [ 1 ]; do
				print -n "  Do you want to re-define it ? (y/n)"
				read ans
				case $ans in
					yes|y)
						export PROD_ROOT=$_PROD_ROOT
						break;;
					no|n)
						_PROD_ROOT= 
						break;;
					*) ;;
				esac
			done
		fi
	fi
	if [ -z "$PROD_ROOT" ]; then
		echo "  If \$HYPERON_HOME is not defined, autopilot attempt to install "
		echo "  product just under your $HOME/hyperion folder."
		echo "  If you define the \$PROD_ROOT environment variable, autopilot"
		echo "  use it for the target location of the product installer."
		echo "  No \$PROD_ROOT environment variable defnied."
		ans=
		while [ -z "$ans" ]; do
			print -n "  Do you want to define this variable ? (y|n)"
			read ans
			case $ans in
				yes|y|no|n)
					break;;
				*) ans=;;
			esac
		done
		if [ "$ans" = "y" -o "$ans" = "yes" ]; then
			while [ -z "$PROD_ROOT" ]; do
				print -n "  Enter \$PROD_ROOT location ? "
				read ans
				if [ -n "$ans" ]; then
					p=${ans#*\$}
					if [ "$p" != "$ans" ]; then
						ans=`eval echo $ans`
					fi
					if [ -d "$ans" ]; then
						export PROD_ROOT=$ans
						_PROD_ROOT=$ans
					else
						echo "  Couldn't find entered directory."
					fi
				fi
			done
		fi
	fi
fi

# Check VERSION

if [ -n "$_VERSION" ]; then
	if [ ! -d "$BUILD_ROOT/$_VERSION" ]; then
		echo "  Specified version directory($_VERSION) not found."
		echo "  Reset specified VERSION setting."
		_VERSION=
	elif [ -n "$VERSION" ]; then
		echo "You already defined \$VERSION=\"$VERSION\"."
		while [ 1 ]; do
			print -n "  Do you want to re-define it ? (y/n)"
			read ans
			case $ans in
				yes|y)
					export VERSION=$_VERSION
					break;;
				no|n)
					_VERSION=
					break;;
				*) ;;
			esac
		done
	fi
fi
if [ -z "$VERSION" ]; then
	echo "No version information."
	while [ -z "$VERSION" ]; do
		print -n "  Which version do you want create env file for ? (ls)"
		read ans
		if [ -n "$ans" ]; then
			p=${ans#*\$}
			if [ "$p" != "$ans" ]; then
				ans=`eval echo $ans`
			fi
			p1=`echo $ans | awk '{print $1}'`
			p2=`echo $ans | awk '{print $2}'`
			if [ "$p1" = "ls" ]; then
				ls $BUILD_ROOT/$p2
			elif [ -d "$BUILD_ROOT/$ans" ]; then
				export VERSION=$ans
				_VERSION=$ans
			else
				echo "  There is no $ans directory under the \$BUILD_ROOT/builds directory."
			fi
		fi
	done
fi

# Check ARCH
cmstrct=`$myloc/ver_cmstrct.sh "$VERSION"`
if [ `uname` = "Windows_NT" ]; then
	if [ -n "$_ARCH" ]; then
		if [ -n "$ARCH" ]; then
			echo "You already defined \$ARCH=\"$ARCH\"."
			while [ 1 ]; do
				print -n "  Do you want to re-define it ? (y/n)"
				read ans
				case $ans in
					yes|y)
						export ARCH=$_ARCH
						break;;
					no|n)
						_ARCH=
						break;;
					*) ;;
				esac
			done
			
		fi
	fi
	if [ -n "$ARCH" ]; then
		if [ "$ARCH" = "win32" -o "$ARCH" = "win64" -o "$ARCH" = "winmonte" -o "$ARCH" = "winamd64" ]; then
			export ARCH=$_ARCH
		else
			echo "The specified value in \$ARCH($ARCH) is invalid."
			export ARCH=
		fi
	fi
	if [ "$cmstrct" != "old" ]; then
		platforms="win32|win64|winmonte|winamd64"
	else
		platforms="win32|win64|winmonte"
	fi
	if [ -z "$ARCH" ]; then
		echo "There is no \$ARCH defined."
		echo "If your environment is not win32, you need to define this variable."
		while [ 1 ]; do
			print -n "  Enter your platform ? ($platforms)"
			read ans
			if [ -n "$ans" ]; then
				p=`echo $platforms | grep $ans`
				if [ -n "$p" ]; then
					if [ "$ans" != "win32" ]; then
						export ARCH=$ans
						_ARCH=$ans
					else
						_ARCH=
					fi
					break
				fi
			fi
		done
	fi
	if [ "$ARCH" = "win32" ]; then
		export ARCH=
		_ARCH=
	fi
elif [ "$cmstrct" != "old" ]; then
	if [ `uname` = "SunOS" -o `uname` = "AIX" ]; then
		if [ -n "$_ARCH" ]; then
			if [ -n "$ARCH" ]; then
				echo "You already defined \$ARCH=\"$ARCH\"."
				while [ 1 ]; do
					print -n "  Do you want to re-define it ? (y/n)"
					read ans
					case $ans in
						yes|y)
							export ARCH=$_ARCH
							break;;
						no|n)
							_ARCH=
							break;;
						*) ;;
					esac
				done
				
			fi
		fi
		if [ -n "$ARCH" ]; then
			if [ "$ARCH" != "32" -a "$ARCH" != "64" ]; then
				echo "The specified value in \$ARCH($ARCH) is invalid."
				export ARCH=
				_ARCH=
			fi
		fi
		if [ -z "$ARCH" ]; then
			echo "There is no \$ARCH defined. In $VERSION, you should define this variable."
			while [ 1 ]; do
				print -n "  Enter your platform ? (32|64)"
				read ans
				if [ "$ans" = "64" -o "$ans" = "32" ]; then
					export ARCH=$ans
					_ARCH=$ans
					break
				fi
			done
		
		fi
	fi
fi


# CONCLUSION

env="${VERSION}_`hostname`"
if [ `uname` = "SunOS" -o `uname` = "AIX" ]; then
	if [ "$cmstrct" = "NEW" ]; then
		env=${env}_${ARCH}
	fi
fi
env=${env}.env

# echo "      HOME=$_HOME"
# echo "BUILD_ROOT=$_BUILD_ROOT"
# echo " AUTOPILOT=$_AUTOPILOT"
# echo " PROD_ROOT=$_PROD_ROOT"
# echo " VIEW_PATH=$_VIEW_PATH"
# echo "   VERSION=$_VERSION"
# echo "      ARCH=$_ARCH"
# echo " user name=${LOGNAME}"
# echo "  hostname=`hostname`"
# echo "  env file=$env"

env="$AUTOPILOT/env/${LOGNAME}/$env"

if [ ! -d "$AUTOPILOT/env/${LOGNAME}" ]; then
	echo "Create ${LOGNAME} directory under the $AUTOPILOT/env directory."
	mkdir $AUTOPILOT/env/${LOGNAME}
	if [ $? -ne 0 ]; then
		echo "Failed to create it. Please check the privilege."
		exit 1
	fi
fi

if [ -f "$env" ]; then
	echo "Find user environment file for this environemnt."
	echo "Execute it now..."
	. $myloc/se.sh "$VERSION"
fi
echo "Check and creating user env file..."
export AP_NOENV=false
. $myloc/setchk_env.sh $VERSION $env > $HOME/make_env.log
echo "Result is recorded in to \$HOME/make_env.log"

# Make a profile base

pf="$HOME/profile.make_env"
if [ -f "$pf" ]; then
	rm -f $pf
fi
touch $pf
for item in HOME BUILD_ROOT AUTOPILOT ARCH VIEW_PATH PROD_ROOT; do
	v=`eval "echo \\$_$item"`
	if [ -n "$v" ]; then
		echo "export $item=\"$v\"" >> $pf
# 		echo "export $item=\"$v\""
	fi
done

if [ -n "$_BUILD_ROOT" ]; then
	echo "export PATH=\"\$BUILD_ROOT/common/bin${sep}\$PATH\"" >> $pf
#	echo "export PATH=\"\$BUILD_ROOT/common/bin${sep}\$PATH\""
fi


if [ -n "$_AUTOPILOT" ]; then
	crrdir=`pwd`
	cd $AUTOPILOT
	ap=`pwd`
	cd $myloc
	ab=`pwd`
	cd $crrdir
	echo "export PATH=\"\$AUTOPILOT/${ab##$ap/}${sep}\$PATH\"" >> $pf
#	echo "export PATH=\"\$AUTOPILOT/${ab##$ap/}${sep}\$PATH\""
fi

echo "==============================="
echo "Created $env file."
echo "Please add the contents of $pf into your .profile."

exit 0
#HELPCONT
make_env.sh : Make user environment ssetup file
usage: make_env.sh [help[ <VAR>=<value>...]]
  <VAR>  : The variable name to define.
           HOME, AUTOPILOT, BUILD_ROOT, VERSION, VIEW_PATH, PROD_ROOT, ARCH
  <value>: Value for the variable.
