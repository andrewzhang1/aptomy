#!/usr/bin/ksh
# The compare string study for all platforms.

## LOGIC 1
# export _a=$1
# export _b=$2
#
# cmp=`perl -e '$a="$ENV{'_a'}";$b="$ENV{'_b'}";if ($a lt $b) {print "<";} elsif ($a eq $b) {print "=";} else {print ">";};'`

## LOGIC 2
# perlcmd="\
# 	\$a=\"${1}\";\
# 	\$b=\"${2}\";\
# 	if(\$a lt \$b){ \
# 		print \"<\" \
# 	}elsif(\$a eq \$b){ \
# 		print \"=\" \
# 	}else{ \
# 		print \">\" \
# 	}"
# cmp=`perl -e "$perlcmd"`

# LOGIC 3
cmpstr()
{
	perlcmd="\$a=\"${1}\";\$b=\"${2}\";if(\$a lt \$b){print \"<\"}elsif(\$a eq \$b){print \"=\"}else{print \">\"}"
	perl -e "$perlcmd"
}
cmp=`cmpstr "$1" "$2"`

echo $1 $cmp $2
