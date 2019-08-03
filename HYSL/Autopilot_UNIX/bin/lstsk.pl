#!/usr/bin/perl

# History
# 07/01/2010 YKono	First edition.
# 08/06/2010 YKono	Add display On:/Start:/End:/Suc information on -opt
# 06/05/2012 YKono	Support -alive option to check the task is alive or not
# 02/22/2013 YKono	Support -sort for platform.

# Display help contents.
# Note: help contents will be end of this file after "__DATA__" line.
sub display_help()
{
	if ($#_ >= 0) {
		($mes)=@_;
		print "lstsk.sh : $mes\n";
	}
	print $_ foreach(<DATA>);
}

# Read system environment variables and initialize variables.
$AUTOPILOT=$ENV{'AUTOPILOT'};
$usr=$ENV{'LOGNAME'};
if ($usr eq undef) {
	$usr=$ENV{'USERNAME'};
}
$AP_NOPLAT=$ENV{'AP_NOPLAT'};
$host=`hostname`; chomp $host;
$plat=`get_platform.sh -l`; chomp $plat;
$node=$usr."@".$host;

if ($AUTOPILOT eq undef) {
	print "\$AUTOPILOT not defined.\n";
	exit(0);
}
undef $ver, $bld, $scr, $rev, $order, $opt, $catcnt;
$lsknd="que";
$outfrm="norm";
$priority=".*";
$skipped="false";
$indebug="false";
$opt="false";
$ckalive="false";
$sortplat="false";
if ($AP_NOPLAT eq "false") {
	$plats="(".$node."|".$plat.")";
} else {
	$plats=$node;
}

# Read parameter
@args=@ARGV;
while (@args != undef) {
	$_=shift @args;
	if (/^-h$|^-help$/) {
			&display_help();
			exit 0;
	} elsif (/^-debug$/) {
		$indebug="true";
	} elsif (/^-o$/) {
		$order="true";
	} elsif (/^-c$|^-crr$|^crr$/) {
		$lsknd="que/crr";
	} elsif (/^-q$|^-que$|^que$/) {
		$lsknd="que";
	} elsif (/^-d$|^-done$|^done$/) {
		$lsknd="que/done";
	} elsif (/^-ap$|^ap$/) {
		$outfrm="apform";
	} elsif (/^-a$|^-all$|^all$/) {
		$plats=".*";
	} elsif (/^-count$/) {
		$outfrm="count";
	} elsif (/^-l$|^-opt$|^opt$/) {
		$opt="true";
	} elsif (/^-r$/) {
		$rev="true";
	} elsif (/^-m$/) {
		$plats=$node;
	} elsif (/^-cat$/) {
		$opt="cat";
	} elsif (/^-mp$/) {
		$plats=$plat;
	} elsif (/^-s$|^-skip$|^-skipped$/) {
		$skipped="true";
	} elsif (/^-sort$/) {
		$sortplat="true";
	} elsif (/^-so$|^-skiponly$|^-skippedonly$/) {
		$skipped="only";
	} elsif (/^-pri$|^-priority$/) {
		if ($#args < 0) {
			&display_help("'-pri' needs the second parameter as priority.");
			exit 1;
		}
		$priority=shift(@args);
	} elsif (/^-p$/) {
		if ($#args < 0) {
			&display_help("'-p' needs the second parameter as platfrom.");
			exit 1;
		}
		$plats=shift(@args);
	} elsif (/^win32$|^win64$|^winamd64$|^aix$|^aix64$|^solaris$/ 
		or /^solaris64$|^solaris.x64$|^hpux$|^hpux64$|^linux$|^linuxamd64$/
		or /^linuxx64exa$/) {
		$plats=$_;
	} elsif (/^-alive$|^alive$/) {
		$ckalive="true";
		$opt="true";
	} elsif (/.+@.+/) {
		$plats=$_;
	} else {
		if ($ver eq undef) {
			$ver=$_;
		} elsif ($bld eq undef) {
			$bld=$_;
		} elsif ($scr eq undef) {
			$scr=$_;
		} else {
			print "lstsk.pl : Too many parameters.\n";
			&display_help();
			exit 1;
		}
	}
}
$ver=".*" if $ver eq undef || $ver eq "-";
$bld=".*" if $bld eq undef || $bld eq "-";
$scr=".*" if $scr eq undef || $scr eq "-";
$lskind="que" if $skipped eq "true";
$scr=~s/ /+/g;
$scr=~s/:/\^/g;
$ver=~s/\//!/g;
if ($outfrm ne "apform") {
	$sepch="\t";
	$dStr="Disable";
	$eStr="Enable";
	$sStr="Skipped";
} else {
	$sepch="|";
	$dStr="d";
	$eStr="e";
	$sStr="s";
}
$lsknd="que" if $skipped ne "false";
if ($indebug eq "true") {
	print "ver=$ver\n";
	print "bld=$bld\n";
	print "scr=$scr\n";
	print "lsknd=$lsknd\n";
	print "plats=$plats\n";
	print "order=$order\n";
	print "outfrm=$outfrm\n";
	print "opt=$opt\n";
	print "catcnt=$catcnt\n";
	print "rev=$rev\n";
	print "skipped=$skipped\n";
	print "dStr=$dStr\n";
	print "eStr=$eStr\n";
	print "sStr=$sStr\n";
	print "sepch= <$sepch>\n";
}

