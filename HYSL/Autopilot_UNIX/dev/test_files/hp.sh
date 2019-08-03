#!/usr/bin/ksh

. se.sh 9.3.3.0.0
ci.sh 9.3.3.0.0 071-02
cmdgqinst.sh 9.3.3.0.0 071-01
cp $ARBORPATH/api/redist/* $ARBORPATH/bin
ap_essinit.sh

