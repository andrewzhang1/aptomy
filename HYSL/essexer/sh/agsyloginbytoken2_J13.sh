##################################################################################
# Test for Login By Token, which were created by agsyCSS_j13.sh
#Test Script: 		agsyloginbytoken2_J13.sh
# Purposes: 			1.
#
# Files Called:    1. loginbytoken*.scr
#
# Updated:  Feb 24
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


# Create loginbytoken_IP_azhang.scr
echo "Output 1 \"%OUT\";"                                           >  loginbytoken_J13_IP_azhang-2.scr
echo "loginbytoken \"%HOST\" \"`cat token_J13_IP_azhang-1.out`\"; " >> loginbytoken_J13_IP_azhang-2.scr
echo "Output 3;"                                                    >> loginbytoken_J13_IP_azhang-2.scr
echo "Logout;"                                                      >> loginbytoken_J13_IP_azhang-2.scr
echo "exit;"                                                        >> loginbytoken_J13_IP_azhang-2.scr

# Create loginbytoken_IP_Jeff.scr
echo "Output 1 \"%OUT\";"                                           >  loginbytoken_J13_IP_Jeff-2.scr
echo "loginbytoken \"%HOST\" \"`cat token_J13_IP_Jeff-1.out`\";"    >> loginbytoken_J13_IP_Jeff-2.scr
echo "Output 3;"                                                    >> loginbytoken_J13_IP_Jeff-2.scr
echo "Logout;"                                                      >> loginbytoken_J13_IP_Jeff-2.scr
echo "exit;"                                                        >> loginbytoken_J13_IP_Jeff-2.scr

# Create loginbytoken_IP_Susan.scr
echo "Output 1 \"%OUT\";"                                           >  loginbytoken_J13_IP_Susan-2.scr
echo "loginbytoken \"%HOST\" \"`cat token_J13_IP_Susan-1.out`\";"   >> loginbytoken_J13_IP_Susan-2.scr
echo "Output 3;"                                                    >> loginbytoken_J13_IP_Susan-2.scr
echo "Logout;"                                                      >> loginbytoken_J13_IP_Susan-2.scr
echo "exit;"                                                        >> loginbytoken_J13_IP_Susan-2.scr

# Create loginbytoken_IP_Prem.scr
echo "Output 1 \"%OUT\";"                                           >  loginbytoken_J13_IP_Prem-2.scr
echo "loginbytoken \"%HOST\" \"`cat token_J13_IP_Prem-1.out`\";"    >> loginbytoken_J13_IP_Prem-2.scr
echo "Output 3;"                                                    >> loginbytoken_J13_IP_Prem-2.scr
echo "Logout;"                                                      >> loginbytoken_J13_IP_Prem-2.scr
echo "exit;"                                                        >> loginbytoken_J13_IP_Prem-2.scr

#  A special case for essexer:

echo "Output 1 \"%OUT\";"                                           >  loginbytoken_J13_AD_essexer.scr
echo "login  \"localhost\" \"essexer\" \"password\";"               >> loginbytoken_J13_AD_essexer.scr
echo "select  \"agsyCSS1\" \"Basic\";"                              >> loginbytoken_J13_AD_essexer.scr
echo "getdbinfo;"                                                   >> loginbytoken_J13_AD_essexer.scr
echo "Output 3;"                                                    >> loginbytoken_J13_AD_essexer.scr
echo "Logout;"                                                      >> loginbytoken_J13_AD_essexer.scr
echo "exit;"                                                        >> loginbytoken_J13_AD_essexer.scr

