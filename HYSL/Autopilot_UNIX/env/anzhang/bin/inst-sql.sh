#!/bin/sh
# Copyright (c) 1995-2000 Hyperion Solutions Corporation.  All rights reserved.
#   Install third-party support for Solaris SQL Interface.

#### Welcome, defaults, and usage (10) ####
product='SQL Interface for Solaris, third-party support'
echo 1>&2 'Starting installation for "'"$product"'" .... '

USAGE='USAGE: '"$0"


#### Prompting support (30) ####

## -- Ask for input from user
# $1: prompt	$2: default	$3: other choices
# Returning value comes back as $input
# USAGE:  ask 'Prompt' "default" ...
ask () {
	_pr="$1"
	_def="$2"
	prompt="${_pr}"
	shift
	if [ $# -gt 0 ]; then prompt="$prompt"' ['"${_def}"']' ; shift ; fi
	if [ $# -gt 0 ]; then prompt="$prompt"' {'"${_def} ""$@"'}' ; fi
	echo 1>&2 "$prompt ?"
	while read input ; do
		if [ -z "$input" ]; then input="${_def}" ; break ; fi
		if [ $# -eq 0 ]; then break ; fi
# @@@@ extend to limit to choices given
		break;
	done
}

## -- Error and information reporting
FATAL () {
	echo 1>&2 "$0:  ERROR: $1"
	shift
	while [ $# -gt 0 ]; do
		echo 1>&2 "$0: (ERROR)   $1"
		shift
	done
	echo 1>&2 "$0: EXITING ...."
	exit 1
}

ERROR () {
	echo 1>&2 "$0:  ERROR: $1"
	shift
	while [ $# -gt 0 ]; do
		echo 1>&2 "$0: (ERROR)   $1"
		shift
	done
}

WARN () {
	echo 1>&2 "$0:  WARNING: $1"
	shift
	while [ $# -gt 0 ]; do
		echo 1>&2 "$0: (WARNING)   $1"
		shift
	done
}

FYI () {
	echo 1>&2 "$0:  FYI: $1"
	shift
	while [ $# -gt 0 ]; do
		echo 1>&2 "$0: (FYI)   $1"
		shift
	done
}


#### Command line handling (45) ####
while getopts "f:" option ; do
	case "$option" in
	\?)	/usr/ucb/echo 1>&2 "$USAGE" ; exit 2 ;;
	esac
done
if [ $OPTIND -gt 1 ]; then shift `expr $OPTIND - 1` ; fi


#### Installation preconditions (50) ####

## -- Need Essbase Solaris installed
if [ -z "$ARBORPATH" ]; then
	FATAL "ARBORPATH not found" \
		"Please install 'Essbase Server for Solaris'" \
		"and set up its environment, then reinstall this product."
fi

## -- Where to install this product?
if [ ! -d $ARBORPATH ]; then
	FATAL "could not locate directory $ARBORPATH" \
		"Please install Hyperion's Server product before this add-on"
fi

#### Installation postprocessing (125) ####

## -- Create user setup scripts, expanding on envvars.
echo "s|@@ARBORPATH@@|$ARBORPATH|g" >> $HYPERION_HOME/common/ODBC/Merant/5.0/tmpl.sed

## -- Copy files into ARBOR bin/ along with support.
( cd $HYPERION_HOME/common
  echo working
  sed -f ODBC/Merant/5.0/tmpl.sed ODBC/Merant/5.0/odbc.ini > $ARBORPATH/bin/.odbc.ini
  if [ -f $HOME/.odbc.ini ]; then
     ( rm $HOME/.odbc.ini )
  fi
        ln -s $ARBORPATH/bin/.odbc.ini $HOME/.odbc.ini
)      

## -- Update symlink to point to SQL support
( cd $ARBORPATH/bin ; rm -f libesssql.so ; ln -s libesssql.so.1 libesssql.so )


#### Clean up (15) ####
FYI "Driver setup complete!"
exit 0
