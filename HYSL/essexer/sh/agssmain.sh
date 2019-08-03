#---------------------#
# date   : 5/12/10    #
# author : bao nguyen #
#---------------------#

# Description : testing user provisioning for Essbase Talleyrand

#: GTLF_testunit: HSS_Security_mode

# History
#       7/4/12 -- create GTLF unittest name
#      09/05/2012 - Hima Vuggumudi, Added agbg12735432.sh
#      09/05/2012 - Hima Vuggumudi, Added agbg13075833.sh
#      09/05/2012 - bao nguyen, change agsycasmain.sh to agssmain.sh
#      03/17/2012 - bao nguyen, add to build it's app
#      10/01/2013 - Hima Vuggumudi, updated 'GTLF_testunit' from ESS_User_Provisioning to HSS_Security_mode
#--------------------------------------Main----------------------------------#
# setup
sxr sh agsycassetup_new.sh

# running native user
sxr sh agsycasHSScase1TR.sh
sxr sh agsycasHSScase2TR.sh
sxr sh agsycasHSScase3TR.sh

# running ldap external provider
sxr sh agsycasLDAPcase1TR.sh
sxr sh agsycasLDAPcase2TR.sh
sxr sh agsycasLDAPcase3TR.sh
sxr sh agsycasMSADcase1TR.sh
sxr sh agsycasMSADcase2TR.sh

# running user identity
sxr sh agsycasusrid.sh

# running native test for external
# sxr sh agsyexauthhss.sh # need some manual steps

# run all bugs
sxr sh agbg72137710.sh # need msad users
sxr sh agbg6886886a.sh # need msad users
sxr sh agbg6886886b.sh # need msad users

sxr sh agbg222828529c1.sh
sxr sh agbg222828529c2.sh
sxr sh agbg222828539c6.sh
sxr sh agbg222828539c8.sh
sxr sh agbg222828529c14.sh

sxr sh agbg12972697.sh

sxr sh agbg13075833.sh
sxr sh agbg12735432.sh
