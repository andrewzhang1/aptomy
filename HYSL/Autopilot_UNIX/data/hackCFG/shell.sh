#!/usr/bin/ksh

#
# Essexer.
#
# Implementation of "sxr shell" command.
#
# 7/Oct/98 Igor  Added -mute option
# 9/Dec/98 Igor  Fixed bug where header wasn't printing any of the
#                arguments to the sxr sh command.
# 10/Dec/98 Igor Name temporary DNA files uniquely, so that if multiple
#                parallel tests execute the same shell scripts, they don't
#                collide on a DNA file name.
# 11/Dec/98 Igor Expanded to support Perl also.
#
# 08/Jun/05 Yuki Hashimoto
#           Added a feature to generate a sta file from sub shell scripts.
#           If the name of a sub shell scripts contains the value of SXR_STA,
#           a sta file is generated and named wit the sub shell script.
#
#############################################################################

#
# Parse flags and arguments
#

op='shell'  #Default

while (test "${1#-}" != "$1")
do
  case "$1" in
 
    -mute)  mute=yes
            ;;
    -perl)  op=perl
            ;;
    *)      print -u2 "sxr $op: Bad flag '$1'"
  esac
  shift
done

#
# Note that we're supporting perl on the shell path.
#

file=`${SXR_HOME}/bin/pathlkup.sh -sh "$1"`

if (test ! -n "$file")
then
  print -u2 "sxr $op: '$1': not found."
  return 2
fi
	
