@echo off
rem
rem Autotest : Start autopilot
rem

title Autopilot preparation.

if "%1" == "MKSINST" goto MKSINST
if "%1" == "/?" goto HELP

mksinfo > nul 2>&1
if errorlevel 1 goto NOMKS
echo Found MKS installation.
goto NEXT

:NOMKS
cmd.exe /E:on /c "%~f0" MKSINST

echo Done MKS installation.
echo Please re-boot computer now.
echo And re-run this script again.

pause

Rem # When you want to run the MKS tools without restart
Rem # Remove following Rem lines. But you might get shared
Rem # memory fault on "whoami" command.
Rem set MKSLOC=C:/MKS
Rem set NUTCROOT=C:\MKS
Rem set DISPLAY=:0.0
Rem set MAN_CHM_INDEX=%MKSLOC%/etc/chm/tkutil.idx;%MKSLOC%/etc/chm/tkapi.idx;%MKSLOC%/etc/chm/tcltk.idx;%MKSLOC%/etc/chm/tkcurses.idx
Rem set MAN_HTM_PATHS=%MKSLOC%/etc/htm/perl;%MKSLOC%/etc/htm/perl/pod;%MKSLOC%/etc/htm/perl/ext;%MKSLOC%/etc/htm/perl/lib
Rem set MAN_TXT_INDEX=%MKSLOC%/etc/tkutil.idx;%MKSLOC%/etc/tkapi.idx;%MKSLOC%/etc/tcltk.idx;%MKSLOC%/etc/tkcurses.idx
Rem set ROOTDIR=%MKSLOC%
Rem set SHELL=%MKSLOC%/mksnt/sh.exe
Rem set TERM=nutc
Rem set TERMCAP=%NUTCROOT%\etc\termcap
Rem set TERMINFO=%NUTCROOT%\usr\lib\terminfo

Rem set HOME=c:/
Rem set TMPDIR=%HOME%/tmp
Rem mkdir C:\tmp
Rem set Path=%MKSLOC%/bin;%MKSLOC%/bin/X11;%MKSLOC%/mksnt;%PATH%
Rem set PATHEXT=%PATHEXT%;.sh;.ksh;.csh;.sed;.awk;.pl

goto END

:HELP
echo "autotest.bat [bg|sh|MKSINST]"
echo "MKSINST: Install MKS Toolkit."
echo "bg:      Run autopilot framework in background."
echo "sh:      Run shell after setup environment."
goto ENG

Rem =====================================================
Rem Inst MKS Part : Start

:MKSINST

echo MKS not found. Install MKS Toolkit.

echo Connecting to \\nar200\essbasecr.
:RETRYCON
net use \\nar200.us.oracle.com\essbasecr

pushd \\nar200.us.oracle.com\essbasecr
if not errorlevel 1 goto INSTCONT

:FAILCON
echo Failed to connect to \\nar200\essbasecr
choice /C RC /M "Reconnect or cancel ?"
if %ERRORLEVEL% == 1 goto RETRYCON
goto SUBEND

:INSTCONT

Rem Install MKS Toolkit
cd Programs
cd MKSToolKit
cd Mks
cd 9.2

if "%PROCESSOR_ARCHITECTURE%" == "AMD64" (
  set MSI=toolkit64x.msi
) else (
  if "%PROCESSOR_ARCHITECTURE%" == "x86" (
    set MSI=toolkit.msi
  ) else (
    set MSI=toolkit64i.msi
  )
)

echo Installing MKS ToolKit 9.2...
msiexec /I %MSI% /qn SERIALNUMBER="TK0605D28397" ^
	LICENSEPIN="0CGF 60OL PK30" ^
	ACCESSKEY="HCmxEg8Lx8sCzeavie+fvir7gf8DF" ^
	TKROOTDIR="C:\MKS"

Rem Install Patch

cd "Patch 3"

if "%PROCESSOR_ARCHITECTURE%" == "AMD64" (
  set MSI=TK64x.msp
) else (
  if "%PROCESSOR_ARCHITECTURE%" == "x86" (
    set MSI=TK.msp
  ) else (
    set MSI=TK64i.msp
  )
)

echo Applying MKS 9.2 Patch 3...
msiexec.exe /p %MSI% /qn

