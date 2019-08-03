# aptomy control script to download unread email...
#

while true
do 
    cd /home/azhang/aptomy_v0.51
    echo "Run dlattachments.py..."
    
    # Clean up
    rm details.txt incomeEmailName.txt
   
    python dlattachments.py   # The files will be at ~/attachment
    
    # Get the email name from the details.txt:
    grep "<.*@.*>" details.txt | sed -e "s/^.*<//g" -e "s/>.*$//g" > incomeEmailName.txt
    
    cd /home/azhang/aptomy_v0.51/attachment
    ls * >  temp_data.txt
   # mv `cat temp_data.txt` `cat /home/azhang3/aptomy_v0.51/incomeEmailName.txt`__`cat temp_data.txt`
   # rm temp_data.txt
  # for i in {1..`wc -l < temp_data.txt`}
    echo "start for loop...... "
  
    #for i in {1..3}
    #n=`wc -l < temp_data.txt`
    num=3
    for i in $(seq "$num")
    do
            echo $i

            mv `sed -n ""$i"p" temp_data.txt` `cat /home/azhang/aptomy_v0.51/incomeEmailName.txt`__`sed -n ""$i"p" temp_data.txt`
    done
    rm temp_data.txt
    # Move text file for scilab to process:
   
    mv /home/azhang/aptomy_v0.51/attachment/*.txt /home/azhang/aptomy_v0.51/inputfolder
    
    sleep 1
   
    #exit
done

