#: Authors: Andrew Zhang
#: Reviewers: 
#: Date: 18/11/2011
#: Purpose: Parallel Data Export and Import for 11.1.2.2.000 feature. 
#: Tag: NORMR 
#: Dependencies: esscmd.func
#: Runnable: true
#: Arguments: none
#: Memory/Disk: 500MB/300MB
#: SUC: 41
#: Test Time: 2 min. 
#: Created for: 11.1.2.2.000
#: Retired for:
#: Test cases: Run paralle import and export with multi-threads
#: History:
#: 18/11/2011 Andrew Zhang     Inital creation
#: 10/25/2012 Van Gee          Fixed hardcoded user name/password in msxxexport


. `sxr which -sh esscmd.func`
 
 sxr agtctl start

#--------------------------------------
#Constants and Variables for all parts
#--------------------------------------
APP=Ddxipar1
DB=Basic
OTL=ddxipara
DATA=Calcdat.txt

FILE1=ddxiparaexp_2thread            # File name for para export output with 2 threads
FILE1_1=ddxiparaexp_2thread_ParaImp  # File name for the full export after para import with 2 threads

FILE2=ddxiparaexp_5thread            # File name for para export output with 5 threads
FILE2_1=ddxiparaexp_5thread_ParaImp  # File name for the full export after para import with 5 threads

FILE3=ddxiparaexp_10thread           # File name for para export output with 10 threads               
FILE3_1=dxiparaexp_10thread_ParaImp  # File name for the full export after para import with 10 threads
 
FILE4=ddxiparaexp_20thread           # File name for para export output with 20 threads               
FILE4_1=dxiparaexp_20thread_ParaImp  # File name for the full export after para import with 20 threads


# Create the application/db
#--------------------------
create_app $APP
create_db $OTL.otl $APP $DB

#Load data to database
#----------------------
copy_file_to_db `sxr which -data $DATA` $APP $DB

load_data $APP $DB $DATA
runcalc_default $APP $DB



######################################################################################
# Part One: Test  ESSCMD - para export and para import with 2 threads using ESSCMD 
######################################################################################
 
# 1. Run paralell export with 2 threads:
sxr esscmd -q ddxiparaexport.scr %HOST=$SXR_DBHOST %UID=$SXR_USER \
                              %PWD=$SXR_PASSWORD %APP=$APP %DB=$DB \
                              %THREAD_NO=2 %EXP_FILE_NAME=$FILE1.out \
                              %OUT=ddxiparaexp1.out
                           
# 2. Verification of paralle exported files
for id in 1 2 
do
  mv $ARBORPATH/app/$FILE1${id}.out $SXR_WORK
  sxr diff $FILE1${id}.out $FILE1${id}.bas
  
done

# 3. Clear up data to prepare for paralle import:
sxr esscmd msxxresetdb.scr   %HOST=${SXR_DBHOST} %UID=${SXR_USER} \
                             %PWD=${SXR_PASSWORD} \
                             %APP=${APP}${Id} %DB=${DB}${Id}
                            
# 4. Prepare multiple data files for para import by moving the 2 exported files to the server   
for id in 1 2 
do
  cp $SXR_WORK/$FILE1${id}.out $ARBORPATH/app/$APP/$DB/$FILE1${id}.txt
done

# 6. Parallel import data with 2 threads
sxr esscmd -q  ddxiparaimport.scr  %HOST=$SXR_DBHOST %UID=$SXR_USER \
                             %PWD=$SXR_PASSWORD %APP=$APP %DB=$DB \
                              %THREAD_NO=2 %IMP_FILE_NAME=$FILE1 \
                              %OUT=ddxiparaimport1.out
                    
# 7. Make a full export again for comparison:
sxr esscmd msxxexport.scr %HOST=${SXR_DBHOST} %UID=$SXR_USER \
                          %PWD=$SXR_PASSWORD %APP=${APP} %DB=${DB} \
                          %FNAME=$FILE1_1.out %OPT="1"

# 8. Move exported data by para import for verifying the correctness:
mv $ARBORPATH/app/$FILE1_1.out  $SXR_WORK                      
                          
# 9. Compare out by Para Import with the default export result
sxr diff $FILE1_1.out ddxiparaFullExp.bas


# 10. Clear up data to prepare for paralle import:

