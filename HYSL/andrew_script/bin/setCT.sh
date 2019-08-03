#Need to modify these two
export SYS_NAME=$(uname -n)
export TAGNAME=${LOGNAME}_70view_${SYS_NAME}
export VIEWLOCATION=${ARBORPATH}/ccv/th_70view_${SYS_NAME}.vws

#Make sure they are in .profile
export SXR_HOME=/vobs/essexer/latest
alias ct=cleartool

#create clearcase view
ct mkview -tag $TAGNAME $VIEWLOCATION  
ct lsview -prop -full $TAGNAME 

#Make the view active
ct setview -login $TAGNAME 

#Edit Config spec
ct edcs
include /net/svfs1/vol/vol0/pre_rel/essbase/cs/zephyr.cs

#Stop a view
ct endview $TAGNAME 

#remove a view
ct  rmview -tag $TAGNAME

