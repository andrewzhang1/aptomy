##################################################################################
# Test for Login By password, expected to be all successful
#Test Script: 		agsyloginbypassword_J13.sh
# Purposes: 			Test login by password, it should be always successful
#
# Files Called:    1. loginbypassword*.scr created on runtime
#
# Updated:  Mar. 20, 2003
##################################################################################

echo ############################################
echo #
echo #        Test for Login by Token
echo #
echo ############################################

HOST=${SXR_DBHOST}
USER=${SXR_USER}
PASSWD=${SXR_PASSWORD}
WORK=${SXR_WORK}
VIEW=${SXR_VIEWHOME}


# Create loginbypassword_IP_azhang.scr
echo "Output 1 \"%OUT\";"                               >  loginbypassword_J13_IP_azhang.scr
echo "login \"%HOST\" \"azhang\" \"password\"; "        >> 	loginbypassword_J13_IP_azhang.scr
echo "Output 3;"                                        >> loginbypassword_J13_IP_azhang.scr
echo "Logout;"                                          >> loginbypassword_J13_IP_azhang.scr
echo "exit;"                                            >> loginbypassword_J13_IP_azhang.scr

# Create loginbypassword_IP_Jeff.scr
echo "Output 1 \"%OUT\";"                               >  loginbypassword_J13_IP_Jeff.scr
echo "login \"%HOST\" \"Jeff\" \"Jeff\";"               >> loginbypassword_J13_IP_Jeff.scr
echo "Output 3;"                                        >> loginbypassword_J13_IP_Jeff.scr
echo "Logout;"                                          >> loginbypassword_J13_IP_Jeff.scr
echo "exit;"                                            >> loginbypassword_J13_IP_Jeff.scr

# Create loginbypassword_IP_Susan.scr
echo "Output 1 \"%OUT\";"                               >  loginbypassword_J13_IP_Susan.scr
echo "login \"%HOST\" \"Susan\" \"Susan\";"             >> loginbypassword_J13_IP_Susan.scr
echo "Output 3;"                                        >> loginbypassword_J13_IP_Susan.scr
echo "Logout;"                                          >> loginbypassword_J13_IP_Susan.scr
echo "exit;"                                            >> loginbypassword_J13_IP_Susan.scr

# Create loginbypassword_IP_Prem.scr
echo "Output 1 \"%OUT\";"                               >  loginbypassword_J13_IP_Prem.scr
echo "login \"%HOST\" \"Prem Gaur\" \"mypassword\";"    >> loginbypassword_J13_IP_Prem.scr
echo "Output 3;"                                        >> loginbypassword_J13_IP_Prem.scr
echo "Logout;"                                          >> loginbypassword_J13_IP_Prem.scr
echo "exit;"                                            >> loginbypassword_J13_IP_Prem.scr

#  A special case for essexer:

echo "Output 1 \"%OUT\";"                                           >  loginbypassword_J13_AD_essexer.scr
echo "login  \"localhost\" \"essexer\" \"password\";"               >> loginbypassword_J13_AD_essexer.scr
echo "select  \"agsyCSS1\" \"Basic\";"                              >> loginbypassword_J13_AD_essexer.scr
echo "getdbinfo;"                                                   >> loginbypassword_J13_AD_essexer.scr
echo "Output 3;"                                                    >> loginbypassword_J13_AD_essexer.scr
echo "Logout;"                                                      >> loginbypassword_J13_AD_essexer.scr
echo "exit;"                                                        >> loginbypassword_J13_AD_essexer.scr

# Create loginbypassword_AD_Andrew.scr
echo "Output 1 \"%OUT\";"                                >  loginbypassword_J13_AD_Andrew.scr
echo "login \"%HOST\" \"Andrew G. Zhang\" \"password\";" >> loginbypassword_J13_AD_Andrew.scr
echo "select  \"agsyCSS1\" \"Basic\";"                  >> loginbypassword_J13_AD_Andrew.scr
echo "import  \"2\" \"Agsytxt\" \"4\" \"n\" \"Y\";"     >> loginbypassword_J13_AD_Andrew.scr
echo "getdbinfo;"                                       >> loginbypassword_J13_AD_Andrew.scr
echo "Output 3;"                                         >> loginbypassword_J13_AD_Andrew.scr
echo "Logout;"                                           >> loginbypassword_J13_AD_Andrew.scr
echo "exit;"                                             >> loginbypassword_J13_AD_Andrew.scr