sxr esscmd msxxresetdb.scr   %HOST=${SXR_DBHOST} %UID=${SXR_USER} \
                             %PWD=${SXR_PASSWORD} \
                             %APP=${APP}${Id} %DB=${DB}${Id}

######################################################################################
# Part Twe: Test new esscmd - para export and para import with 5 threads using ESSCMD 
######################################################################################

#Load data to database
#----------------------
#copy_file_to_db `sxr which -data $DATA` $APP $DB

load_data $APP $DB $DATA
runcalc_default $APP $DB


# 1. Run paralell export with 5 threads:
sxr esscmd -q ddxiparaexport.scr %HOST=$SXR_DBHOST %UID=$SXR_USER \
                              %PWD=$SXR_PASSWORD %APP=$APP %DB=$DB \
                              %THREAD_NO=5 %EXP_FILE_NAME=$FILE2.out \
                              %OUT=ddxiparaexp2.out

# 2. Verification of paralle exported files

for id in 1 2 3 4 5 
do
  mv $ARBORPATH/app/$FILE2${id}.out $SXR_WORK
  sxr diff $FILE2${id}.out $FILE2${id}.bas
  
done

# 3. Clear up data to prepare for paralle import:

sxr esscmd msxxresetdb.scr   %HOST=${SXR_DBHOST} %UID=${SXR_USER} \
                             %PWD=${SXR_PASSWORD} \
                             %APP=${APP}${Id} %DB=${DB}${Id}
                            
# 4. Prepare multiple data files for para import by moving the 5 exported files to the server   
for id in 1 2 3 4 5 
do
  cp $SXR_WORK/$FILE2${id}.out $ARBORPATH/app/$APP/$DB/$FILE2${id}.txt
done

# 6. Parallel import data with 5 threads
sxr esscmd -q  ddxiparaimport.scr  %HOST=$SXR_DBHOST %UID=$SXR_USER \
                             %PWD=$SXR_PASSWORD %APP=$APP %DB=$DB \
                              %THREAD_NO=5 %IMP_FILE_NAME=$FILE2 \
                              %OUT=ddxiparaimport2.out
                    
# 7. Make a full export again for comparison:
sxr esscmd msxxexport.scr %HOST=${SXR_DBHOST} %UID=$SXR_USER \
                          %PWD=$SXR_PASSWORD %APP=${APP} %DB=${DB} \
                          %FNAME=$FILE2_1.out %OPT="1"

# 8. Move exported data by para import for verifying the correctness:
mv $ARBORPATH/app/$FILE2_1.out  $SXR_WORK                      
                          
# 9. Compare out by Para Import with the default export result
sxr diff $FILE2_1.out ddxiparaFullExp.bas

# 10. Clear up data to prepare for paralle import:

sxr esscmd msxxresetdb.scr   %HOST=${SXR_DBHOST} %UID=${SXR_USER} \
                             %PWD=${SXR_PASSWORD} \
                             %APP=${APP}${Id} %DB=${DB}${Id}
        

######################################################################################
# Part Three: Test new esscmd - para export and para import with 10 threads using ESSCMD 
######################################################################################

#Load data to database
#----------------------
#copy_file_to_db `sxr which -data $DATA` $APP $DB

load_data $APP $DB $DATA
runcalc_default $APP $DB


# 1. Run paralell export with 5 threads:
sxr esscmd -q ddxiparaexport.scr %HOST=$SXR_DBHOST %UID=$SXR_USER \
                              %PWD=$SXR_PASSWORD %APP=$APP %DB=$DB \
                              %THREAD_NO=10 %EXP_FILE_NAME=$FILE3.out \
                              %OUT=ddxiparaexp3.out

# 2. Verification of paralle exported files

for id in 1 2 3 4 5 6 7 8 9 10
do
  mv $ARBORPATH/app/$FILE3${id}.out $SXR_WORK
  sxr diff $FILE3${id}.out $FILE3${id}.bas
  
done

# 3. Clear up data to prepare for paralle import:

sxr esscmd msxxresetdb.scr   %HOST=${SXR_DBHOST} %UID=${SXR_USER} \
                             %PWD=${SXR_PASSWORD} \
                             %APP=${APP}${Id} %DB=${DB}${Id}
                                               
                           
