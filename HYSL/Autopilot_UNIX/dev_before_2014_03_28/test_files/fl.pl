#!/usr/bin/perl

#################################################################
# Initial value
			
#################################################################
# Read parameter
@args=@ARGV;
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
$mypid=`echo $$`;
$tmp=`ps -p $$ -f 2> /dev/null | tail -1`;
print "myid=$mypid\n";
print "ps -p=$tmp\n";

exit(123);

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
test program help

SYNTAX:
  fl.pl [-h] 

PARAMETER:
  -h      : Display help.
