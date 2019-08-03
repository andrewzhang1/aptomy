login $1 $2 on $3;

create or replace database "'$4'"."'$5'";

/* return error code if any */
iferror 'create_db_failed';
logout;
exit;

define label 'create_db_failed';
exit;