# 4. Prepare multiple data files for para import by moving the 10 exported files to the server   
for id in 1 2 3 4 5 6 7 8 9 10 
do
  cp $SXR_WORK/$FILE3${id}.out $ARBORPATH/app/$APP/$DB/$FILE3${id}.txt
done

# 6. Parallel import data with 10 threads
sxr esscmd -q  ddxiparaimport.scr  %HOST=$SXR_DBHOST %UID=$SXR_USER \
                             %PWD=$SXR_PASSWORD %APP=$APP %DB=$DB \
                              %THREAD_NO=10 %IMP_FILE_NAME=$FILE3 \
                              %OUT=ddxiparaimport3.out
                    
# 7. Make a full export again for comparison:
sxr esscmd msxxexport.scr %HOST=${SXR_DBHOST} %UID=$SXR_USER \
                          %PWD=$SXR_PASSWORD %APP=${APP} %DB=${DB} \
                          %FNAME=$FILE3_1.out %OPT="1"

# 8. Move exported data by para import for verifying the correctness:
mv $ARBORPATH/app/$FILE3_1.out  $SXR_WORK                      
                          
# 9. Compare out by Para Import with the default export result
sxr diff $FILE3_1.out ddxiparaFullExp.bas


# 10. Clear up data to prepare for paralle import:

sxr esscmd msxxresetdb.scr   %HOST=${SXR_DBHOST} %UID=${SXR_USER} \
                             %PWD=${SXR_PASSWORD} \
                             %APP=${APP}${Id} %DB=${DB}${Id}  




######################################################################################
# Part Four: Test new esscmd - para export and para import with 20 threads using ESSCMD 
######################################################################################

#Load data to database
#----------------------
#copy_file_to_db `sxr which -data $DATA` $APP $DB

load_data $APP $DB $DATA
runcalc_default $APP $DB


# 1. Run paralell export with 5 threads:
sxr esscmd -q ddxiparaexport.scr %HOST=$SXR_DBHOST %UID=$SXR_USER \
                              %PWD=$SXR_PASSWORD %APP=$APP %DB=$DB \
                              %THREAD_NO=20 %EXP_FILE_NAME=$FILE4.out \
                              %OUT=ddxiparaexp4.out
                              
                              
# 2. Verification of paralle exported files

for id in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20
do
  mv $ARBORPATH/app/$FILE4${id}.out $SXR_WORK
  sxr diff $FILE4${id}.out $FILE4${id}.bas
  
done

# 3. Clear up data to prepare for paralle import:

sxr esscmd msxxresetdb.scr   %HOST=${SXR_DBHOST} %UID=${SXR_USER} \
                             %PWD=${SXR_PASSWORD} \
                             %APP=${APP}${Id} %DB=${DB}${Id}
                                               
                           
# 4. Prepare multiple data files for para import by moving the 10 exported files to the server   
for id in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20
do
  cp $SXR_WORK/$FILE4${id}.out $ARBORPATH/app/$APP/$DB/$FILE4${id}.txt
done

# 6. Parallel import data with 10 threads
sxr esscmd -q  ddxiparaimport.scr  %HOST=$SXR_DBHOST %UID=$SXR_USER \
                             %PWD=$SXR_PASSWORD %APP=$APP %DB=$DB \
                              %THREAD_NO=20 %IMP_FILE_NAME=$FILE4 \
                              %OUT=ddxiparaimport4.out
                    
# 7. Make a full export again for comparison:
sxr esscmd msxxexport.scr %HOST=${SXR_DBHOST} %UID=$SXR_USER \
                          %PWD=$SXR_PASSWORD %APP=${APP} %DB=${DB} \
                          %FNAME=$FILE4_1.out %OPT="1"


# 8. Move exported data by para import for verifying the correctness:
mv $ARBORPATH/app/$FILE4_1.out  $SXR_WORK                      
                          
# 9. Compare out by Para Import with the default export result
sxr diff $FILE4_1.out ddxiparaFullExp.bas

# 10. Clear up data to prepare for paralle import:

sxr esscmd msxxresetdb.scr   %HOST=${SXR_DBHOST} %UID=${SXR_USER} \
                             %PWD=${SXR_PASSWORD} \
                             %APP=${APP}${Id} %DB=${DB}${Id}  



#######################
# Unlpad app
#######################
unload_app $APP

