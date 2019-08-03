while true
do 
    echo "Run sendattachMain.py..."
    VAR=`(ls -t /home/azhang/aptomy_v0.51/resultfolder/*.pdf | tail -1)`
    
    echo $VAR
    echo "Show $VAR"
    sleep 2
    
    # Move the current $VAR which is the result as a pdf file for sending to the user:
    mv $VAR /home/azhang/aptomy_v0.51

    python sendattachMain.py  `ls *.pdf`
    echo "move $VAR to $APTOMY_HOME/processedfolder"

    # After sending the resut, move the pdf file to the processedfolder:
    mv *.pdf  /home/azhang/aptomy_v0.51/processedfolder

    #mv  $VAR $APTOMY_HOME/processedfolder
    sleep 1

done

