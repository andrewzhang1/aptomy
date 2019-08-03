#!/usr/bin/perl
# 2014/01/31 YKono Bug 18091128 - DIR COMP CHECKS THE LIB VERSION

#################################################################
# Initial value
			
#################################################################
# Read parameter
@args=@ARGV;
undef $srcfile;
undef $trgfile;
$igndir="false";
while (@args != undef) {
	$_=shift @args;
	if (/^-h$|^-help$/) {
			&display_help();
			exit 0;
	} elsif (/^-igndir$/) {
			$igndir="true";
	} else {
		if (!defined($srcfile)) {
			$srcfile=$_;
		} elsif (!defined($trgfile)) {
			$trgfile=$_;
		} else {
			&display_help("Too many parameters.");
			exit 1;
		}
	}
}

#################################################################
### Main
#################################################################

if (!defined($srcfile) || !defined($trgfile)) {
	&display_help("Not enough parameter.");
	exit 1;
}

if (! -f $srcfile ) {
	print "$srcfile not found.\n";
	exit 2;
}

if (! -f $trgfile ) {
	print "$trgfile not found.\n";
	exit 3;
}

#################################################################
# Read souce base file

undef @src, @trg;
open(SRC, "<$srcfile");
while (<SRC>) {
	chomp $_;
	if (!/^#|^$/) {
		undef @d, $sz, $fn, $ck, $dt, $at, $gl;
		$al=0;
		($l1, $l2)=split(/#/, $_, 2);
		$l1=~s/^\s+//g; $l1=~s/\s+$//g;
		$l2=~s/^\s+//g; $l2=~s/\s+$//g;
		@d=split(/\s+/, $l1);
		$sz=$d[$#d];
		$fn=substr($l1, 0, length($l1) - 1 - length($sz));
		if ($sz =~ /%/) {
			($sz, $al)=split(/%/, $sz, 2);
			$al=20 if ($al eq "");
		}
		if ($l2 ne "") {
			foreach (split(/\s+/, $l2)) {
				if (/_/) {
					$dt=$_;
				} elsif (/^[0-9]+$/) {
					$ck=$_;
				} elsif (/^glibcxx\(/) {
					$gl=$_;
					$gl=~s/^glibcxx\(//g;
					$gl=~s/\)*$//g;
				} elsif (/^[-a-zA-Z]+$/) {
					$at=$_;
				}
			}
		}
		push (@src, {'name'=>$fn, 'size'=>$sz, 'allow'=>$al, 'cksum'=>$ck,
			'date'=>$dt, 'attr'=>$at, 'glibcxx'=>$gl, 'org'=>$_ });
	}
}
close(SRC);

#################################################################
# Read target size files
open(TRG, "<$trgfile");
while (<TRG>) {
	chomp $_;
	if (!/^#|^$/) {
		undef @d, $sz, $fn, $ck, $dt, $at, $gl;
		$al=0;
		($l1, $l2)=split(/#/, $_, 2);
		$l1=~s/^\s+//g; $l1=~s/\s+$//g;
		$l2=~s/^\s+//g; $l2=~s/\s+$//g;
		@d=split(/\s+/, $l1);
		$sz=$d[$#d];
		$fn=substr($l1, 0, length($l1) - 1 - length($sz));
		if ($sz =~ /%/) {
			($sz, $al)=split(/%/, $sz, 2);
			$al=20 if ($al eq "");
		}
		if ($l2 ne "") {
			foreach (split(/\s+/, $l2)) {
				if (/_/) {
					$dt=$_;
				} elsif (/^[0-9]+$/) {
					$ck=$_;
				} elsif (/^glibcxx\(/) {
					$gl=$_;
					$gl=~s/^glibcxx\(//g;
					$gl=~s/\)*$//g;
				} elsif (/^[-a-zA-Z]+$/) {
					$at=$_;
				}
			}
		}
		push (@trg, {'name'=>$fn, 'size'=>$sz, 'allow'=>$al, 'cksum'=>$ck,
			'date'=>$dt, 'attr'=>$at, 'glibcxx'=>$gl, 'org'=>$_ });
	}
}
close(TRG);

#################################################################
# Debug print
=pod
my $i=0;
foreach $item (@src) {
	print "$i:$item->{'name'}, $item->{'size'}($item->{'allow'}),".
		" ck=$item->{'cksum'}, dt=$item->{'date'}, at=$item->{'attr'}, glibcxx=$item->{'glibcxx'}\n";
	++$i;
}
print "Src lines=$#src\n";
print "Trg lines=$#trg\n";
=cut

#################################################################
# Comparison
undef $keepdir;
@src=sort {$a->{'name'} <=> $b->{'name'}} @src;
@trg=sort {$a->{'name'} <=> $b->{'name'}} @trg;

while ($#src != -1 && $#trg != -1) {
	if ($igndir eq "true" && $src[0]->{'size'} eq "<dir>") {
		shift @src;
	} elsif ($igndir eq "true" && $trg[0]->{'size'} eq "<dir>") {
		shift @trg;
	} else {
		my $sts=$src[0]->{'name'} cmp $trg[0]->{'name'};
		if ($sts == 0) {
			my $tmp, $opt;
			undef($tmp); undef($opt);
			if ($src[0]->{'size'} ne $trg[0]->{'size'}) {
				if ($src[0]->{'size'} eq "<dir>" || $trg[0]->{'size'} eq "<dir>") {
					$tmp=$src[0]->{'size'}." -> ".$trg[0]->{'size'};
				} else {
					if ($src[0]->{'allow'} != 0) {
						$allowvar=int($src[0]->{'size'} * $src[0]->{'allow'} / 100);
						$szvar=abs($src[0]->{'size'} - $trg[0]->{'size'});
						if ($allowvar < $szvar) {
							$tmp=$src[0]->{'size'}." -> ".$trg[0]->{'size'}.
								"(allow=".$allowvar.
								",variance=".$szvar.
								",ratio=".$src[0]->{'allow'}."%)";
						}
					} else {
						$tmp=$src[0]->{'size'}." -> ".$trg[0]->{'size'};
					}
				}
			}
			if (defined($src[0]->{'cksum'})) {
				if ($src[0]->{'cksum'} ne $trg[0]->{'cksum'}) {
					$opt="cksum(".$src[0]->{'cksum'}." -> ".$trg[0]->{'cksum'}.")";
				}
			}
			if (defined($src[0]->{'date'})) {
				if ($src[0]->{'date'} ne $trg[0]->{'date'}) {
					$opt=defined($opt) ? 
						$opt.", date(".$src[0]->{'date'}." -> ".$trg[0]->{'date'}.")" : 
						"date(".$src[0]->{'date'}." -> ".$trg[0]->{'date'}.")";
				}
			}
			if (defined($src[0]->{'attr'})) {
				if ($src[0]->{'attr'} ne $trg[0]->{'attr'}) {
					$opt=defined($opt) ? 
						$opt.", attr(".$src[0]->{'attr'}." -> ".$trg[0]->{'attr'}.")" : 
						"attr(".$src[0]->{'attr'}." -> ".$trg[0]->{'attr'}.")";
				}
			}
			if (defined($src[0]->{'glibcxx'})) {
				if ($src[0]->{'glibcxx'} ne $trg[0]->{'glibcxx'}) {
					$opt=defined($opt) ? 
						$opt.", glibcxx(".$src[0]->{'glibcxx'}." -> ".$trg[0]->{'glibcxx'}.")" : 
						"glibcxx(".$src[0]->{'glibcxx'}." -> ".$trg[0]->{'glibcxx'}.")";
				}
			}
			if (defined($opt)) {
				$opt=" # ".$opt;
				 if (!defined($tmp)) {
					$tmp= ($src[0]->{'size'} ne $trg[0]->{'size'})  ?
						(
							$src[0]->{'size'}.(
								$src[0]->{'allow'} != 0 ?
								 	"(".$src[0]->{'allow'}."%)" : 
									""
							)." -> ".$trg[0]->{'size'}."(OK)"
						) : $src[0]->{'size'}
						
				}
			}
			if (defined($tmp)) {
				print "c - ".$src[0]->{'name'}." ".$tmp.$opt."\n";
				undef $keepdir
			}
			shift @src;
			shift @trg;
		} elsif ($sts < 0) {	# Case of src is deleting
			&ad_disp("d < ", $src[0]);
			# print "d < $src[0]->{'org'}\n";
			shift @src;
		} else {				# Case of trg is adding
			&ad_disp("a > ", $trg[0]);
			# print "a > $trg[0]->{'org'}\n";
			shift @trg;
		}
	}
}

# Flush rest of srouce
if ($#src != -1) {
	foreach (@src) {
		&ad_disp("d < ", $_);
		# print "d < ".$_->{'org'}."\n";
	}
}

# Flush rest of srouce
if ($#trg != -1) {
	foreach (@trg) {
		&ad_disp("a > ", $_);
		# print "a > ".$_->{'org'}."\n";
	}
}

exit(0);

#################################################################
### Sub rutines
#################################################################

sub ad_disp()
{
	if (defined($keepdir)) {
		if ($_[1]->{'name'} !~ /^${keepdir}.*/) {
			print $_[0].$_[1]->{'org'}."\n";
			if ($_[1]->{'size'} eq "<dir>") {
				$keepdir=$_[1]->{'name'};
			} else {
				undef $keepdir;
			}
		}
	} else {
		if ($_[1]->{'size'} eq "<dir>") {
			$keepdir=$_[1]->{'name'};
		}
		print $_[0].$_[1]->{'org'}."\n";
	}
}

#################################################################
# Display help.

sub display_help()
{
	if ($#_ >= 0) {
		($mes)=@_;
		print "filesize.pl : $mes\n";
	}
	print $_ foreach(<DATA>);
}

#        1         2         3         4         5         6         7
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
__END__
Compare size files and display difference

SYNTAX:
  sizediff.pl [-h|-igndir] <src> <trg>

PARAMETER:
  <src>   : Base Size file for the comparison
  <trg>   : Target Size file for the comparison
  -h      : Display help.
  -igndir : Ignore directory entry.
   If there is differetia between <src> and <trg> file,
   This script display following informations:
   1. Newly added to <trg>. (Not in <src>)
     a> <file path> <file size>
   2. Deleted in <trg>. (Exist in <src>, but not in <trg>
     d< <file path> <file size>
   3. Change the file size.
     c - <file path> <src file size> -> <trg file size>


  