# Create loginbytoken_AD_Andrew.scr
echo "Output 1 \"%OUT\";"                                           >  loginbytoken_J13_AD_Andrew-2.scr
echo "loginbytoken \"%HOST\" \"`cat token_J13_AD_Andrew-1.out`\";"  >> loginbytoken_J13_AD_Andrew-2.scr
#echo "select  \"agsyCSS1\" \"Basic\";"                             >> loginbytoken_J13_AD_Andrew-2.scr
#echo "import  \"2\" \"Agsytxt\" \"4\" \"n\" \"Y\";"                >> loginbytoken_J13_AD_Andrew-2.scr
#echo "getdbinfo;"                                                  >> loginbytoken_J13_AD_Andrew-2.scr
echo "Output 3;"                                                    >> loginbytoken_J13_AD_Andrew-2.scr
echo "Logout;"                                                      >> loginbytoken_J13_AD_Andrew-2.scr
echo "exit;"                                                        >> loginbytoken_J13_AD_Andrew-2.scr

# Create loginbytoken_AD_Bao.scr
echo "Output 1 \"%OUT\";"                                           >  loginbytoken_J13_AD_Bao-2.scr
echo "loginbytoken \"%HOST\" \"`cat token_J13_AD_Bao-1.out`\";"     >> loginbytoken_J13_AD_Bao-2.scr
echo "Output 3;"                                                    >> loginbytoken_J13_AD_Bao-2.scr
echo "Logout;"                                                      >> loginbytoken_J13_AD_Bao-2.scr
echo "exit;"                                                        >> loginbytoken_J13_AD_Bao-2.scr

# Create loginbytoken_AD_Jeff.scr
echo "Output 1 \"%OUT\";"                                           >  loginbytoken_J13_AD_Jeff-2.scr
echo "loginbytoken \"%HOST\" \"`cat token_J13_AD_Jeff-1.out`\";"    >> loginbytoken_J13_AD_Jeff-2.scr
echo "Output 3;"                                                    >> loginbytoken_J13_AD_Jeff-2.scr
echo "Logout;"                                                      >> loginbytoken_J13_AD_Jeff-2.scr
echo "exit;"                                                        >> loginbytoken_J13_AD_Jeff-2.scr

# Create loginbytoken_AD_John.scr
echo "Output 1 \"%OUT\";"                                           >  loginbytoken_J13_AD_John-2.scr
echo "loginbytoken \"%HOST\" \"`cat token_J13_AD_John-1.out`\";"    >> loginbytoken_J13_AD_John-2.scr
echo "Output 3;"                                                    >> loginbytoken_J13_AD_John-2.scr
echo "Logout;"                                                      >> loginbytoken_J13_AD_John-2.scr
echo "exit;"                                                        >> loginbytoken_J13_AD_John-2.scr

# Create loginbytoken_AD_anguyen.scr
echo "Output 1 \"%OUT\";"                                           >  loginbytoken_J13_AD_anguyen-2.scr
echo "loginbytoken \"%HOST\" \"`cat token_J13_AD_anguyen-1.out`\";" >> loginbytoken_J13_AD_anguyen-2.scr
echo "createapp \"App_AN\";"                                        >> loginbytoken_J13_AD_anguyen-2.scr
echo "Output 3;"                                                    >> loginbytoken_J13_AD_anguyen-2.scr
echo "Logout;"                                                      >> loginbytoken_J13_AD_anguyen-2.scr
echo "exit;"                                                        >> loginbytoken_J13_AD_anguyen-2.scr

# Create loginbytoken_AD_bnguyen.scr
echo "Output 1 \"%OUT\";"                                           >  loginbytoken_J13_AD_bnguyen-2.scr
echo "loginbytoken \"%HOST\" \"`cat token_J13_AD_bnguyen-1.out`\";" >> loginbytoken_J13_AD_bnguyen-2.scr
echo "createapp \"App_BN-2\";"                                      >> loginbytoken_J13_AD_bnguyen-2.scr
echo "createdb  \"App_BN-2\" \"Basic\";"                            >> loginbytoken_J13_AD_bnguyen-2.scr
echo "createuser \"user_BN-2\" \"password\";"                       >> loginbytoken_J13_AD_bnguyen-2.scr
echo "listusers;"                                                   >> loginbytoken_J13_AD_bnguyen-2.scr
echo "listdb;"                                                      >> loginbytoken_J13_AD_bnguyen-2.scr
echo "select  \"App_BN-2\" \"Basic\";"                              >> loginbytoken_J13_AD_bnguyen-2.scr
echo "unloadapp \"App_BN-2\";"                                      >> loginbytoken_J13_AD_bnguyen-2.scr
echo "deleteapp \"App_BN-2\";"                                      >> loginbytoken_J13_AD_bnguyen-2.scr
echo "Output 3;"                                                    >> loginbytoken_J13_AD_bnguyen-2.scr
echo "Logout;"                                                      >> loginbytoken_J13_AD_bnguyen-2.scr
echo "exit;"                                                        >> loginbytoken_J13_AD_bnguyen-2.scr