$tardir=$AUTOPILOT."/".$lsknd;
if (not(-d $tardir)) {
	print "lstsk.sh : $tardir not found.\n";
	exit 2;
}

#chdir $tardir;
# Read directory information.
opendir DIRHANDLE, $tardir;
@dir=readdir DIRHANDLE;
closedir DIRHANDLE;
$reg=($lsknd eq "que") ? 
		($skipped eq "true") ?
			$priority."~".$ver."~".$bld."~.*".$scr."~".$plats."\.(tsk|tsd|tsk\.skipped)\$" :
			($skipped eq "only") ? 
				$priority."~".$ver."~".$bld."~.*".$scr."~".$plats."\.tsk\.skipped\$" :
				$priority."~".$ver."~".$bld."~.*".$scr."~".$plats."\.ts[kd]\$" :
	$ver."~".$bld."~".$scr."~".$plats."\.tsk\$";
@dir=grep(/$reg/, @dir);
if ($sortplat eq "true") {
	@dir=sort {
		@itemA=split(/~/, $a);
		@itemB=split(/~/, $b);
		@extA=split(/\./, $itemA[$#itemA]);
		@extB=split(/\./, $itemB[$#itemB]);
		$extA[0] cmp $extB[0]
	} @dir;
} else {
	@dir=sort @dir;
}

if ($rev eq "true") {
	@dir=reverse @dir;
}
if ($outfrm ne "count") {
	$dspcnt=0;
	foreach $line (@dir) {
		@items=split(/~/, $line);
		# $#items=3: crr/done format : talleyrand~0444~maxlmain.sh~aix.tsk
		# $#items=4:without order 0100~talleyrand~444~maxlmain.sh~aix.tsk
		# $#items=5:with order 0100~talleyrand~444~014~maxlmain.sh~aix.tsk
		if ($#items == 5) {
	 		if ($order eq "true") {
				$items[4]=$items[3].":".$items[4];
			}
			splice(@items, 3, 1) 
		}
		@exts=split(/\./, $items[$#items]);
		if ($exts[$#exts] eq "skipped") {
			pop(@exts); pop(@exts);
			$dmy=$sStr;
		} elsif ($exts[$#exts] =~ /ts[kd]/) {
			$dmy=pop(@exts);
			$dmy=($dmy eq "tsk") ? $eStr : $dStr;
		}
		$plnd="";
		foreach (@exts) {
			$plnd=$plnd eq "" ? $_ : $plnd."\.".$_;
		}
		$items[$#items]=$plnd;
		push(@items, $dmy);
		@ditems=();
		$skpline="false";
		my @contents=();
		foreach (@items) {
			s/\+/ /g;
			s/\!/\//g;
			s/\^/:/g;
			push(@ditems, $_);
		}
		if ($opt ne "false") {
			$sts = open FIN, $tardir."/".$line;
			if ($sts ne undef) {
				foreach (<FIN>) {
					chomp;
					$_=~s/\x0d$//g;	# For target file which is created by Windows platform.
					push @contents, $_;
				}
				close FIN;
				# Display option
				($v, $b, $s, $cont)=split(/:/, $contents[0], 4);
				push(@ditems, $cont); # task options
				# print $sepch.$cont;
				my @grepout=grep(/^On:/, @contents);
				if ($#grepout >= 0) {
					$cont=$grepout[0];
					$cont=~s/^On://g;
					if (($ckalive eq "true") && ($lsknd eq "que/crr")) {
						$lsts=`lock_ping.sh -v $AUTOPILOT/lck/$cont.reg`;
						($lsts, $dmy)=split(/ /, $lsts, 2);
						# print $sepch.$cont."(".$lsts.")";
						push(@ditems, $cont."(".$lsts.")");
						if ($lsts ne "#0") {
							$skpline="true";
						}
					
					} else {
						# print $spech.$cont;
						push(@ditems, $cont);
					}
				}
				my @grepout=grep(/^Start:/, @contents);
				if ($#grepout >= 0) {
					$cont=$grepout[0];
					$cont=~s/^Start://g;
					# print $sepch."S:".$cont;
					push(@ditems, "S:".$cont);
				}
				my @grepout=grep(/^End:/, @contents);
				if ($#grepout >= 0) {
					$cont=$grepout[0];
					$cont=~s/^End://g;
					# print $sepch."E:".$cont;
					push(@ditems, "S:".$cont);
				}
				my @grepout=grep(/^Suc:/, @contents);
				if ($#grepout >= 0) {
					$cont=$grepout[0];
					# print $sepch.$cont;
					push(@ditems, $cont);
				}
				my @grepout=grep(/^Plat:/, @contents);
				if ($#grepout >= 0) {
					$cont=$grepout[0];
					$cont=~s/^Plat://g;
					# print $sepch."P:".$cont;
					push(@ditems, "P:".$cont);
				}
				if ($opt ne "cat") {
					@contents=();
				}
			}
			
		}
		if ($skpline ne "true") {
			$flg=0;
			foreach (@ditems) {
				if ($flg != 1) {
					print $_;
					$flg=1;
				} else {
					print $sepch.$_;
				}
			}
			print "\n";
			foreach (@contents) {
				print "> ".$_."\n";
			}
			$dspcnt=$dspcnt + 1;
		}
	}
	if ($outfrm eq "norm") {
		if ($dspcnt == 0) {
			print "No tasks.\n";
		} elsif ($dspcnt == 1) {
			print "One task.\n";
		} else {
			print $dspcnt." tasks.\n";
		}
	}
} else {
	if (($lsknd eq "que/crr") && ($ckalive eq "true")) {
		$dspcnt=0;
		foreach $line (@dir) {
			$sts = open FIN, $tardir."/".$line;
			$skpline="true";
			if ($sts ne undef) {
				foreach (<FIN>) {
					chomp;
					$_=~s/\x0d$//g;	# For target file which is created by Windows platform.
					push @contents, $_;
				}
				close FIN;
				my @grepout=grep(/^On:/, @contents);
				if ($#grepout >= 0) {
					$cont=$grepout[0];
					$cont=~s/^On://g;
					$lsts=`lock_ping.sh -v $AUTOPILOT/lck/$cont.reg`;
					($lsts, $dmy)=split(/ /, $lsts, 2);
					if ($lsts eq "#0") {
						$skpline="false";
					}
				}
			}
			if ($skpline ne "true") {
				$dspcnt=$dspcnt + 1;
			}
		}
		print $dspcnt."\n";
	} else {
		print ($#dir + 1);
		print "\n";
	}
}


print "reg=[$reg]\n" if $indebug eq "true";

#        1         2         3         4         5         6         7
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
__END__
List tasks in the task queue or done/current buffer.

Syntax:
  lstsk.pl [que|crr|done] [<options>] [<plat>|<node>] [<ver> [<bld> [<scr>]]]

Parameters:
  <plat> : Platform to display.
           win, win64, winamd64, aix, aix64, solaris, solaris64, hpux, hpux64,
           linux, linux64 and all or -a.
  <node> : the specifc node to display. <node>:=<user>@<hostname>.
           Note: When you skip <plat> or <node> parameter, this command uses
                 "(<crrusr>@<crrhost>|<crr-platform>)" for the target.
  <ver>  : Version number to list. You can use '-' for all versions.
  <bld>  : Build number to list. You can use '-' for all builds.
  <scr>  : Script name to list. You can use '-' for all scripts.
  que    : List waiting tasks in the task queue.(Default)
  crr    : List currently executing tasks.
  done   : List done tasks.

<Options>:
  -h     : Display help.
  -o     : Display script order.
  -l     : Display task options.
  -ap    : Display AP format.
  -r     : Display tasks in reverse order.
  -m     : Current node.
  -mp    : Current platform.
  -count : Display count only.
  -cat   : Display task file contents.
  -pri <pri>    : List specific tasks which have the specified <pri> priority.
  -p <plats>    : Define listed platforms or nodes.(in perl reg exp syntax).
  -d|-done|done : List done tasks.
  -c|-crr|crr   : List current executing tasks.
  -q|-que|que   : List waiting tasks in the task queue.
  -a|-all|all   : List all task files.
  -l|-opt|opt   : Display task options.
  -debug : Display debug informations.
  -s|-skip|-skipped          : Display skipped task alse.
  -so|-skiponly|-skippedonly : Display skipped task only.
  -alive : Check the task is alive or not when target is que/crr
  -sort  : Sort output with the platform or node.
  Note: When you use "skipped task" option, the target queue kind is set to 
        "que" forcibly.