popd
net use /D \\nar200.us.oracle.com\essbasecr > nul 2>&1

:SUBEND
exit
Rem Inst MKS Part : End
Rem =====================================================

:NEXT

set i=0
:FEXISTLOOP
if not exist C:\auto_%i%.sh goto FEXISTEXIT
set /A i=%i%+1 > nul
goto FEXISTLOOP
:FEXISTEXIT
Rem the value of "skip" parameter should be same as the "Rem # END OF THE DOS PORTION" line number
for /F "skip=139 usebackq delims=~" %%i in ("%~f0") do @echo %%i >> C:\auto_%i%.sh
sh C:\auto_%i%.sh %1 %2 %3 %4 %5
del /F C:\auto_%i%.sh
goto END

Rem # END OF THE DOS PORTION
#!/usr/bin/ksh
#######################################################################
# Shell script portion start here
#######################################################################
# Warnning: We cannot use a tilda character on following section.
#   Because DOS FOR command uses the tilda character as separator.
#######################################################################

# Read parameter
# $1 can be below:
#    MSKINST - handled by CMD.EXE
#    alt/tst - Assign path with altbin or tst
unset alt tst runbg runsh
while [ $# -ne 0 ]; do
	case $1 in
		a|alt|altbin|d|dev)
			alt="true";;
		t|tst|test)
			tst="true";;
		bg)
			runbg="true";;
		sh)
			runsh="true";;
	esac
	shift
done

#######################################################################
# Get current drive information

i=0;
while [ -f "C:/auto_${i}.tmp" ]; do
	let i=i+1
done

ftmp="C:/auto_${i}.tmp"

