#!/usr/bin/perl
#################################################################
# file name:   pstree.pl
# Auther:      Yukio Kono
# Description: Display processes in a tree format or Kill
#             processes using a tree hirarchy.
# History #######################################################
# 2010/08/25 YKono  Display all processes under the ingore
#                   process with protect mark.
#                   This command define itself and it's parent
#                   as a protected process, won't kill.
#                   In this change, -kill command won't kill
#                   the children processes from marked as ignore/
#                   protected process.
# 2010/09/09 YKono  Add -x option on HP-UX.
# 2010/09/10 YKono  Use UCB version of ps command on Solaris.
# 2010/09/27 YKono  Fix -i problem. (Same level process also got 
#                   -i effect)
# 2011/02/04 YKono  Add -showall option and hide pstree.pl related
#                   processes.
# 2013/04/05 YKono  Support Solaris Sparc 64 on Exalytics
#################################################################
# Initial value
$usr=$ENV{'LOGNAME'};
$plat=`uname`; chomp $plat;
$form="user,pid,ppid,args";
$who=($plat eq "Windows_NT") ? "" : "-u $usr";
$ind=0;
$tmp=`ps -p $$ -f | tail -1`;
$tmp=~s/^\s+//g;
($dmy1, $mypid, $myppid, $dmy3)=split(/\s+/, $tmp, 4);
$hide="true";	# 2011/02/04 YK

#################################################################
# Read parameter
@args=@ARGV;
undef $stpoint;
undef $kill;
while (@args != undef) {
	$_=shift @args;
	if (/^-h$|^-help$/) {
			&display_help();
			exit 0;
	} elsif (/^-showall$/) {	# 2011/02/04 YK
		$hide="false";
	} elsif (/^-a$|^all$|^-all$/) {
		$who="-e";
	} elsif (/^-i$|^-ign$/) {
		if ($#args < 0) {
			&display_help("'-ign' needs the second parameter as protect PID.");
			exit 1;
		}
		$ignpid=(defined($ignpid)) ? $ignpid." ".shift(@args) : shift(@args);
	} elsif (/^-kill$/) {
		$kill="true";
	} elsif (/^-u$/) {
		if ($#args < 0) {
			&display_help("'-u' needs the second parameter as user.");
			exit 1;
		}
		$usr=shift(@args);
		$who="-u $usr";
	} else {
		$stpoint=$_;
	}
}

#################################################################
### Main
#################################################################

# Get process list
if ($plat eq "HP-UX") {
	@procs=`export UNIX95=;export PATH=/usr/bin/xpg4:\$PATH;ps -x $who -o $form`;
} elsif ($plat eq "Windows_NT") {
	@procs=`ps $who -o $form`;
} elsif ($plat eq "SunOS") {
	if (-x "/usr/ucb/ps") {
		@ucbps=`/usr/ucb/ps auxwww`;
	} else {
		@ucbps=`ps auxwwww`;
	}
	$dmy=shift(@ucbps);
	%lngps=();
	foreach $k (@ucbps) {
		chomp $k;
		($usr, $pid, $k)=split(/[ \t]+/, $k, 3);
		$k=~s/^.* [0-9][0-9]*:[0-9][0-9]* *//;
		$lngps{$pid}={ 'args'=>$k };
		# print "#U $usr, $pid, $k\n";
	}
	@procs=`ps $who -o $form`;
} else { # Other UNIX
	@procs=`ps $who -o $form`;
}

$dmy=shift(@procs);	# Drop column header like PID  PPID USER...
%psh=();
foreach $k (@procs) {
	chomp $k;
	$k=~s/^[ \t]+//;
	($usr, $pid, $ppid, $args)=split(/[ \t]+/, $k, 4);
	$ppid=undef if $pid==$ppid;
	if ($args ne "_Total") {
		#if ($plat eq "SunOS") {
		#	my $ret=&sun_ps($pid);
		#	$args=">".$ret if $ret ne "";
		#}
		$args=$lngps{$pid}->{'args'} if $plat eq "SunOS" && exists $lngps{$pid};
		$psh{$pid}={ 'pid'=>$pid, 'ppid'=>$ppid,
			'usr'=>$usr, 'args'=>$args, 
			'ch'=>undef, 'next'=>undef, 'prev'=>undef};
		# print "# $pid, $ppid, $usr, $args\n";
	}	
}

