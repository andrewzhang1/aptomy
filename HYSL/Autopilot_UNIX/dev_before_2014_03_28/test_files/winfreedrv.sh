#!/usr/bin/ksh
used_drive=`cmd /C net use | grep ^OK | awk '{print $2}'`
free_drive=
cnt=0
for drv in Z Y X W V U T S R Q P O N M L K J I H; do
  if [ "${used_drive#*${drv}}" = "$used_drive" ]; then
    [ -z "$free_drive" ] && free_drive=$drv || free_drive="$free_drive $drv"
    let cnt=cnt+1
  fi
done
if [ $cnt -lt 3 ]; then
  echo "There is not enough free drive letter on this machine."
  exit 1
else
  vol1drv=${free_drive%% *}
  free_drive=${free_drive#* }
  vol2drv=${free_drive%% *}
  free_drive=${free_drive#* }
  vol3drv=${free_drive%% *}
fi

echo "vol1drv=$vol1drv, vol2drv=$vol2drv, vol3drv=$vol3drv"


