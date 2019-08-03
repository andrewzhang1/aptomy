#!/usr/bin/ksh
# ver_mkbase.sh : Set variables for mk_basefile.sh.
# 
# DESCRIPTION:
# Set following variables which are required for making base file.
# _VER_VER_DYNDIR : Dynamic files and folders for each version
# _VER_DIRCMP     : Ignore files and folders pattern for the egrep command.
# _VER_DIRLST     : Dump folder list for make size file.
#
# SYNTAX:
# ver_mkbase.sh <ver#>
# <ver#> : Version number in fulll/short format.
#
# CALL FROM:
# mk_basefile.sh:
#
# HISTORY
# 08/01/2008 YK - First Edition.
# 11/05/2008 YK - Add Dickens
# 03/20/2009 YK - Add Talleyrand and Zola
# 05/20/2009 YK - Pull together after 9.5x
#                 Add _VER_DIRLST for making directory list.

# _VER_DIRLST : Directories list to a created File/Size list. - perl - filesize.pl
#			  You don't need just double 
# _VER_DYNDIR : Dynamic compare files list - perl comparing string
# _VER_DIRCMP : Ignore files list - perl comparing string
#               If you want to Ignore start from $ARBOR..., you need define ^\\\$ARBOR...
# 01/05/2012  : Add version 11.1.2.2.100 dynamic base.

unset _VER_DYNDIR _VER_DIRCMP
case $1 in
	5*|6*|7*| \
	london|joyce|joyce_dobuild|tide| \
	zephyr|tsunami|woodstock|beckett|9.0*|9.2*|9.3*)
		_VER_DYNDIR="^ARBORPATH/bin/.*"
		_VER_DYNDIR="${_VER_DYNDIR}|^ARBORPATH/api/redist/.*"

		_VER_DIRCMP="^ARBORPATH/Uninstall.*|.*\.log|.*\.LOG|.*/ESSCMDQ|.*/ESSCMDG|^ARBORPATH/bin/ESSTESTCREDSTORE"

		_VER_DIRLST="\$ARBORPATH \$HYPERION_HOME/common" 
		;;
	# kennedy|9.5.0.0.0|11.1.1.0.0)
	# kennedy2|11.1.1.1.0)
	# 11.1.1.1.1)	# Kennedy2 Oracle patch
	# dickens|11.1.1.2.0)
	# zola|11.1.1.3.0)
	# talleyrand|11.1.2.0.0)
	*)
		case $AP_SECMODE in
			fa|rep)
				_VER_DYNDIR="^ESSBASEPATH/bin/.*"
				_VER_DYNDIR="$_VER_DYNDIR|^ARBORPATH/bin/.*"
				_VER_DYNDIR="$_VER_DYNDIR|^ARBORPATH/java/.*"
				_VER_DYNDIR="$_VER_DYNDIR|^HYPERION_HOME/client/epm/Essbase/EssbaseJavaAPI/bin/.*"
				_VER_DYNDIR="$_VER_DYNDIR|^HYPERION_HOME/client/epm/Essbase/EssbaseJavaAPI/lib/.*"
				_VER_DYNDIR="$_VER_DYNDIR|^HYPERION_HOME/client/epm/Essbase/EssbaseRTC/bin/.*"
				_VER_DYNDIR="$_VER_DYNDIR|^HYPERION_HOME/client/epm/Essbase/api/lib/.*"
				_VER_DYNDIR="$_VER_DYNDIR|^HYPERION_HOME/client/epm/Essbase/api/include/.*"
				_VER_DYNDIR="$_VER_DYNDIR|^HYPERION_HOME/common/EssbaseJavaAPI/11.1.2.0/lib/.*"

			# 	_VER_DIRCMP=".*\.log .*|.*\.LOG .*|.* -> .*"
				_VER_DIRCMP="^ARBORPATH/Uninstall.*|.*\.log|.*\.LOG|.*/ESSCMDQ|.*/ESSCMDG|^ARBORPATH/bin/ESSTESTCREDSTORE"
		
				_VER_DIRLST="\$ESSBASEPATH" 
				_VER_DIRLST="$_VER_DIRLST \$ARBORPATH"
				_VER_DIRLST="$_VER_DIRLST \$HYPERION_HOME/client" 
				_VER_DIRLST="$_VER_DIRLST \$HYPERION_HOME/common" 
				_VER_DIRLST="$_VER_DIRLST \$HYPERION_HOME/bin" 
				_VER_DIRLST="$_VER_DIRLST \$ORACLE_INSTANCE/config"
				;;
			*)
				_VER_DYNDIR="^ARBORPATH/bin/.*"
				_VER_DYNDIR="$_VER_DYNDIR|^HYPERION_HOME/common/EssbaseJavaAPI/9.5.0.0/lib/.*"
				_VER_DYNDIR="$_VER_DYNDIR|^HYPERION_HOME/common/EssbaseJavaAPI/11.1.2.0/lib/.*"
				_VER_DYNDIR="$_VER_DYNDIR|^HYPERION_HOME/common/EssbaseRTC/9.5.0.0/bin/.*"
				_VER_DYNDIR="$_VER_DYNDIR|^HYPERION_HOME/common/EssbaseRTC/11.1.2.0/bin/.*"
				_VER_DYNDIR="$_VER_DYNDIR|^HYPERION_HOME/products/Essbase/EssbaseClient/api/lib/.*"
				_VER_DYNDIR="$_VER_DYNDIR|^HYPERION_HOME/products/Essbase/EssbaseClient/api/include/.*"
				_VER_DYNDIR="$_VER_DYNDIR|^HYPERION_HOME/products/Essbase/EssbaseClient/api/redist/[^/][^/]*"
				_VER_DYNDIR="$_VER_DYNDIR|^HYPERION_HOME/products/Essbase/EssbaseClient/bin/.*"
				_VER_DYNDIR="$_VER_DYNDIR|^ARBORPATH/api/lib/.*"
				_VER_DYNDIR="$_VER_DYNDIR|^ARBORPATH/api/include/.*"
				_VER_DYNDIR="$_VER_DYNDIR|^ARBORPATH/java/.*"
		
				# _VER_DIRCMP=".*\.log .*|.*\.LOG .*"
				_VER_DIRCMP="^ARBORPATH/Uninstall.*|.*\.log|.*\.LOG|.* -> .*"
				_VER_DIRCMP="${_VER_DIRCMP}|.*/ESSCMDQ|.*/ESSCMDG|^ARBORPATH/bin/ESSTESTCREDSTORE"
				_VER_DIRCMP="${_VER_DIRCMP}|^HYPERION_HOME/common/EssbaseRTC.*/bin/essbase.cfg"
		
				_VER_DIRLST="\$ARBORPATH" 
				_VER_DIRLST="$_VER_DIRLST \$HYPERION_HOME/products/Essbase/EssbaseClient" 
				_VER_DIRLST="$_VER_DIRLST \$HYPERION_HOME/common" 
				_VER_DIRLST="$_VER_DIRLST \$HYPERION_HOME/bin" 
				_VER_DIRLST="$_VER_DIRLST \$HYPERION_HOME/../ohs/opmn" 
				;;
		esac
		;;
esac