# Create loginbytoken_AD_cnguyen.scr
echo "Output 1 \"%OUT\";"                                           >  loginbytoken_J13_AD_cnguyen-2.scr
echo "loginbytoken \"%HOST\" \"`cat token_J13_AD_cnguyen-1.out`\";" >> loginbytoken_J13_AD_cnguyen-2.scr
echo "createuser \"user_CN-2\" \"passowrd\";"                       >> loginbytoken_J13_AD_cnguyen-2.scr
echo "createapp \"App_CN-2\";"                                      >> loginbytoken_J13_AD_cnguyen-2.scr
echo "Output 3;"                                                    >> loginbytoken_J13_AD_cnguyen-2.scr
echo "Logout;"                                                      >> loginbytoken_J13_AD_cnguyen-2.scr
echo "exit;"                                                        >> loginbytoken_J13_AD_cnguyen-2.scr

# Create loginbytoken_AD_enguyen.scr
echo "Output 1 \"%OUT\";"                                            >  loginbytoken_J13_AD_enguyen-2.scr
echo "loginbytoken \"%HOST\" \"`cat token_J13_AD_enguyen-1.out`\";"  >> loginbytoken_J13_AD_enguyen-2.scr
echo "loadapp  \"agsyCSS1\";"                                        >> loginbytoken_J13_AD_enguyen-2.scr
echo "Output 3;"                                                     >> loginbytoken_J13_AD_enguyen-2.scr
echo "Logout;"                                                       >> loginbytoken_J13_AD_enguyen-2.scr
echo "exit;"                                                         >> loginbytoken_J13_AD_enguyen-2.scr

# Create loginbytoken_AD_hnguyen.scr
echo "Output 1 \"%OUT\";"                                           >  loginbytoken_J13_AD_hnguyen-2.scr
echo "loginbytoken \"%HOST\" \"`cat token_J13_AD_hnguyen-1.out`\";" >> loginbytoken_J13_AD_hnguyen-2.scr
echo "createapp \"App_HN-2\";"                                      >> loginbytoken_J13_AD_hnguyen-2.scr
echo "createdb  \"App_HN-2\" \"Basic\";"                            >> loginbytoken_J13_AD_hnguyen-2.scr
echo "createuser \"user_HN-2\" \"passowrd\";"                       >> loginbytoken_J13_AD_hnguyen-2.scr
# echo "select  \"agsyCSS1\" \"Basic\";"                            >> loginbytoken_J13_AD_hnguyen-2.scr
# echo "import  \"2\" \"Agsytxt\" \"4\" \"n\" \"Y\";"               >> loginbytoken_J13_AD_hnguyen-2.scr
# echo "listusers;"                                                 >> loginbytoken_J13_AD_hnguyen-2.scr
echo "unloadapp \"App_HN-2\";"                                      >> loginbytoken_J13_AD_hnguyen-2.scr
echo  "deleteapp \"App_HN-2\";"                                     >> loginbytoken_J13_AD_hnguyen-2.scr
echo "Output 3;"                                                    >> loginbytoken_J13_AD_hnguyen-2.scr
echo "Logout;"                                                      >> loginbytoken_J13_AD_hnguyen-2.scr
echo "exit;"                                                        >> loginbytoken_J13_AD_hnguyen-2.scr

chmod 777 *scr
cp *scr ../scr



