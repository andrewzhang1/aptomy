#!/usr/bin/perl

$arg="";
for($i=0; $i<@ARGV; $i++){
  $arg=$arg.$ARGV[$i]." ";
}

$ret=`chkcrr.sh $arg`;

print $ret;

