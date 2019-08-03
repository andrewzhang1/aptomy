#!/bin/bash

# This is a bash comment.
hive << EOF > results.txt
-- This is a hive comment.
SHOW DATABASES
;
EOF


