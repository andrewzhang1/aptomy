#!/usr/bin/env bash
# Author: Andrew Zhang
# Data:  2015
# updated on 2016/1/30

ps -fu $LOGNAME |grep scilab > scilab_processID


cat scilab_processID  |
        while read line
        do
           set $line
           echo $2
        #   sleep 1
           kill -9 $2
         done