file_short=${file##*/}
file_root=${file_short%.*}

export SXR_CUR_SHELL=$file_short

#
# If this is a top level script, then do some housekeeping:
# 1. Setup the left margin for log_command to know how many "+"'s
#    to put in front of lines.
# 2. Stash away a flag to know to fire the triggers after the shell is
#    completed.
# 3. Remove *everything* from work directory.
#


if (test ! -n "$SXR_TOP_SHELL")
then
  # Top level shell

  export SXR_TOP_SHELL="${file_root}"
  export SXR_LOG_LMARGIN=''
  top_level=yes

  # Remove all the files from the work directory.  First try deleting the
  # files, if that doesn't work, most likely because there's too many of them,
  # recreate the directory.

  rm -rf $SXR_WORK/* 2>&1 > $SXR_NULLDEV
  if ( test $? != 0 )
  then
    # Most likely there were too many arguments to 'rm'.
    rm -rf $SXR_WORK
    if ( test $? != 0 )
    then
      print -u2 "sxr $op: Unable to clean up work directory."
      return 2
    else
      mkdir $SXR_WORK
    fi
  fi

  export SXR_SHELL_DEPTH=0
else

  # Second or deeper level shell
  export SXR_PREV_DNA=$SXR_THIS_DNA
# YUKI START
  let "tmp= SXR_SHELL_DEPTH + 1"
  export SXR_SHELL_DEPTH=$tmp
# YUKI END
fi

export SXR_THIS_DNA="${SXR_WORK}/${file_root}.$$.dna"
cd $SXR_WORK

#
# Time this script.  We calculate the timestamps as number of
# seconds elapsed since the beginning of the year.  Obviously, this
# code will fail if the test script runs over the New Years night.
#
# We also get the date in YY_MM_DD fortat so that we're able later
# to tell from looking at the first string of the statitstics file
# on what date the run was started.
#

set -A timestring $(date '+%j %H %M %S')
datestring=$(date '+%y_%m_%d')
startsecs=$((${timestring[0]}*24*3600 + ${timestring[1]}*3600 \
            + ${timestring[2]}*60 + ${timestring[3]}))

echo "+$SXR_LOG_LMARGIN $file_short ${timestring[0]}:${timestring[1]}:${timestring[2]}:${timestring[3]} $datestring"  \
              >> ${SXR_WORK}/${SXR_TOP_SHELL}.sta

if [ "$SXR_TRACECFG" = "true" ]; then
	if [ -f "$ARBORPATH/bin/essbase.cfg" ]; then
		echo "  ### essbase.cfg contents:" >> ${SXR_TOP_SHELL}.sta
		cat $ARBORPATH/bin/essbase.cfg | while read _line_; do
			echo "    {$_line_}" >> ${SXR_WORK}/${SXR_TOP_SHELL}.sta
		done
	else
		echo "  ### No esbase.cfg under $ARBORPATH/bin ### " >> ${SXR_WORK}/${SXR_TOP_SHELL}.sta
	fi
fi
#
# Run the shell/perl script.  Do not echo header if -mute was passed. We
# use the array variable to preserve the original tokens even if they
# have spaces in them (e.g. sxr sh "one long argument")
#

original_argv="$@"
shift               # Don't pass the name of the script as $1
command=$file
for arg in "$@"
do
  command="$command \"$arg\""
done

case $op in

  shell) 

    if (test -n "$mute")
    then

      ( $SXR_SHCMD -c "$command" 2>&1 ) | tee ${file_root}.sog

    else

      ( header "+" "sxr shell $original_argv" ;  \
        $SXR_SHCMD -c "$command" 2>&1 ) | tee ${file_root}.sog
    fi
    ;;

  perl)

    # Add entire SXR_PATH_SH to Perl's include path

    for path_dir in $(echo ${SXR_PATH_SH} | tr ';' ' ')
    do
      inc="$inc -I $path_dir"
    done

    if (test -n "$mute")
    then
 
      ( $SXR_SHCMD -c "perl $inc $command" 2>&1 ) | tee ${file_root}.sog
 
    else
 
      ( header "+" "sxr perl $original_argv" ;  \
        $SXR_SHCMD -c "perl $inc $command" 2>&1 ) | tee ${file_root}.sog
    fi
    ;;

  *) print -u2 "sxr $op: Internal error: unknown operation"
     ;;
esac



#
# Calculate the elapsed seconds and report it into the statistics file
#

set -A timestring $(date '+%j %H %M %S')
finishsecs=$((${timestring[0]}*24*3600 + ${timestring[1]}*3600 \
             + ${timestring[2]}*60 + ${timestring[3]}))
elapsedsecs=$(($finishsecs - $startsecs))

#
# Produce the DNA file.
#

dna_file="$SXR_VIEWHOME/sxr/${file_root}.dna"

if (test -n "$top_level")
then
  # Don't forget this shell script, unless this is a top level script.
  echo "sh/$file_short" >> ${SXR_THIS_DNA}
fi

if ( test -f ${SXR_THIS_DNA} )
then
  # Only produce a final dna file if the interim one is present.

  echo "# Essexer ${SXR_VERSION}"                  > $dna_file
  echo "#"                                         >> $dna_file
  echo "# DNA file for test ${file_short}"         >> $dna_file
  echo "# Created on : $(date '+%Y%j%H%M%S (%c)')" >> $dna_file
  echo "#         by : ${LOGNAME:-unknown} @ $SXR_HOST:$SXR_VIEWHOME" >> \
                                                      $dna_file
  echo "#" >> $dna_file
  echo "#" >> $dna_file
  cat ${SXR_THIS_DNA} | sort | uniq >> $dna_file
fi

#
# If this is a top level script then 1. Report number of sucs/difs,
# 2. see if the trigger has been set.
# If this is not a top level script, then prapagade the dna
# information to the caller's dna file.
#

if (test -n "$top_level")
then
  # Calculate number of diffs and sucs.

  sucno=$(ls *.suc 2> $SXR_NULLDEV | wc -w)
  difno=$(ls *.dif 2> $SXR_NULLDEV | wc -w)

  echo "+$SXR_LOG_LMARGIN $file_short ${timestring[0]}:${timestring[1]}:${timestring[2]}:${timestring[3]} Elapsed sec:    $elapsedsecs Suc: $sucno Dif: $difno" >> ${SXR_WORK}/${SXR_TOP_SHELL}.sta
		
  if ( test -n "$SXR_STA_DEPTH" ); then
    dir_list=`ls *.ssta`
    for ssta_file in ${dir_list}
    do
      cat ${ssta_file} >> ${SXR_WORK}/${SXR_TOP_SHELL}.asta
    done
  fi


  if ( test -n "$SXR_SHELL_TRIGGER"  && ( test "$op" = "shell" ))
  then
    export SXR_TRIGGER_ARGC=$(($# + 1))
    argno=0
    for arg in $@
    do
      argno=$((argno+=1))
      eval "export SXR_TRIGGER_ARG${argno}=$arg"
    done

    # Trigger

    header "+" "ON-SHELL trigger '$SXR_SHELL_TRIGGER'"
    $SXR_SHCMD -c "$SXR_SHELL_TRIGGER"
    header "" "End ON_SHELL trigger"
  fi

 if ( test -n "$SXR_PERL_TRIGGER"  && ( test "$op" = "perl" ))
  then
    export SXR_TRIGGER_ARGC=$(($# + 1))
    argno=0
    for arg in $@
    do
      argno=$((argno+=1))
      eval "export SXR_TRIGGER_ARG${argno}=$arg"
    done

    # Trigger

    header "+" "PERL trigger '$SXR_PERL_TRIGGER'"
    $SXR_SHCMD -c "$SXR_PERL_TRIGGER"
    header "" "End PERL trigger"
  fi


else
  if ( test -n "$SXR_STA_ACCUMULATED" ); then
    sucaccno=$(ls *.suc 2> $SXR_NULLDEV | wc -w)
    difaccno=$(ls *.dif 2> $SXR_NULLDEV | wc -w)
    echo "+$SXR_LOG_LMARGIN $file_short ${timestring[0]}:${timestring[1]}:${timestring[2]}:${timestring[3]} Elapsed sec:    $elapsedsecs Suc: $sucaccno Dif: $difaccno (Accumulated)" >> ${SXR_WORK}/${SXR_TOP_SHELL}.sta
  else
    echo "+$SXR_LOG_LMARGIN $file_short ${timestring[0]}:${timestring[1]}:${timestring[2]}:${timestring[3]} Elapsed sec:     $elapsedsecs " \
                >> ${SXR_WORK}/${SXR_TOP_SHELL}.sta
  fi

  if ( ( test -n "$SXR_STA" && test "$(echo $file_root | awk '/'$SXR_STA'/ {print 1}')" = "1" ) || test "$SXR_STA_DEPTH" -ge "$SXR_SHELL_DEPTH" ); then
      sucno_tmp=$(ls *.suc 2> $SXR_NULLDEV | wc -w)
      difno_tmp=$(ls *.dif 2> $SXR_NULLDEV | wc -w)
  
    if( test ! -f "${SXR_WORK}/${SXR_TOP_SHELL}.suc.tmp" ); then
      print -n $sucno_tmp > ${SXR_WORK}/${SXR_TOP_SHELL}.suc.tmp
      sucno=$sucno_tmp
    else
      tmp=$(cat ${SXR_WORK}/${SXR_TOP_SHELL}.suc.tmp)
      let "sucno=sucno_tmp - tmp"
      print -n $sucno_tmp > ${SXR_WORK}/${SXR_TOP_SHELL}.suc.tmp
    fi

    if( test ! -f "${SXR_WORK}/${SXR_TOP_SHELL}.dif.tmp" ); then
      print -n $difno_tmp > ${SXR_WORK}/${SXR_TOP_SHELL}.dif.tmp
      difno=$difno_tmp
    else
      tmp=$(cat ${SXR_WORK}/${SXR_TOP_SHELL}.dif.tmp)
      let "difno=difno_tmp - tmp"
      print -n $difno_tmp > ${SXR_WORK}/${SXR_TOP_SHELL}.dif.tmp
    fi

    let "next_depth=SXR_SHELL_DEPTH + 1"

    if ( test -f "${SXR_WORK}/${SXR_TOP_SHELL}.suc.${next_depth}.tmp" ); then
      tmp=$(cat ${SXR_WORK}/${SXR_TOP_SHELL}.suc.${next_depth}.tmp)
      rm -f ${SXR_WORK}/${SXR_TOP_SHELL}.suc.${next_depth}.tmp
      let "sucno=sucno + tmp"
    elif ( test ! -f "${SXR_WORK}/${SXR_TOP_SHELL}.suc.${SXR_SHELL_DEPTH}.tmp" ); then
      print -n $sucno > ${SXR_WORK}/${SXR_TOP_SHELL}.suc.${SXR_SHELL_DEPTH}.tmp
    else
      tmp=$(cat ${SXR_WORK}/${SXR_TOP_SHELL}.suc.${SXR_SHELL_DEPTH}.tmp)
      let "tmp=sucno + tmp"
      print -n $tmp > ${SXR_WORK}/${SXR_TOP_SHELL}.suc.${SXR_SHELL_DEPTH}.tmp
    fi

    if ( test -f "${SXR_WORK}/${SXR_TOP_SHELL}.dif.${next_depth}.tmp" ); then
      tmp=$(cat ${SXR_WORK}/${SXR_TOP_SHELL}.dif.${next_depth}.tmp)
      rm -f ${SXR_WORK}/${SXR_TOP_SHELL}.dif.${next_depth}.tmp
      let "difno=difno + tmp"
    elif ( test ! -f "${SXR_WORK}/${SXR_TOP_SHELL}.dif.${SXR_SHELL_DEPTH}.tmp" ); then
      print -n $difno > ${SXR_WORK}/${SXR_TOP_SHELL}.dif.${SXR_SHELL_DEPTH}.tmp
    else
      tmp=$(cat ${SXR_WORK}/${SXR_TOP_SHELL}.dif.${SXR_SHELL_DEPTH}.tmp)
      let "tmp=difno + tmp"
      print -n $tmp > ${SXR_WORK}/${SXR_TOP_SHELL}.dif.${SXR_SHELL_DEPTH}.tmp
    fi

    echo "+$SXR_LOG_LMARGIN $file_short ${timestring[0]}:${timestring[1]}:${timestring[2]}:${timestring[3]} Elapsed sec:    $elapsedsecs Suc: $sucno Dif: $difno" >> ${SXR_WORK}/${file_root}.ssta
  fi


  #
  # Current shell file may not have produced a dna file if it did
  # not do any sxr commands, but if it did, merge it into the previous level's
  # dna file.
  #

  if (test -f ${SXR_THIS_DNA})
  then
    cat ${SXR_THIS_DNA}  >> ${SXR_PREV_DNA}
  fi
fi

rm -f $SXR_WORK/${file_root}.dna
return 0