@rootlvl=();
foreach $k (keys(%psh)) {
	$ppid=$psh{$k}->{'ppid'};
	if ( exists $psh{$ppid}) {
		if ( $psh{$ppid}->{'ch'} == undef ) {
			$psh{$ppid}->{'ch'} = $k;
		} else {
			$crrpid=$psh{$ppid}->{'ch'};
			while ( $psh{$crrpid}->{'next'} != undef ) {
				$crrpid=$psh{$crrpid}->{'next'};
			}
			$psh{$crrpid}->{'next'}=$k;
			$psh{$k}->{'prev'}=$crrpid;
		}
	} else {
		$psh{$k}->{'ppid'}="<none>";
		push(@rootlvl, $k);
	}
# print "## $psh{$k}->{'pid'}, $psh{$k}->{'ppid'}, $psh{$k}->{'usr'}, $psh{$k}->{'args'}\n";
}
# print "myid=$mypid, ign=$ignpid\n";

if ($stpoint == undef) {
	if ($kill eq "true") {
		print "pstree.pl : -kill option without <pid> is not allowed.\n";
	} else {
		foreach $one (@rootlvl) {
			&disp_tree($one, 0);
		}
	}
} elsif (exists($psh{$stpoint})) {
	&disp_tree($stpoint, 0);
} else {
	print "Process $stpoint is not exists.\n";
}
exit(0);

#################################################################
### Sub rutines
#################################################################

#################################################################
# Display sub

sub disp {
	#        norm  prtct ign  me   parent
	my @mchr=( '', '-',  '*', '@', '^' );
	my ($st, $prot)=@_;
	for (my $i=0; $i<$ind; ++$i) {
		print "  ";
	}
	print $mchr[$prot].$psh{$st}->{'pid'}." ".$psh{$st}->{'ppid'}." ".
		$psh{$st}->{'usr'}." ".$psh{$st}->{'args'}."\n";
	if ($kill eq "true" && $prot == 0) {
		`kill -9 $psh{$st}->{'pid'} > /dev/null 2>&1`
	}
}

#################################################################
# Display each prcesses by tree format

sub disp_tree1 {
	my ($st, $pprot)=@_;
	my $prot=($st == $mypid) ? 3 : 
		($ignpid =~ /\b$st\b/) ? 2 :
		($st == $myppid) ? 4 : 
		($pprot != 0) ? 1 : 0;
	if ($hide eq "false" || $prot == 0 || $prot == 4 || $prot == 1) {
		&disp($st, $prot);
		if ($psh{$st}->{'ch'} != undef) {
			++$ind;
			&disp_tree1($psh{$st}->{'ch'}, $prot);
			--$ind;
		}
	}
	if ($psh{$st}->{'next'} != undef) {
		&disp_tree1($psh{$st}->{'next'}, $pprot);
	}
}

#################################################################
# Display root level by tree format

sub disp_tree {
	my ($st, $prot)=@_;
	$prot=($st == $mypid) ? 3 : 
		($ignpid =~ /\b$st\b/) ? 2 :
		($st == $myppid) ? 4 : 
		($prot != 0) ? 1 : 0;
	if ($hide eq "false" || $prot == 0 || $prot == 4 || $prot == 1) {
		&disp($st, $prot);
		if ($psh{$st}->{'ch'} != undef) {
			++$ind;
			&disp_tree1($psh{$st}->{'ch'}, $prot);
			--$ind;
		}
	}
}

#################################################################
# Display help.

sub display_help()
{
	if ($#_ >= 0) {
		($mes)=@_;
		print "pstree.pl : $mes\n";
	}
	print $_ foreach(<DATA>);
}

#        1         2         3         4         5         6         7
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
__END__
List or kill processes in a tree format.

Syntax:
  pstree.pl [<options>] [<pid>...]

Parameters:
  <pid>    : Process ID to list.

Options:
  -h       : Display help.
  -u <usr> : Display <usr>'s processes.
  -all     : Display all user's processes.
  -i <pid> : Ignore process ID.
  -kill    : Kill proccess start from specific <pid>.
  -showall : Display pstree.pl process it self
Note:
  This tool automatically add itself and it's parent to ignore processes.
  Those ignore process will be displayed with following characgters.
  *<pid> : Ignore target process.
  ^<pid> : Parent process of pstree.pl.
  @<pid> : pstree.pl process.
  -<pid> : Children processes of the ignore porcesses.
  Sample:
    $> pstree.pl -i 4063
    *4063 <none> regrrk1 /usr/bin/ksh delegated.sh
      -2399 4063 regrrk1 sleep 1
    4073 <none> regrrk1 /usr/bin/ksh keep_lock.sh
      2407 4073 regrrk1 sleep 1
    9497 <none> regrrk1 -ksh
    ^17925 <none> regrrk1 -ksh
      @2408 17925 regrrk1 /usr/bin/perl pstree1.pl -i 4063
        -2413 2408 regrrk1 sh -c export UNIX95=;export PATH=/usr/bin/xpg4:$PATH
          -2414 2413 regrrk1 ps -u regrrk1 -o user,pid,ppid,comm,args
