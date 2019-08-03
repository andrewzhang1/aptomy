#!/bin/bash

#: Authors: Andrew Zhang
#: Reviewers: 
#: Date: 02/26/2015
#: Purpose: 	Batch control aptomy's data flow..
#: Test cases: 
#    	Use case 1: 
#	    -------------------------------------------------------------------
#
#: Component/Sub Comp: 
#: Owned by: 
#: Tag: 
#: Dependencies: scilab, python, etc
#: Runnable: true
#: Arguments: none
#: Memory/Disk: 200MB/200MB
#: SUC: 
#: Created for: 
#: Retired for:
#: Test time: within 10 sec
#: History:
# 02/26/2015 AZHANG	First edition.
# 03/08/2015 Azhang: added APTOMY_HOME env
# 03/11: Azhang: Added logic to combine email address with the downloaded text file name

# Note: In order to run test, we need to set two 
# 1. APTOMY_HOME: Store all the scilab files and sub folders.
# 2. APTOMY_LOG_HOME: store all log files
# 3. This one use emai account: aptomy.test1@gmail.com
# 03/20/2015 Move to v2
# Script name:aptomymain_v2.sh
# 
# 04/03/2015 Move to v0.50
# 1) use: Import_Kin_Data_v7sh.sce
# 2) Added python file PrintModulev3.py inside the Import_Kin_Data_v7sh.sce
# 3) Created pdf file instead of text file

umask 000

if [ -z "$APTOMY_HOME" ]; then
	echo ""
	echo "APTOMY_HOME is not defined."
	echo "Please define APTOMY_HOME first!"	
	exit 
fi

if [ -z "$APTOMY_LOG_HOME" ]; then
        echo ""
	echo "APTOMY_LOG_HOME is not defined."
        echo "Please created a APTOMY_LOG_HOME!"
        exit
fi

#logf="$APTOMY_HOME_`date +%Y%m%d_%H%M%S`.log"
logf="$APTOMY_LOG_HOME_`date +%Y%m%d_%H%M%S`.log"


cd $APTOMY_HOME

echo "Currently we are running at: "
echo `pwd`

echo "### START THIS TEST at `date +%D_%T`" >>  $APTOMY_LOG_HOME/$logf

# Clear up the resultfolder/
echo " "
echo "Clean up the ~/resultfolder"
rm $APTOMY_HOME/resultfolder/* 2>&1 | tee -a $APTOMY_LOG_HOME/$logf
rm $APTOMY_HOME/inputfolder/* 2>&1 | tee -a $APTOMY_LOG_HOME/$logf
#rm $APT_HOME/attachments/*.txt 2>&1 | tee -a $logf
mv $APTOMY_HOME/*.txt $APTOMY_HOME/processedfolder

# Clean up the pdf in the APTOMY_HOME directory:
rm $APTOMY_HOME/*.pdf 

echo "### Run 1) Download attachemen by dlattachments.py at `date +%D_%T`" >> $APTOMY_LOG_HOME/$logf
python dlattachments.py 2>&1 | tee -a $APTOMY_LOG_HOME/$logf

# Get the email name from the details.txt:
grep "<.*@.*>" details.txt | sed -e "s/^.*<//g" -e "s/>.*$//g" > incomeEmailName.txt

#concatenate the content of the incomeEmailName.txt with the text file name :
# For exaple from Text.txt into:  agz111@hotmail.com__Text.txt

# attachment

# Keep download file inti there attachments

cd $APTOMY_HOME/inputfolder

ls * > temp_data.txt

mv `cat temp_data.txt` `cat $APTOMY_HOME/incomeEmailName.txt`__`cat temp_data.txt`

g
# Clean the dumy filei to avoid confusion::
rm temp_data.txt

cd $APTOMY_HOME

#chmod 755 inputfolder/*

if [ -f inputfolder/*.txt ] ; then
    echo " "
  

  echo "### Run 2) Run Scilab Data Analysis... at `date +%D_%T`" >> $APTOMY_LOG_HOME/$logf
    /home/ubuntu/scilab-5.5.1/bin/scilab -nw -f Import_Kin_Data_v7sh.sce 2>&1 | tee -a $APTOMY_LOG_HOME/$logf
    ls -l resultfolder/* 

    
    echo " "
    echo "### Run 3) Check Scilab test results:" >> $APTOMY_LOG_HOME/$logf
    echo "ls -l resultfolder" >> $APTOMY_LOG_HOME/$logf 
    echo "`ls -l resultfolder`" >> $APTOMY_LOG_HOME/$logf

# move result file to the current folder to be sent to the end user by gmail.
    echo " "
    echo "### Run 4) Move result file to the current folder to be sent to the end user by gmail. `date +%D_%T`" >> $APTOMY_LOG_HOME/$logf

    mv resultfolder/*.pdf . 2>&1 | tee -a $APTOMY_LOG_HOME/$logf

    ls *Result.pdf > resultFileName.txt

 
    echo " "
    echo "### Run 5) Send Result by  sendattach.py at `date +%D_%T`" >> $APTOMY_LOG_HOME/$logf
  
    python sendattachMain.py `cat resultFileName.txt` 2>&1 | tee -a $APTOMY_LOG_HOME/$logf

#export
# or:
# python sendattachMain.py  $var2
 
  # python sendattach.py  2>&1 | tee -a $APTOMY_LOG_HOME/$logf

    echo "" 
    echo "### DONE TEST after sent result at `date +%D_%T`" >> $APTOMY_LOG_HOME/$logf

    echo ""
    echo "Move analyzed text data into folder processedfolder" 
    mv *.txt processedfolder  2>&1 | tee -a $APTOMY_LOG_HOME/$logf

    echo "Test is done"

   cd -
   echo "We are at:"
   echo "`pwd` " 

else

   echo ""
   echo "No file found under inputfolder folder; exit!"
   echo "No file found under inputfolder folder" >> $APTOMY_LOG_HOME/$logf 
   echo "No scilab test is running. Exit now." >> $APTOMY_LOG_HOME/$logf
fi

