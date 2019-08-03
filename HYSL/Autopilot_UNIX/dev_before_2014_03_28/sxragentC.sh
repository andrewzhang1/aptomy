#!/usr/bin/ksh

# SxrAgent
#
# Help: sxragent.sh help
#
#  10/12/2007 Yuki Hashimoto
#             This file is called by a SxrAgent server when a SxrAgent client
#             requets to start another SxrAgent server.
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

if ( test -a "./SxrAgent.jar" ) then
  export CLASSPATH=./SxrAgent.jar${path_sep}"${CLASSPATH}"
elif ( test -a "${AUTOPILOT}/bin/SxrAgent.jar" ) then
  export CLASSPATH=${AUTOPILOT}/bin/SxrAgent.jar${path_sep}"${CLASSPATH}"
elif ( test -a "${SXR_HOME}/bin/SxrAgent.jar" ) then
  export CLASSPATH=${SXR_HOME}/bin/SxrAgent.jar${path_sep}"${CLASSPATH}"
elif ( test -z "${SXRAGENT_HOME}" ) then
  echo "Set SXRAGENT_HOME"
  exit
else
  export CLASSPATH=${SXR_AGENTHOME}/SxrAgent.jar${path_sep}"${CLASSPATH}"
fi

if ( test -z "${SXR_SHCMD}") then
  SXR_SHCMD=${SHELL}
fi

SXR_VIEWHOME=${VIEW_PATH}${path_sep}autoregress

java -Dsxrshcmd=${SXR_SHCMD} -Dsxrhome=${SXR_HOME} -Dsxragentport=${SXRAGENT_PORT} -Darborpath=${ARBORPATH} -Dsxrviewhome=${SXR_VIEWHOME} -Dviewpath=${VIEW_PATH} com.hyperion.essexer.SxrAgent.SxrAgent

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
