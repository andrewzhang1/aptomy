#!/usr/bin/ksh

# SxrAgent
#
# Help: sxragent.sh help
#
#  12/ ?/2005 Yuki Hashimoto
#
# Note: We need to use the JRE version that comes with Hyperion Common.
#
#       E.g.) set PATH=c:\Hyperion\Common\JRE\Sun\1.5.0\bin;%PATH%
#
#   9/28/2007 Yuki Hashimoto
#             You don't need to be in an Essexer view
#
#  10/ 2/2007 Yuki Hashimoto
#             Added a document to the end of this file.
#
if ( test -n "${SXR_PLATFORM}") then
  case "$SXR_PLATFORM" in
    solaris | hpux | aix | linux ) path_sep=":" ;;
    nti | nta | win95 ) path_sep=";" ;;
  esac
elif ( test "${OS}" = "Windows_NT" ) then
  path_sep=";"
else
  path_sep=":"
fi

if ( test -a "${SXRAGENT_HOME}" ) then
  export CLASSPATH=${SXR_AGENTHOME}/SxrAgent.jar${path_sep}"${CLASSPATH}"
elif ( test -a "./SxrAgent.jar" ) then
  export CLASSPATH=./SxrAgent.jar${path_sep}"${CLASSPATH}"
elif ( test -a "${AUTOPILOT}/bin/SxrAgent.jar" ) then
  export CLASSPATH=${AUTOPILOT}/bin/SxrAgent.jar${path_sep}"${CLASSPATH}"
elif ( test -a "${SXR_HOME}/bin/SxrAgent.jar" ) then
  export CLASSPATH=${SXR_HOME}/bin/SxrAgent.jar${path_sep}"${CLASSPATH}"
else
  echo "Couldn't find SxrAgent.jar"
  exit
fi

if ( test -z "${SXR_SHCMD}") then
  SXR_SHCMD=${SHELL}
fi

if ( test -z "${SXRAGENT_PORT}") then
#  echo "SXRAGENT_PORT is empty"
#  echo "Set SXRAGENT_PORT to 2047"
  SXRAGENT_PORT=2047
#else
#  echo "SXRAGENT_PORT is ${SXRAGENT_PORT}"
fi

java -Dsxrshcmd=${SXR_SHCMD} -Dsxrhome=${SXR_HOME} -Dsxragentport=${SXRAGENT_PORT} -Darborpath=${ARBORPATH} -Dsxrviewhome=${SXR_VIEWHOME} -Dviewpath=${VIEW_PATH} com.hyperion.essexer.SxrAgent.SxrAgent $1 $2 $3 $4 $5 $6 $7 $8 $9 ${10}

#
# D O C U M E N T
#
#### Document History
#
# 10/2/2007 Yuki Hashimoto wrote the first draft.
#
#
#### Summary
#
#    SxrAgent is a tool that lets us perform the following tasks at a remote
# machine:
#
# 1. observe and kill Essbase processes including Esssvr, Esscmd family, and
#    Essmsh
# 2. execute any UNIX commands
# 3. Retrieve files
#
#   The tool has potential to do more.  We can add new commands to it.
#
#
#### Configuration
#
#    The tool has already been installed in the $SXR_HOME/bin directory and the
# \\nar200\essbasesxr\regressions\Autopilot_UNIX\bin.  We should have either or
# both in our PATH.
#
#    If $SXR_HOME is not set, we need to set $SXRAGENT_HOME to either the
# location.
#
#    Optionally, we can set the SxrAgent network port by setting
# $SXRAGENT_PORT. The default port number is 2047.
#
#
#### Usage
#
## SxrAgent server
#
#    SxrAgent needs to run at the remote machines that we want to perform
# commands. Make sure ARBORPATH is set if we want SxrAgent to retrieve Essbase-
# related files such as XCP files.  To run SxrAgent as a server:
#
# SxrAgent ( or SxrAgent.sh )
#
## SxrAgent client
#
#   We run SxrAgent only when we perform a command just like the UNIX ping
# program.
#
# SxrAgent <remote host name> <command> [command arguments]
# (We might need to type SxrAgent.sh.)
#
#
#### All available commands
#
#    To find out all the available commands, run
#
# SxrAgent help
#
#    To see the help on a specific command, run
#
# SxrAgent help <command name>
#
#
#### Architecture
#
#    We do not need to know the architecture to use SxrAgent.  This section is
# for people who need to know about it.
#
#    SxrAgent is a client server program written purely in Java.  It utilizes
# the Java RMI technology for the client server communication.  
#    SxrAgent uses a couple UNIX commands, ps and kill, to achieve some tasks.
# If commands like killAllApps donÅft work, ps is not called the way it should
# be called.
#
