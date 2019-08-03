#!/usr/bin/ksh
 
#
# Essexer. Agent control implementer.
# 
# 07/10/98 igor  Ignore this command alltogether if SXR_DBHOME is different
#                from SXR_HOME, i.e. the test is running against a remote
#                server.
#
# 11/20/2002 Yuki Hashimoto
#            If SXR_AGENT_FG is set to "1", the agent will start on
#            the foregroud only on NT.
#
#  8/20/2003 Yuki Hashimoto
#            If SXR_ALTARBORPATH is set to an alternate ARBORPATH, Essbase
#            in that specified location will start and stop.
#
#  1/14/2003 Yuki Hashimoto
#            If SXR_AGTCTL_LD_PRELOAD is set, LD_PRELOAD is set to the value
#            if SXR_AGTCTL_LD_PRELOAD
#
#  3/ 7/2005 Yuki Hashimoto
#            If SXR_AGTCTL_PID is set, the value is used to get process IDs
#            of ESSBASE and ESSSVR
#
#  3/ 8/2005 Yuki Hashimoto
#            If SXR_AGTCTL_IGNORE_AGENT is set, it will start Essbase even if
#            there is an existing Essbase instance running.
#
#  3/10/2005 Yuki Hashimoto
#            If SXR_AGTCTL_GETLIC is set, it will copy the file specified in
#            SXR_AGTCTL_GETLIC to $SXR_WORK before it starts the Agent.
#
#  8/19/2005 Yuki Hashimoto
#            Modified how agent_count gets computed by adding double-quotes
#            per request.
#
#  9/12/2005 Yuki Hashimoto
#            Use the previous method for nti, and the one with doube-quotes
#            for the rest
#
#  7/18/2007 Yuki Hashimoto
#            This change added an argument, $SXR_DBHOST, passed to
#            the agtshut.scr script.
#
# 12/12/2008 Yuki Hashimoto
#            Added essexercr and essexersxr to ignore on nti
#
#  1/30/2009 Yuki Hashimoto
#            Added SXR_AGTCTL_STOP_SLEEP
#
#  6/15/2009 Yuki Hashimoto
#            Added grep -v 'Essbase\\eas' so that it does not count EAS
#            processes.
#
#  9/ 2/2009 Yukio Kono
#            Changed following methods to use "ps -o pid,comm" command:
#            1) Getting the agent count.
#            2) Collecting process IDs for "ESSBASE" and "ESSSVR".
#
case "$SXR_PLATFORM" in
   solaris | hpux | aix | linux ) path_sep=":" ;;
   nti | nta | win95 ) path_sep=";" ;;
esac

if ( test -n "$SXR_ALTARBORPATH" )
then
   ARBORPATH="${SXR_ALTARBORPATH}"
   PATH="${SXR_ALTARBORPATH}/bin${path_sep}${PATH}"
   CLASSPATH="${SXR_ALTCLASSPATH}"

   case "$SXR_PLATFORM" in
      solaris ) LD_LIBRARY_PATH="${SXR_ALTARBORPATH}/bin${path_sep}${LD_LIBRARY_PATH}" ;;
      hpux ) SHLIB_PATH="${SXR_ALTARBORPATH}/bin${path_sep}${SHLIB_PATH}" ;;
      
      aix )  LIBPATH="${SXR_ALTARBORPATH}/bin${path_sep}${LIBPATH}" ;;
   esac
   
fi

if ( test ! $SXR_HOST = $SXR_DBHOST )
then

   print -u2 "sxr agtctl $@: Command ignored due to remote server."
   return 1
fi

case $SXR_PLATFORM in
 
#   solaris | hpux | aix | linux )
   solaris | aix | linux )
      ESS_IMAGE_NAME="ESSBASE"
      ESS_COMMAND="ESSBASE password -b &"
#     PS="ps -lfu $LOGNAME"
#     PID="$PS | egrep -i 'essbase|esssvr' | grep -v 'essbase/' | \
#        grep -v -- '-p essbase' | grep -v '/essbase' | \
#        grep -v 'Essbase\\eas' | \
#        grep -v grep | awk '{print \$4}'"
      PS="ps -u $LOGNAME -o pid,comm"
      PID="$PS | egrep -i 'essbase|esssvr' | grep -v grep | \
         awk '{print \$1}'"
      ;;
 
   hpux )
      # If you want to use "ps -o pid,comm" command on HP-UX 10.10 or later,
      # you need to change the UNIX95 compliant mode.
      # (XPG4=X/Open Portability Guide Issue 4)
      # Please refer "man ps" or http://docs.hp.com/em/5965-4406/ch05s14.html
      export UNIX95=
      export PATH=/usr/bin/xpg4:$PATH
      ESS_IMAGE_NAME="ESSBASE"
      ESS_COMMAND="ESSBASE password -b &"
      PS="ps -u $LOGNAME -o pid,comm"
      PID="$PS | egrep -i 'essbase|esssvr' | grep -v grep | \
         awk '{print \$1}'"
      ;;
 
   nti | nta )
      ESS_IMAGE_NAME="essbase"
      if ( test "$SXR_AGENT_FG" = "1" )
      then
         ESS_COMMAND="start essbase password"
      else
         ESS_COMMAND="start essbase password -b"
      fi