# Create loginbypassword_AD_Bao.scr
echo "Output 1 \"%OUT\";"                               >  loginbypassword_J13_AD_Bao.scr
echo "login \"%HOST\" \"Bao Nguyen\"  \"password\";"    >> loginbypassword_J13_AD_Bao.scr
echo "Output 3;"                                        >> loginbypassword_J13_AD_Bao.scr
echo "Logout;"                                          >> loginbypassword_J13_AD_Bao.scr
echo "exit;"                                            >> loginbypassword_J13_AD_Bao.scr

# Create loginbypassword_AD_Jeff.scr
echo "Output 1 \"%OUT\";"                               >  loginbypassword_J13_AD_Jeff.scr
echo "login \"%HOST\" \"Jeff A. Lee\" \"password\";"    >> loginbypassword_J13_AD_Jeff.scr
echo "Output 3;"                                        >> loginbypassword_J13_AD_Jeff.scr
echo "Logout;"                                          >> loginbypassword_J13_AD_Jeff.scr
echo "exit;"                                            >> loginbypassword_J13_AD_Jeff.scr

# Create loginbypassword_AD_John.scr
echo "Output 1 \"%OUT\";"                               >  loginbypassword_J13_AD_John.scr
echo "login \"%HOST\" \"John Doe\" \"doe, john\";"      >> loginbypassword_J13_AD_John.scr
echo "Output 3;"                                        >> loginbypassword_J13_AD_John.scr
echo "Logout;"                                          >> loginbypassword_J13_AD_John.scr
echo "exit;"                                            >> loginbypassword_J13_AD_John.scr

# Create loginbypassword_AD_anguyen.scr
echo "Output 1 \"%OUT\";"                               >  loginbypassword_J13_AD_anguyen.scr
echo "login \"%HOST\" \"anguyen_AD\" \"password\";"     >> loginbypassword_J13_AD_anguyen.scr
echo "createapp \"App_AN\";"                            >> loginbypassword_J13_AD_anguyen.scr
echo "Output 3;"                                        >> loginbypassword_J13_AD_anguyen.scr
echo "Logout;"                                          >> loginbypassword_J13_AD_anguyen.scr
echo "exit;"                                            >> loginbypassword_J13_AD_anguyen.scr

# Create loginbypassword_AD_bnguyen.scr
echo "Output 1 \"%OUT\";"                               >  loginbypassword_J13_AD_bnguyen.scr
echo "login \"%HOST\" \"bnguyen_AD\" \"password\";"     >> loginbypassword_J13_AD_bnguyen.scr
echo "createapp \"App_BN-1\";"                          >> loginbypassword_J13_AD_bnguyen.scr
echo "createdb  \"App_BN-1\" \"Basic\";"                >> loginbypassword_J13_AD_bnguyen.scr
echo "createuser \"user_BN-1\" \"password\";"           >> loginbypassword_J13_AD_bnguyen.scr
echo "listusers;"                                       >> loginbypassword_J13_AD_bnguyen.scr
echo "listdb;"                                          >> loginbypassword_J13_AD_bnguyen.scr
echo "select  \"App_BN-1\" \"Basic\";"                  >> loginbypassword_J13_AD_bnguyen.scr
echo "unloadapp \"App_BN-1\";"                          >> loginbypassword_J13_AD_bnguyen.scr
echo "deleteapp \"App_BN-1\";"                          >> loginbypassword_J13_AD_bnguyen.scr
echo "deleteuser \"user_BN-1\";"                        >> loginbypassword_J13_AD_bnguyen.scr
echo "Output 3;"                                        >> loginbypassword_J13_AD_bnguyen.scr
echo "Logout;"                                          >> loginbypassword_J13_AD_bnguyen.scr
echo "exit;"                                            >> loginbypassword_J13_AD_bnguyen.scr

