#!/usr/bin/ksh

#########################################################################
# Filename:    get_crrapp.sh
# Author:      Yukio Kono
# History ###############################################################
# 09/24/2010 YKono	First Edition from autopilot2.sh

psu -essa | grep -v "DM_APP" | while read pid dmy app; do
	echo $app
done


