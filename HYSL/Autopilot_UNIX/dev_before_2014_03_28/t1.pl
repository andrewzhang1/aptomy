#!/usr/bin/perl

# $ENV{ARBORPATH}="$ENV{HOME}\\hyperion\\11-1-2-3-500";
# system "net use Z: \\\\10.148.218.213\\kono /USER:ykono password";
# print "Enter perl sub system\n";
# system "cmd.exe";
# print "Exit perl sub system\n";
# system "net use Z: /DELETE";
# my $out= `ls -l`;
# print $out, "\n";

my $netuse = `net use`;
print $netuse."\n";

my $useletter = `fsutil fsinfo drives`;
print $useletter."\n";

