#!/usr/bin/ksh
pstree.pl $@ -i $$ | sed -e "s![^ ]*vobs/essexer/!SXR/!g" -e "s!$AUTOPILOT!AP!g" -e "s![^ ]*autoregress/!SXR_VIEW/!g" -e "s!/usr/bin/ksh!KSH!g" -e "s![^ ]*EssbaseServer[^ ]*/bin!ARBORPATH/bin!g" -e "s![^ ]*EPMSystem11R1/!HYPERION_HOME/!g"
