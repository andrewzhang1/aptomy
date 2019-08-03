#!/usr/bin/ksh

addtsk.sh -f i18nyuki.tsk regryhw32e@scl34437 $1 $2 -o "opackver(!bi) opackskip(client)"
addtsk.sh -f i18nyuki.tsk regryhw64e@scl20204 $1 $2 -o "opackver(!bi) opackskip(client)"
addtsk.sh -f i18nyuki.tsk hhashimo@scl51027.us.oracle.com $1 $2 -o "opackver(!bi)"
addtsk.sh -f i18nyuki.tsk yhlx32b@oel5yhap2 $1 $2 -o "opackver(!bi)"
addtsk.sh -f i18nyuki.tsk yhlx64@oel6x64yh $1 $2 -o "opackver(!bi)"
addtsk.sh -f i18nyuki.tsk hhashimo@scl59181 $1 $2 -o "opackver(!bi)"