# Create loginbypassword_AD_cnguyen.scr
echo "Output 1 \"%OUT\";"                               >  loginbypassword_J13_AD_cnguyen.scr
echo "login \"%HOST\" \"cnguyen_AD\" \"password\";"     >> loginbypassword_J13_AD_cnguyen.scr
echo "createuser \"user_CN-1\" \"passowrd\";"           >> loginbypassword_J13_AD_cnguyen.scr
echo "createapp \"App_CN-1\";"                          >> loginbypassword_J13_AD_cnguyen.scr
echo "deleteuser \"user_CN-1\" ;"                       >> loginbypassword_J13_AD_cnguyen.scr
echo "Output 3;"                                        >> loginbypassword_J13_AD_cnguyen.scr
echo "Logout;"                                          >> loginbypassword_J13_AD_cnguyen.scr
echo "exit;"                                            >> loginbypassword_J13_AD_cnguyen.scr

# Create loginbypassword_AD_enguyen.scr
echo "Output 1 \"%OUT\";"                               >  loginbypassword_J13_AD_enguyen.scr
echo "login \"%HOST\" \"enguyen_AD\" \"password\";"     >> loginbypassword_J13_AD_enguyen.scr
echo "loadapp  \"agsyCSS1\";"                           >> loginbypassword_J13_AD_enguyen.scr
echo "Output 3;"                                        >> loginbypassword_J13_AD_enguyen.scr
echo "Logout;"                                          >> loginbypassword_J13_AD_enguyen.scr
echo "exit;"                                            >> loginbypassword_J13_AD_enguyen.scr

# Create loginbypassword_AD_hnguyen.scr
echo "Output 1 \"%OUT\";"                               >  loginbypassword_J13_AD_hnguyen.scr
echo "login \"%HOST\" \"hnguyen_AD\" \"password\";"     >> loginbypassword_J13_AD_hnguyen.scr
echo "createapp \"App_HN-1\";"                          >> loginbypassword_J13_AD_hnguyen.scr
echo "createdb  \"App_HN-1\" \"Basic\";"                >> loginbypassword_J13_AD_hnguyen.scr
echo "createuser \"user_HN-1\" \"passowrd\";"           >> loginbypassword_J13_AD_hnguyen.scr
# echo "select  \"agsyCSS1\" \"Basic\";"                >> loginbypassword_J13_AD_hnguyen.scr
# echo "import  \"2\" \"Agsytxt\" \"4\" \"n\" \"Y\";"   >> loginbypassword_J13_AD_hnguyen.scr
# echo "listusers;"                                     >> loginbypassword_J13_AD_hnguyen.scr
echo "unloadapp \"App_HN-1\";"                          >> loginbypassword_J13_AD_hnguyen.scr
echo  "deleteapp \"App_HN-1\";"                         >> loginbypassword_J13_AD_hnguyen.scr
echo "Output 3;"                                        >> loginbypassword_J13_AD_hnguyen.scr
echo "Logout;"                                          >> loginbypassword_J13_AD_hnguyen.scr
echo "exit;"                                            >> loginbypassword_J13_AD_hnguyen.scr

chmod 777 *scr
cp *scr ../scr



#####################################################################################
# loginbypassword Part 1: Token lasts for 10 minusts
##################################################################################


sxr esscmd -q loginbypassword_J13_IP_azhang.scr %HOST=$HOST %OUT=loginbypassword_J13_IP_azhang.out
sxr esscmd -q loginbypassword_J13_IP_Jeff.scr   %HOST=$HOST %OUT=loginbypassword_J13_IP_Jeff.out
sxr esscmd -q loginbypassword_J13_IP_Susan.scr  %HOST=$HOST %OUT=loginbypassword_J13_IP_Susan.out
sxr esscmd -q loginbypassword_J13_IP_Prem.scr   %HOST=$HOST %OUT=loginbypassword_J13_IP_Prem.out

