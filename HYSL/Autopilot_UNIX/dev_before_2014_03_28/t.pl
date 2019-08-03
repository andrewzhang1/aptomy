#!/usr/bin/perl

if ( $^O eq "MSWin32" ) {
	$os = "win";
} else {
	$os = `uname`;
}
print "$os\n";


