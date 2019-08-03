#!/usr/bin/perl
# History:
# 2013/11/15 YKono Bug 17806229 - FILESIZE.PL ENTER INFINITY LOOP WHEN EXECUTED BY PERL 5.16.3 
# 2014/01/31 YKono Bug 18091128 - DIR COMP CHECKS THE LIB VERSION

#################################################################
# Initial value
$cksum="false";
$date="false";
$attr="false";
$igndir="false";
$ignptn=undef;
$dynp=20;
$dynptn=undef;
# $whichdate=`which date`;
# $crryear=`date +%Y`; chomp $crryear;
($d1, $d2, $d3, $d4, $d5, $crryear, $d7, $d8, $d9) = localtime();
$crryear += 1900;
%monstr=(	Jan=>"01", Feb=>"02", Mar=>"03", Apr=>"04",
			May=>"05", Jun=>"06", Jul=>"07", Aug=>"08",
			Sep=>"09", Oct=>"10", Nov=>"11", Dec=>"12" );
			
#################################################################
# Read parameter
@args=@ARGV;
undef(@loclist);
while (@args != undef) {
	$_=shift @args;
	if (/^-h$|^-help$/) {
			&display_help();
			exit 0;
	} elsif (/^-cksum$/) {
		$cksum="true";
	} elsif (/^-date$/) {
		$date="true";
	} elsif (/^-attr$/) {
		$attr="true";
	} elsif (/^-igndir$/) {
		$igndir="true";
	} elsif (/^-ign$/) {
		if ($#args < 0) {
			&display_help("'-ign' needs the ignore pattern.");
			exit 1;
		}
		$ignptn=shift(@args);
	} elsif (/^-dyn$/) {
		if ($#args < 0) {
			&display_help("'-dyn' needs the dynamic pattern.");
			exit 1;
		}
		$dynptn=shift(@args);
	} elsif (/^-dynper$|^-dynp$/) {
		if ($#args < 0) {
			&display_help("'-dynp' needs the dif percentage.");
			exit 1;
		}
		$dynp=shift(@args);
		if ($dynp !~ /^[0-9]+$/) {
			&display_help("The percentage parameter should be decimal.");
			exit 1;
		}
	} elsif (!/^$/) {
		push(@loclist, $_);
	}
}

#################################################################
### Main
#################################################################

# -rwxrwxrwa   1 Administrators  HYPERIONAD\sxrdev   16925 Oct 15 10:04 sh_histo
# -rwxrwxrwa   1 Administrators  HYPERIONAD\sxrdev      38 Apr  2  2008 tstenv
undef @dir;
foreach $oneloc (@loclist) {
	$targ=`echo $oneloc`; chomp $targ;
	if (-d $targ) {
		$oneloc=~s/\$//g;
		$crrdir=$oneloc;
		$crrdir2=$targ;
		foreach $one (`ls -lRp $targ`) {
			chomp $one;
			if ($one=~/:$/) {
				$crrdir2=$one;
				$crrdir2=~s/:$//g;
				$one=~s/^$targ/$oneloc/;
				$one=~s/:$//g;
				$crrdir=$one;
			} elsif ($one !~ /^total/ && $one !~ /^$/) {
				($attrb, $dmy, $usr, $grp, $siz, $mm, $dd, $ytim, $fname)=split(/[ 	]+/, $one, 9);
				$str="$crrdir/$fname";
				next if (defined($ignptn) && $str =~ /$ignptn/);
				if ($fname !~ /\/$/) {
					if (defined($dynptn) && $str =~ /$dynptn/) { # Check dynamic file
						$str=($dynp == 20) ? $crrdir."/".$fname." ".$siz."%" 
										  : $crrdir."/".$fname." ".$siz."%".$synp;
					} else {
						$str=$crrdir."/".$fname." ".$siz;
					}
				} else { # Directory name
					next if ($igndir eq "true");
					$str="$crrdir/$fname <dir>";
				}
				undef $glibver;
				if ($^O eq "linux" && $crrdir eq "ARBORPATH/bin" && 
				     ($fname =~ /^ESS/ || $fname =~ /^lib/ || $fname eq "essmsh")) {
					$glibver=`objdump -x '$crrdir2/$fname' 2> /dev/null | grep GLIBCXX_ | while read line; do echo \${line##*GLIBCXX_}; done | sort | tail -1`;
					chomp $glibver;
				}
				$str="$str #" if ($cksum eq "true" || $date eq "true" || $attr eq "true" || $glibver);
				$dd="0$dd" if ($dd < 10);
				if ($cksum eq "true") {
					if ($fname !~ /\/$/) {
						if ($fname =~ /->/) {
							($fname, $dmy)=split(/\s+/, $fname, 2);
						}
						$ckval=`cksum '$crrdir2/$fname' 2> /dev/null`;
						($ckval, $dmy)=split(/\s+/, $ckval, 2);
					} else {
						$ckval="---";
					}
					$str=$str." ".$ckval;
				}				
				if ($date eq "true") {
					$mm=$monstr{$mm};
					if ($ytim !~ /:/) {
						$year=$ytim;
						$ytim="00:00"
					} else {
						$year=$crryear;
					}
					$str=$str." ".$year."/".$mm."/".$dd."_".$ytim;
				}
				if ($attr eq "true") {
					$str="$str $attrb";
				}
				$str="$str glibcxx($glibver)" if ($glibver);
				push @dir, $str;
			}
		}
	}
}
# print "IgnPtn:<".$ignptn.">\n";
# print "DynPtn:<".$dynptn.">\n";
@dir=sort @dir;
foreach (@dir) { print "$_\n"; }

exit(0);

#################################################################
### Sub rutines
#################################################################


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
Make file size list under the specified path.
SYNTAX: 
filesize.pl [-cksum|-lower|-date|-attr|<newopt>] <path> [<path>...]
INPUT:
 -cksum : Add cksum value
 -date  : Add date stamp 
 -attr  : Add file/dir attribute
 -lower : Make all alphabet in lower case.
 <path> : The folder location for making a size file.
          Note: If you define <path> with $ARBORPATH,
                This script output exact path for it
                like below:
                  C:/Hyp/products/essbase/EssbaseServer/bin/ESSBASE.EXE 22222
                  ...
                This might be problem when you compare
                with base file.
                So, if you don't want this kind of output,
                please use \$ARBORPATH for the <path>.
                Then this script create following output:
                  ARBORPATH/bin/ESSBASE.EXE 22222
                  ...
NEW OPTIONS:
 -igndir    : Ignore directory
 -ign <ptn> : Ignore file pattern
 -dyn <ptn> : Dynamic file pattern
 -dynp <n>  : Dynamic file percentage 1..99
OUTPUT:
  The whole file list under the <path> location. following format.
    <file path> <file size> [# <cksum>[ <date>[ <attr>]]]
    ...
NOTE:
  The date format is YYYY/MM/DD_hh:mm.
  The attribute format is same as Unix 'ls -l' command.
    -rw-rw-rw-, -rwxr--r--,...
SAMPLE:
  filesize.sh > kennedy2_091.siz