# sxr esscmd -q loginbypassword_J13_AD_essexer.scr %HOST=$HOST %OUT=loginbypassword_J13_AD_essexer.out
sxr esscmd -q loginbypassword_J13_AD_Andrew.scr %HOST=$HOST %OUT=loginbypassword_J13_AD_Andrew.out
sxr esscmd -q loginbypassword_J13_AD_Bao.scr    %HOST=$HOST %OUT=loginbypassword_J13_AD_Bao.out
sxr esscmd -q loginbypassword_J13_AD_Jeff.scr   %HOST=$HOST %OUT=loginbypassword_J13_AD_Jeff.out
sxr esscmd -q loginbypassword_J13_AD_John.scr   %HOST=$HOST %OUT=loginbypassword_J13_AD_John.out

sxr esscmd -q loginbypassword_J13_AD_anguyen.scr %HOST=$HOST %OUT=loginbypassword_J13_AD_anguyen.out
sxr esscmd -q loginbypassword_J13_AD_bnguyen.scr %HOST=$HOST %OUT=loginbypassword_J13_AD_bnguyen.out
sxr esscmd -q loginbypassword_J13_AD_cnguyen.scr %HOST=$HOST %OUT=loginbypassword_J13_AD_cnguyen.out
sxr esscmd -q loginbypassword_J13_AD_enguyen.scr %HOST=$HOST %OUT=loginbypassword_J13_AD_enguyen.out
sxr esscmd -q loginbypassword_J13_AD_hnguyen.scr %HOST=$HOST %OUT=loginbypassword_J13_AD_hnguyen.out

compare_result ()
{
# OutputFileName BaselineFileName (by pair)
sxr diff -ignore "Average Clust.*$" -ignore "Average Fragment.*$" \
	 -ignore '\[... .*$' -ignore '\[... .*$' -ignore 'Last login .*$' \
         -ignore 'process id .*$' \
         -ignore 'Total Calc Elapsed Time .*$' \
         -ignore '\[... .*$' -ignore 'Logging out .*$' \
	 -ignore 'Average Fragmentation Quotient .*$' \
	 -ignore '.*Time.*$' \
	 $1  $2

if [ $? -eq 0 ]
     then
       echo Success comparing $1
     else
       echo Failure comparing $1
fi
}

#########################################
#
#  Compare the result
#########################################

compare_result loginbypassword_J13_IP_azhang.out  loginbypassword_J13_IP_azhang.bas
compare_result loginbypassword_J13_IP_Jeff.out    loginbypassword_J13_IP_Jeff.bas
compare_result loginbypassword_J13_IP_Susan.out   loginbypassword_J13_IP_Susan.bas
compare_result loginbypassword_J13_IP_Prem.out    loginbypassword_J13_IP_Prem.bas

compare_result loginbypassword_J13_AD_Andrew.out  loginbypassword_J13_AD_Andrew.bas
compare_result loginbypassword_J13_AD_Bao.out     loginbypassword_J13_AD_Bao.bas
compare_result loginbypassword_J13_AD_Jeff.out    loginbypassword_J13_AD_Jeff.bas
compare_result loginbypassword_J13_AD_John.out    loginbypassword_J13_AD_John.bas

compare_result loginbypassword_J13_AD_anguyen.out  loginbypassword_J13_AD_anguyen.bas
compare_result loginbypassword_J13_AD_bnguyen.out  loginbypassword_J13_AD_bnguyen.bas
compare_result loginbypassword_J13_AD_cnguyen.out  loginbypassword_J13_AD_cnguyen.bas
compare_result loginbypassword_J13_AD_enguyen.out  loginbypassword_J13_AD_enguyen.bas
compare_result loginbypassword_J13_AD_hnguyen.out  loginbypassword_J13_AD_hnguyen.bas