# Create used drive list
chcpback=`chcp`
chcpback=${chcpback##* }
[ "$chcpback" != "437" ] && chcp 437 > /dev/null 2>&1 || unset chcpback
[ -f "$ftmp" ] && rm -rf "$ftmp"
fsutil fsinfo drives > "$ftmp"
ltmp=`cat -v "$ftmp" | tail -1`
ltmp=${ltmp#* }
ltmp=`echo $ltmp | sed -e "s/:.../ /g" -e "s/\^M//g"`
[ -f "$ftmp" ] && rm -rf "$ftmp"
for i in $ltmp; do
	chcp 437 > /dev/null 2>&1
	fsutil fsinfo drivetype $i: | sed -e "s/ - Fixed Drive/F/g" -e "s/ - CD-ROM Drive/C/g" -e "s! - Remote/Network Drive!R!g" -e "s/ - .*$/O/g" >> "$ftmp"
done
[ -n "$chcpback" ] && chcp $chcpback > /dev/null 2>&1
# echo "Drive list:"
# cat "$ftmp"

# Create free drive list
echo "Creating free drive list..."
freedrv="ZYXWVUTSRQPONMLKJIHGFED"
while read line; do
	tmp=${line%${line#?}}
	freedrv=`echo $freedrv | sed -e "s/$tmp//g"`
done < "$ftmp"
echo "  Free Drive : $freedrv"

# Create Fixed Drive list
echo "Creating fixed dirve list..."
fixlist=`grep "^.\:F" "$ftmp"`
fixdrv=
for i in $fixlist; do
	[ -z "$fixdrv" ] && fixdrv=${i%${i#?}} || fixdrv="${fixdrv}${i%${i#?}}"
done
echo "  Fixed drive : $fixdrv"

[ -f "$ftmp" ] && rm -f "$ftmp"

# Create net drive list
net use | grep ":" > "$ftmp"
for i in hit pre_rel essbasesxr; do
	dtmp=`grep "nar200" "$ftmp" | grep "$i "`
	[ -n "$dtmp" ] && eval $i=`echo $dtmp | awk '{print $2}'`
done
[ -f "$ftmp" ] && rm -f "$ftmp"

#######################################################################
# Drive mapping and define variables.
# HIT_ROOT, BUILD_ROOT, AUTOPILOT

# HIT_ROOT
echo "Check //nar200/hit mapping..."
if [ -n "$hit" -a -d "$hit" ]; then
	export HIT_ROOT="$hit/"
else
	if [ -n "$hit" ]; then
		echo "But failed to access there. Try to re-connect."
		d=${hit%:*}
	else
		echo "No HIT portion is mounted."
		if [ -z "$freedrv" ]; then
			echo "There is no free drive letter."
			echo "Please un-mount some drive and try this again."
			exit 10
		fi
		d=${freedrv%${freedrv#?}}
		freedrv=${freedrv#?}
		echo "Try to assign \\\\nar200.us.oracle.com\\hit to ${d}:"
	fi
	while [ 1 ]; do
		net use "${d}:" "\\\\nar200.us.oracle.com\\hit"
		[ $? -eq 0 ] && break
		echo "Failed to assign \\\\nar200.us.oracle.com\\hit to ${d}: drive."
		while [ 1 ]; do
			print -n "Re-try to connect or terminate ? (r/t)"
			read ans
			[ "$ans" = "r" ] && break
			[ "$ans" = "t" ] && exit 1
		done
	done
	export HIT_ROOT="${d}:/"
fi

# BUILD_ROOT
echo "Check //nar200/pre_rel mapping..."
if [ -n "$pre_rel" -a -d "$pre_rel" ]; then
	export BUILD_ROOT="${pre_rel}/essbase/builds"
else
	if [ -n "$pre_rel" ]; then
		echo "But failed to access there. Try to re-connect."
		d=${pre_rel%:*}
	else
		echo "No BUILD_ROOT portion is mounted."
		if [ -z "$freedrv" ]; then
			echo "There is no free drive letter."
			echo "Please un-mount some drive and try this again."
			exit 10
		fi
		d=${freedrv%${freedrv#?}}
		freedrv=${freedrv#?}
		echo "Try to assign \\\\nar200.us.oracle.com\\pre_rel to ${d}:"
	fi
	while [ 1 ]; do
		net use "${d}:" "\\\\nar200.us.oracle.com\\pre_rel"
		[ $? -eq 0 ] && break
		echo "Failed to assign \\\\nar200.us.oracle.com\\pre_rel to ${d}: drive."
		while [ 1 ]; do
			print -n "Re-try to connect or terminate ? (r/t)"
			read ans
			[ "$ans" = "r" ] && break
			[ "$ans" = "t" ] && exit 1
		done
	done
	export BUILD_ROOT="${d}:/essbase/builds"
fi

# AUTOPILOT
echo "Check //nar200/essbasesxr mapping..."
if [ -n "$essbasesxr" -a -d "$essbasesxr" ]; then
	export AUTOPILOT="${essbasesxr}/regressions/Autopilot_UNIX"
else
	if [ -n "$essbasesxr" ]; then
		echo "But failed to access there. Try to re-connect."
		d=${essbasesxr%:*}
	else
		echo "No AUTOPILOT portion is mounted."
		if [ -z "$freedrv" ]; then
			echo "There is no free drive letter."
			echo "Please un-mount some drive and try this again."
			exit 10
		fi
		d=${freedrv%${freedrv#?}}
		freedrv=${freedrv#?}
		echo "Try to assign \\\\nar200.us.oracle.com\\essbasesxr to ${d}:"
	fi
	while [ 1 ]; do
		net use "${d}:" "\\\\nar200.us.oracle.com\\essbasesxr"
		[ $? -eq 0 ] && break
		echo "Failed to assign \\\\nar200.us.oracle.com\\essbasesxr to ${d}: drive."
		while [ 1 ]; do
			print -n "Re-try to connect or terminate ? (r/t)"
			read ans
			[ "$ans" = "r" ] && break
			[ "$ans" = "t" ] && exit 1
		done
	done
	export AUTOPILOT="${d}:/regressions/Autopilot_UNIX"
fi


#######################################################################
# PATH normalization
# Convert \ to /, Long file name -> short file name
crrpath=`print -r $PATH | sed -e "s/\\\\\\/\\\//g"`

echo "Normalizing \$PATH variable..."
newpath=
crrdir=`pwd`
oldpath="$crrpath"
while [ -n "$crrpath" ]; do
	onepath=${crrpath%%;*}
		# echo "#OnePath=<$onepath>"
	[ "$onepath" = "$crrpath" ] && unset crrpath || crrpath=${crrpath#*;}
	if [ -n "$onepath" ]; then
		newone=
		while [ -n "$onepath" ]; do
			one=${onepath%%/*}
			[ "$one" = "$onepath" ] && unset onepath || onepath=${onepath#*/}
			if [ -n "$one" ]; then
		# echo "#One=<$one>(`pwd`)"
				if [ "${one%:*}" != "$one" ]; then	# DRIVE LETTER
					cd "${one}/"
					if [ $? -ne 0 ]; then
						newone=
		# echo "#No drive $one exist."
						break	# No drive exist.
					fi
					newone="$one"
				else
					if [ -d "$one" ]; then
						one=`cmd /C dir /x | grep "<DIR>" | egrep -wi "${one}" | sed -e "s/^.*<DIR> *//g" | awk '{print $1}'`
						newone="$newone/$one"
						cd $one
					else
		# echo "#No $one fodler."
						newone=
						break	# No such directory
					fi
				fi
			fi
		done
		if [ -n "$newone" ]; then
			[ -z "$newpath" ] && newpath="$newone" || newpath="${newpath};${newone}"
		fi
	fi
done
cd "$crrdir"
if [ "$alt" = "true" ]; then
	pathdef="\$AUTOPILOT/dev;\$AUTOPILOT/bin"
elif [ "$tst" = "true" ]; then
	pathdef="\$AUTOPILOT/tst;\$AUTOPILOT/dev;\$AUTOPILOT/bin"
else
	pathdef="\$AUTOPILOT/bin"
fi

#######################################################################
# Detect HOME location

echo "Detecting \$HOME definition..."
_HOME=
if [ -n "$HOME" -a "$HOME" != "c:/" -a "$HOME" != "C:/" ]; then
	free=`df -k "$HOME" | awk '{print $3}' | sed "s/\/.*$//g"`
	if [ "$free" -lt 10485760 ]; then
		echo "Found \$HOME directory."
		echo "But there is not enough free spaces(${free}KB/10485760KB)."
	else
		_HOME=$HOME
	fi
else
	if [ -z "$HOME" ]; then
		echo "There is no \$HOME definition."
	else
		echo "Detected \$HOME defined to default location($HOME)."
		if [ -d "$HOME/${USERNAME}" ]; then
			echo "  Found $HOME/${USERNAME} folder."
			free=`df -k "$HOME/" | awk '{print $3}' | sed "s/\/.*$//g"`
			if [ "$free" -lt 10485760 ]; then
				echo "  But there is not enough free space on $HOME."
			else
				echo "  Will use this folder as \$HOME."
				_HOME="$HOME${USERNAME}"
			fi
		fi
	fi
	if [ -z "$_HOME" -a -n "$fixdrv" ]; then
		tard=
		tmp=$fixdrv
		while [ -n "$tmp" ]; do
			d=${tmp%${tmp#?}}
			tmp=${tmp#?}
			free=`df -k ${d}:/ | awk '{print $3}' | sed "s/\/.*$//g"`
			if [ "$free" -ge 10485760 ]; then
				echo "  Found drive ${d}: has enough spaces."
				echo "  Will create ${d}:/${USERNAME} folder and use it as \$HOME."
				[ ! -d "${d}:/${USERNAME}" ] && mkdir ${d}:/${USERNAME} > /dev/null 2>&1
				_HOME="${d}:/${USERNAME}"
				break
			fi
		done
	fi
fi

if [ -z "$_HOME" ]; then
	_dispfree=
	while [ 1 ]; do
		if [ -z "$_dispfree" ]; then
			if [ -n "$fixdrv" ]; then
				tmp=$fixdrv
				echo "Current free space on fixed dirves:"
				while [ -n "$tmp" ]; do
					d=${tmp%${tmp#?}}
					tmp=${tmp#?}
					free=`df -k ${d}:/ | awk '{print $3}' | sed "s/\/.*$//g"`
					echo " ${d}:${free}K"
					[ -z "$tmp" ] && echo "" || print -n ","
				done
			else	
				echo "- There is no fixed drive."
			fi
			_dispfree=1
		fi
		print -n "Please enter \$HOME location(?help) :"
		read ans
		if [ "$ans" = "sh" ]; then
			ksh
		elif [ "$ans" = "cancel" -o "$ans" = "stop" -o "$ans" = "exit" ]; then
			exit 2
		elif [ "$ans" = "?" ]; then
			echo "?      : Display help."
			echo "free   : Re-Display free size on fixed drives."
			echo "cancel : Terminate execution.(stop|terminate)"
			echo "sh     : Execute sh."
		elif [ "$ans" = "free" ]; then
			_dispfree=
		else
			if [ -d "$ans" ]; then
				free=`df -k ${ans} | awk '{print $3}' | sed "s/\/.*$//g"`
				if [ "$free" -lt 10485760 ]; then
					echo "There is not enough free spaces(${free}KB/10485760KB) on ${ans}."
				else
					_HOME=$ans
					break;
				fi		
			else
				echo "$ans not found."
			fi
		fi
	done
fi
# HOME Normalization
crrdir=`pwd`
_home=`print -r $_HOME | sed -e "s/\\\\\\/\\\//g"`
newone=
while [ -n "$_home" ]; do
	one=${_home%%/*}
	[ "$one" = "$_home" ] && unset _home || _home=${_home#*/}
	if [ -n "$one" ]; then
		if [ "${one%:*}" != "$one" ]; then	# DRIVE LETTER
			cd "${one}/"
			if [ $? -ne 0 ]; then
				newone=
				break	# No drive exist.
			fi
			newone="$one"
		else
			if [ -d "$one" ]; then
				one=`cmd /C dir /x | grep "<DIR>" | egrep -i " ${one}$" | sed -e "s/^.*<DIR> *//g" | awk '{print $1}'`
				newone="$newone/$one"
				cd $one
			else
				newone=
				break	# No such directory
			fi
		fi
	fi
done
cd "$crrdir"
[ -z "$newone" ] && newone=$_HOME

export HOME="$newone"
echo "\$HOME is set to $HOME."
H="HKEY_CURRENT_USER\\Environment"
registry -s -k "$H" -n "HOME" -v "$HOME" > /dev/null 2>&1

export PATH="$newpath"
[ -f "$HOME/capienv.sh" ] && . "$HOME/capienv.sh"
_tmp=`eval echo \"$pathdef\"`
export PATH="$_tmp;$PATH;$BUILD_ROOT/common/bin"

if [ ! -d "$HOME/hyperion" ]; then
	echo "There is no $HOME/hyperion folder."
	echo "Create it for \$PROD_ROOT location."
	mkdir $HOME/hyperion > /dev/null 2>&1
fi
export PROD_ROOT="$HOME/hyperion"

if [ ! -d "$HOME/tmp" ]; then
	echo "There is no $HOME/tmp folder."
	echo "Create it for \$TMP, \$TEMP, \$TMPDIR location."
	mkdir $HOME/tmp > /dev/null 2>&1
fi
export TMP="$HOME/tmp"
export TEMP="$HOME/tmp"
export TMPDIR="$HOME/tmp"

if [ ! -d "$HOME/views" ]; then
	echo "There is no $HOME/views folder."
	echo "Create it for \$VIEW_PATH location."
	mkdir $HOME/views > /dev/null 2>&1
	export VIEW_PATH="$HOME/views"
fi
export VIEW_PATH="$HOME/views"

#######################################################################
# Check "Local" in $windir/System32/Drivers/etc/hosts

loc=`grep Local $windir/System32/Drivers/etc/hosts`
if [ -z "$loc" ]; then
	echo "There is no \"Local\" entry in the hosts file."
	echo "127.0.0.1	Local" >> $windir/System32/Drivers/etc/hosts
fi

export PS1='[$PWD] '

#######################################################################
# END
#######################################################################


echo "##########################################"
echo "### Finish setup autopilot environment ###"
echo "##########################################"
echo "Environment variables definition:"
prtenv.sh HOME AUTOPILOT BUILD_ROOT HIT_ROOT PROD_ROOT VIEW_PATH TMP TEMP TMPDIR
echo ""
echo "PATH:"
print -r $PATH
echo ""

if [ ! -f "$HOME/profile.ksh" ]; then
	echo "There is no profile.ksh under the \$HOME."
	while [ 1 ]; do
		print -n "Do you want to create it (y/n/c) ?"
		read ans
		if [ "$ans" = "y" -o "$ans" = "yes" ]; then
			echo "echo \"Running $HOME/profile.ksh...\"" > $HOME/profile.ksh
			echo "unset HYPERION_HOME ARBORPATH ESSBASEPATH ESSLANG" >> $HOME/profile.ksh
			echo "export HOME=\"$HOME\"" >> $HOME/profile.ksh
			echo "export BUILD_ROOT=\"$BUILD_ROOT\"" >> $HOME/profile.ksh
			echo "if [ ! -d \"\$BUILD_ROOT\" ]; then" >> $HOME/profile.ksh
			echo "  net use \"${BUILD_ROOT%:*}:\" \"\\\\\\\\\\\\\\\\nar200.us.oracle.com\\\\\\\\pre_rel\"" >> $HOME/profile.ksh
			echo "fi" >> $HOME/profile.ksh
			echo "export HIT_ROOT=\"$HIT_ROOT\"" >> $HOME/profile.ksh
			echo "if [ ! -d \"\$HIT_ROOT\" ]; then" >> $HOME/profile.ksh
			echo "  net use \"${HIT_ROOT%:*}:\" \"\\\\\\\\\\\\\\\\nar200.us.oracle.com\\\\\\\\hit\"" >> $HOME/profile.ksh
			echo "fi" >> $HOME/profile.ksh
			echo "export AUTOPILOT=\"$AUTOPILOT\"" >> $HOME/profile.ksh
			echo "if [ ! -d \"\$AUTOPILOT\" ]; then" >> $HOME/profile.ksh
			echo "  net use \"${AUTOPILOT%:*}:\" \"\\\\\\\\\\\\\\\\nar200.us.oracle.com\\\\\\\\essbasesxr\"" >> $HOME/profile.ksh
			echo "fi" >> $HOME/profile.ksh
			echo "for one in views hyperion tmp; do" >> $HOME/profile.ksh
			echo "  if [ ! -d \"\$one\" ]; then" >> $HOME/profile.ksh
			echo "    echo \"Missing \$one folder. Create it.\"" >> $HOME/profile.ksh
			echo "    mkdir \$HOME/\$one" >> $HOME/profile.ksh
			echo "  fi" >> $HOME/profile.ksh
			echo "done" >> $HOME/profile.ksh
			echo "export VIEW_PATH=\"\$HOME/views\"" >> $HOME/profile.ksh
			echo "export PROD_ROOT=\"\$HOME/hyperion\"" >> $HOME/profile.ksh
			echo "export TMP=\"\$HOME/tmp\"" >> $HOME/profile.ksh
			echo "export TEMP=\"\$HOME/tmp\"" >> $HOME/profile.ksh
			echo "export TMPDIR=\"\$HOME/tmp\"" >> $HOME/profile.ksh
			echo "export PS1='[\$PWD] '" >> $HOME/profile.ksh
			echo "export AP_NOPLAT=false" >> $HOME/profile.ksh
 			echo "export PATH=\"$newpath\"" >> $HOME/profile.ksh
			echo "[ -f \"\$HOME/capienv.sh\" ] && . \$HOME/capienv.sh" >> $HOME/profile.ksh
			echo "export PATH=\"$pathdef;\$PATH;\$BUILD_ROOT/common/bin\"" >> $HOME/profile.ksh
			echo "prtenv.sh HOME AUTOPILOT BUILD_ROOT HIT_ROOT PROD_ROOT VIEW_PATH TMP TEMP TMPDIR AP_NOPLAT" >> $HOME/profile.ksh
			echo "echo \"\"" >> $HOME/profile.ksh
			echo "echo \"PATH:\"" >> $HOME/profile.ksh
			echo "print -r \$PATH" >> $HOME/profile.ksh
			break
		elif [ "$ans" = "n" -o "$ans" = "no" ]; then
			break
		elif [ "$ans" = "c" -o "cancel" ]; then
			exit 0
		fi
	done
else
	echo "There is profile.sh under the \$HOME.\n"
fi

if [ "$runbg" = "true" ]; then
	sh autopilotbg.sh
else
	while [ 1 ]; do
		print -n "Do you want to run autopilot framework in background (y/n/c) ?"
		read ans
		if [ "$ans" = "y" -o "$ans" = "yes" ]; then
			sh autopilotbg.sh
			break
		elif [ "$ans" = "n" -o "$ans" = "no" ]; then
			break
		elif [ "$ans" = "c" -o "cancel" ]; then
			exit 0
		fi
	done
fi

sh

exit 0

:END