#####################################################################################
# LoginByToken Part 1: Token lasts for 10 minusts
##################################################################################


sxr esscmd -q loginbytoken_J13_IP_azhang-2.scr %HOST=$HOST %OUT=loginbytoken_J13_IP_azhang-2.out
sxr esscmd -q loginbytoken_J13_IP_Jeff-2.scr   %HOST=$HOST %OUT=loginbytoken_J13_IP_Jeff-2.out
sxr esscmd -q loginbytoken_J13_IP_Susan-2.scr  %HOST=$HOST %OUT=loginbytoken_J13_IP_Susan-2.out
sxr esscmd -q loginbytoken_J13_IP_Prem-2.scr   %HOST=$HOST %OUT=loginbytoken_J13_IP_Prem-2.out

# sxr esscmd -q loginbytoken_J13_AD_essexer.scr %HOST=$HOST %OUT=loginbytoken_J13_AD_essexer.out
sxr esscmd -q loginbytoken_J13_AD_Andrew-2.scr %HOST=$HOST %OUT=loginbytoken_J13_AD_Andrew-2.out
sxr esscmd -q loginbytoken_J13_AD_Bao-2.scr    %HOST=$HOST %OUT=loginbytoken_J13_AD_Bao-2.out
sxr esscmd -q loginbytoken_J13_AD_Jeff-2.scr   %HOST=$HOST %OUT=loginbytoken_J13_AD_Jeff-2.out
sxr esscmd -q loginbytoken_J13_AD_John-2.scr   %HOST=$HOST %OUT=loginbytoken_J13_AD_John-2.out

sxr esscmd -q loginbytoken_J13_AD_anguyen-2.scr %HOST=$HOST %OUT=loginbytoken_J13_AD_anguyen-2.out
sxr esscmd -q loginbytoken_J13_AD_bnguyen-2.scr %HOST=$HOST %OUT=loginbytoken_J13_AD_bnguyen-2.out
sxr esscmd -q loginbytoken_J13_AD_cnguyen-2.scr %HOST=$HOST %OUT=loginbytoken_J13_AD_cnguyen-2.out
sxr esscmd -q loginbytoken_J13_AD_enguyen-2.scr %HOST=$HOST %OUT=loginbytoken_J13_AD_enguyen-2.out
sxr esscmd -q loginbytoken_J13_AD_hnguyen-2.scr %HOST=$HOST %OUT=loginbytoken_J13_AD_hnguyen-2.out

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

compare_result loginbytoken_J13_IP_azhang-2.out  loginbytoken_J13_IP_azhang-2.bas
compare_result loginbytoken_J13_IP_Jeff-2.out    loginbytoken_J13_IP_Jeff-2.bas
compare_result loginbytoken_J13_IP_Susan-2.out   loginbytoken_J13_IP_Susan-2.bas
compare_result loginbytoken_J13_IP_Prem-2.out    loginbytoken_J13_IP_Prem-2.bas

compare_result loginbytoken_J13_AD_Andrew-2.out  loginbytoken_J13_AD_Andrew-2.bas
compare_result loginbytoken_J13_AD_Bao-2.out     loginbytoken_J13_AD_Bao-2.bas
compare_result loginbytoken_J13_AD_Jeff-2.out    loginbytoken_J13_AD_Jeff-2.bas
compare_result loginbytoken_J13_AD_John-2.out    loginbytoken_J13_AD_John-2.bas

compare_result loginbytoken_J13_AD_anguyen-2.out  loginbytoken_J13_AD_anguyen-2.bas
compare_result loginbytoken_J13_AD_bnguyen-2.out  loginbytoken_J13_AD_bnguyen-2.bas
compare_result loginbytoken_J13_AD_cnguyen-2.out  loginbytoken_J13_AD_cnguyen-2.bas
compare_result loginbytoken_J13_AD_enguyen-2.out  loginbytoken_J13_AD_enguyen-2.bas
compare_result loginbytoken_J13_AD_hnguyen-2.out  loginbytoken_J13_AD_hnguyen-2.bas

