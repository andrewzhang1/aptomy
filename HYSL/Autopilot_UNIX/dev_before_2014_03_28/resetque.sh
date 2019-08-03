#~/usr/bin/ksh
. apinc.sh

echo "`date +%D_%T` $node : RESETQUE.SH." >> $aphis
echo "Remove tasks for ${node} from the task queue."
rmtsk.sh -m - - -
echo "Remove tasks for ${node} from the current execution buffer."
rmtsk.sh crr -m - - -
echo "Remove done tasks for ${node}."
rmtsk.sh done -m - - -
if [ "$AP_NOPLAT" = "false" ]; then
	echo "Remove tasks for ${plat} from the task queue."
	rmtsk.sh -mp - - -
	echo "Remove tasks for ${plat} from the current execution buffer."
	rmtsk.sh crr -mp - - -
	echo "Remove done tasks for ${plat}."
	rmtsk.sh done -mp - - -
fi
