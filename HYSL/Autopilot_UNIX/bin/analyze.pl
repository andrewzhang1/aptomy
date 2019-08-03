#!/usr/bin/perl
# analyze.sh <sog base> [<dif db> <ign sh>]
# in:  <sog base> script base name for .sog file
#      <dif db>   diff and script match database file
#      <ign sh>   Script list file for ignore
# out: 1 = no <sog base> parameter
#      2 = <sog base>.sog not found.
# History:
#  ...
# 2012/04/11 Fix different date format form SXR output.

use Time::Local qw(timelocal);

($sta, $difdbf, $ignshf)=@ARGV;

if ( $sta.sta eq "" ) {
	print "### No sta base file name.\n";
	exit 1;
}

if ( ! -e "$sta.sta" ) {
	print "### There is no $sta.sta file.\n";
	exit 2;
}

# Read diff script mapping database
# Usually it is in $AUTOPILOT/data/dif_script.txt
%difdb=(); # clear hash
if ( $difdbf ne "" ) {
	if (! -e "$difdbf" ) {
		print "### No $difdbf file.\n";
	} else {
		open DBFILE, "$difdbf";
		while ($input = <DBFILE>) {
			chomp $input;
			if (( $input !~ /^#/) && ($input !~ /^$/)) {
				($df, $sc)=split(/[ \t]/, $input, 2);
				$difdb{$df}=$sc;
			}
		}
		close DBFILE;
		#foreach $k ( keys(%difdb)) {		# debug print
		#	print "DIFF $k -> $difdb{$k}\n";	# debug print
		#}								# debug print
	}
}

# Read ignore script mapping database
# Usually it is in $AUTOPILOT/data/ignoresh.txt
%ignsh=(); # clear hash
if ( $ignshf ne "" ) {
	if (! -e "$ignshf" ) {
		print "### No $ignshf file.\n";
	} else {
		open IGNSH, "$ignshf";
		while ($input = <IGNSH>) {
			chomp $input;
			if (( $input !~ /^#/) && ($input !~ /^$/)) {
				$ignsh{$input}="yes";
			}
		}
		close IGNSH;
		#foreach $k ( keys(%ignsh)) {		# debug print
		#	print "IGN $k -> $ignsh{$k}\n";	# debug print
		#}								# debug print
	}
}

# Clear line array
@lines=();

# Make dif timestamp record
$difcnt=0;
if (! -e "$sta.sog" ) {
	print "### No $sta.sog file.\n";
	print "### Use file time stamp for the dif analyze.\n";

	# Check diff time stamp from file time stamp.
	foreach $diffile (<*.dif>) {
		$difcnt++;
		($sc,$mi,$hr,$dy,$mo,$yr,$wdy,$ydy,$dst)=localtime((stat($diffile))[9]);
		$tmp=sprintf("%04d%02d%02d %02d%02d%02d %s %s%s", 
			$yr+1900,$mo+1,$dy,$hr,$mi,$sc,
			exists $difdb{$diffile} ? "DB" : "DF",
			$diffile, 
			exists $difdb{$diffile} ? " $difdb{$diffile}" : "");
		# print "TimeStamp: $tmp\n";	# debug print
		push(@lines, $tmp);
	}
} else {	# Make diff time stamp from .sog file.
	# Month hash
	%mname=( Jan => 1, Feb => 2, Mar => 3, Apr => 4,
			May => 5, Jun => 6, Jul => 7, Aug => 8,
			Sep => 9, Oct => 10, Nov => 11, Dec => 12,
			January => 1, February => 2, March => 3, April => 4,
			June => 6, Jully => 7, August => 8,
			Septempber => 9, October => 10, November => 11, December => 12 );
	# Read .sog file
	open SOG, "$sta.sog";
	@sog=<SOG>;
	close SOG;
	# Make dif line file from .sog file.
	@sxrdif=`egrep -n "\\++ sxr diff" $sta.sog`;
	# Make dif line number hash.
	%difrec=();
	foreach $item (@sxrdif) {
		chomp $item;
		($n, $dmy)=split(/:/, $item, 2);
		while ( $item =~ /\\$/ ) {
			$item="$item $sog[$n]";
			chomp $item;
			$n++;
		}
		@dmy=split(/ /, $item);
		$fnm=$dmy[$#dmy - 1];
		@dmy2=split(/\./, $fnm);
		$ext=$dmy2[$#dmy2];
		$fnm=~ s/\.[^.]+$//;
		undef @dmy2;		
		# print "DREC $item\nDREC $fnm, $ext, $n\n";	# debug print
		if ( ($fnm =~ /[\\\/\[\]=*:+\?\$]/) || ($ext =~ /[\\\/\[\]=*:+\?\$]/ ) 
			|| ($fnm eq "") || ($ext eq "") || ($fnm eq $dmy[$#dmy-1]) ) {
			$fnm=$dmy[$#dmy];
			$fnm =~ s/\.[^.]+$//;
		}
		undef @dmy;
		$difrec{$fnm}=$n;
	}
	undef @sxrdif;
	# Print difrec hash.
	# foreach $key (keys(%difrec)) {			# debug print
	# 	print "DifRec $key=$difrec{$key}\n";	# debug print
	# }									# debug print

	# Check diff time stamp from .sog file
	foreach $diffile (<*.dif>) {
		$difcnt++;
		$tmp=$diffile;
		$tmp=~ s/\.[^.]+$//;
		if ( exists $difrec{$tmp} ) {
			$n=$difrec{$tmp};
			$_=$sog[$n];
			#($dm1, $dm2, $dm3, $dm4, $dm5, $dm6, $dm7,
			#	$mo, $dy, $tm, $dm11, $yr)=split /[ \t]+/;
			@dm=split /[ \t]+/;
			$mo=$dm[7];
			$dy=$dm[8];
			if ($dy =~ /,/) {
				$dy=~s/\,//;
			}
			if ( $dm[9] =~ /:/) {
				$tm=$dm[9];
				$yr=$dm[11];
				$hrofs=0;
			} else {
				$tm=$dm[10];
				$yr=$dm[9];
				$hrofs=($dm[11] eq "PM") ? 12 : 0;
			}
			# There are two format of time stamp like below:
			# 0   1       2    3 4          5  6        7     8   9        10       11    12
			# +++ Essexer 2.20 - Production on Tuesday, April 9,  2013     06:30:39 AM    PDT
			# ++  Essexer 2.20 - Production on Mon      Apr   8   10:59:34 PDT      2013
			$yr -= 1900;
			$mo = $mname{$mo} - 1;
			($hr, $mi, $sc)=split(/:/, $tm);
			$hr += $hrofs;
		} else {
			($sc,$mi,$hr,$dy,$mo,$yr,$wdy,$ydy,$dst)=localtime((stat($diffile))[9]);
			$diffile="$diffile";
		}
		$tmp=sprintf("%04d%02d%02d %02d%02d%02d 000000 %s %s%s", 
			$yr+1900,$mo+1,$dy,$hr,$mi,$sc,
			exists $difdb{$diffile} ? "DB" : exists $difrec{$tmp} ? "DF" : "DF",
			$diffile, 
			exists $difdb{$diffile} ? " $difdb{$diffile}" : "");
		# print "SOG $tmp\n";	# debug print
		push(@lines, $tmp);
	}
	undef @sog;
	undef %difrec;
}

# printf("difcnt=%s\n", $difcnt);	# debug print
# print "======\n";	# debug print

# Make script time stamp record.
$sts=open STAFILE, "$sta.sta";
$serialcnt=0;
@scrlvl=();
$prevtm="";
if ( $sts ne undef) {
	while ($input=<STAFILE>) {
		chomp($input);
		#if ($input =~ /\+ FAILED DIFF/ ) {
		#	($dmy, $lvl, $dmy1, $dmy2, $sh, $rst)=split(/[ \t]+/, $input, 5);
		#	$tmp=sprintf(
		#		"%s %06d DIFF %s",
		#		$prevtm,$serialcnt, $sh);
		# 	$serialcnt++;
		# 	push(@lines, $tmp);
		# } elsif ($input =~ /^\+/) {
		if ($input =~ /^\+/) {
			($lvl, $sh, $tm, $dt, $dm, $ep, $dm2)=split(/[ \t]+/, $input);
			($dm, $hr, $mi, $se)=split(/:/, $tm);
			($yr, $mo, $dy)=split(/_/, $dt);
			if ( ! exists $ignsh{$sh} ) {
				if ( "$dt" eq "Elapsed" ) {
					$tmp=pop(@scrlvl);
					($sc,$mi,$hr,$dy,$mo,$yr,$wdy,$ydy,$dst)=
						localtime($tmp+$ep);
					$yr += 1900;
					$mo++;
					$kd="ED";
				} else {
					$yr+=2000;
					$tmp=timelocal($se,$mi,$hr,$dy,$mo-1,$yr);
					push(@scrlvl, $tmp);
					$kd="BG";
				}
				$tmp=sprintf(
					"%04d%02d%02d %02d%02d%02d %06d %s %s",
					$yr,$mo,$dy,$hr,$mi,$se,$serialcnt, $kd, $sh);
				$prevtm=sprintf(
					"%04d%02d%02d %02d%02d%02d",
					$yr,$mo,$dy,$hr,$mi,$se);
				# print "<$tmp>\n";	# debug print
				$serialcnt++;
				push(@lines, $tmp);
			}
		}
	}
	close STAFILE;
}

@sortlines=sort @lines;
undef @lines;
@scrlvl=();

# Print sorted result.
# print "======\n";			# debug print
# foreach $item (@sortlines) {	# debug print
# 	print ">$item\n";		# debug print
# }							# debug print

$firstShell="";
foreach $item (@sortlines) {
	($dt, $tm, $ct, $kd, $sh, $scr)=split(/ /, $item, 6);
	if ( $kd eq "BG" ) {
		push(@scrlvl, $sh);
		$firstShell=$sh if ($firstShell eq "");
		next;
	} elsif ( $kd eq "ED" ) {
		pop(@scrlvl);
		next;
	} elsif ( $kd eq "DF" ) {
		$scr="";
		foreach $i (@scrlvl) {
			$scr= $scr eq "" ? $i : "$scr $i";
		}
	} elsif ( $kd eq "DIFF" ) {
		next;
	}
	if ( $scr eq "" ) {
		print "$sh\t$firstShell\n";
	} else {
		print "$sh\t$scr\n";
	}
}

exit(0);