#     PS="ps -lfu $LOGNAME"
#     PID="$PS | egrep -i 'essbase|esssvr' | egrep -v 'essbase[/_]' | \
#        grep -v 'essbase\\\\' | grep -v -- '-p essbase' | \
#        grep -v '\\\\essbase' | grep -v 'essbasecr' | \
#        grep -v 'essbasesxr' | \
#        grep -v grep | awk '{print \$2}'"
      PS="ps -o pid,comm"
      PID="$PS | egrep -i 'essbase|esssvr' | grep -v grep | \
         awk '{print \$1}'"
      ;;
 
   win95)
      ESS_IMAGE_NAME="essbase"
      ESS_COMMAND="start essbase password -b"
      PS="ps"
      PID="$PS | egrep -i 'essbase|esssvr' | grep -v grep | \
         awk '{print \$2}'"
      ;;
 
   os2)
      ESS_IMAGE_NAME="essbase"
      ESS_COMMAND="start essbase password -b"
      PS="ps"
      PID="$PS | egrep -i 'essbase|esssvr' | grep -v grep | \
         awk '{print \$1}'"
      ;;
 
   *) print -u2 "sxr agtctl: $SXR_PLATFORM: Unsupported platform."
      return 1
esac

if ( test -n "$SXR_AGTCTL_PID" )
then
  PID=$SXR_AGTCTL_PID
fi

if (test "$1" = "-force"); then
  force="yes"
  shift
fi
 
if ( test $# -eq 0 ); then
  flag="status"
else
  flag="$1"
fi


# case $SXR_PLATFORM in
#   nti | nta )
#     agent_count=$($PS | grep -i $ESS_IMAGE_NAME | egrep -v 'essbase[/_]' | grep -v 'essbase\\' | grep -v 'essbasecr' | grep -v 'essbasesxr' | grep -v -- '-p essbase' | grep -v 'Essbase\\eas' | grep -v grep | wc -l)
#     ;;
#   *)
#     agent_count=$($PS | grep -i "$ESS_IMAGE_NAME " | grep -v 'essbase/' | grep -v -- '-p essbase' | grep -v grep | wc -l)
#     ;;
# esac
agent_count=$($PS | grep -i $ESS_IMAGE_NAME | grep -v grep | wc -l)

case $flag in
 
  status)

    echo $agent_count
    ;;

  start)

    if ( test $agent_count -gt 0 )
    then
      # Agent is already running.  Kill only if -force.
 
      if (test -n "$force"); then
        $SXR_HOME/bin/agtctl.sh kill
      elif ( test ! "$SXR_AGTCTL_IGNORE_AGENT" = "1" )
      then
        return 0
      fi
    fi
    
    if ( test -n "$SXR_AGTCTL_LD_PRELOAD" )
    then
      export LD_PRELOAD=$SXR_AGTCTL_LD_PRELOAD
      echo LD_PRELOAD=$LD_PRELOAD
    fi
    
    if ( test -n "$SXR_AGTCTL_GETLIC" )
    then
      cp $SXR_AGTCTL_GETLIC $SXR_WORK
    fi

    eval ${SXR_ESSBASE:-"$ESS_COMMAND"}

    if ( test -n "$SXR_AGTCTL_START_SLEEP" )
    then
      echo "Sleep for $SXR_AGTCTL_START_SLEEP"
      sleep $SXR_AGTCTL_START_SLEEP
    fi
    ;;
 
  stop)

    if ( test $agent_count -gt 0 )
    then
      $SXR_HOME/bin/esscmd1.sh "" 1 $SXR_HOME/scr/agtshut.scr 3          \
                               %USERNAME=$SXR_USER %PASSWORD=$SXR_PASSWORD \
                               %HOST=$SXR_DBHOST
      fi

    if ( test -n "$SXR_AGTCTL_STOP_SLEEP" )
    then
      echo "Sleep for $SXR_AGTCTL_STOP_SLEEP"
      sleep $SXR_AGTCTL_STOP_SLEEP
    fi

      ;;
 
  kill)

    for pid in $(eval ${PID})
    do
      kill -9 $pid
    done

    #
    # Sleep a second just so the killed processes are out of the picture
    #

    sleep 1  
    ;;
 
  *)
     print -u2 "sxr agtctl: $flag: Bad argument."
     return 1
esac
