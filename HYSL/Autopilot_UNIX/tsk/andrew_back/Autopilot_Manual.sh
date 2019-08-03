
32 bits:  vi agsf_createusrgrp.sog
++ sxr shell agsf_createusrgrp.sh /net/nar200/vol/vol3/essbasesxr/11122200/vobs/essexer/base/data/agsf_user_groups.py weblogic wel
come1 /net/nar200/vol/vol3/essbasesxr/11122200/vobs/essexer/base/data/agsf_usrgrp.properties
++ Essexer 2.20 - Production on Fri Feb  1 10:08:09 PST 2013
++

/net/nar200/vol/vol3/essbasesxr/11122200/vobs/essexer/base/data/agsf_usrgrp.properties
/net/nar200/vol/vol3/essbasesxr/11122200/vobs/essexer/base/sh/agsf_createusrgrp.sh[18]: cd: /scratch/anzhang/hyperion/11.1.2.2.200
_FA_AMD64/jrockit_160_24_D1.1.2-4/jre/lib/i386/jrockit/wlserver_10.3/server/bin: [No such file or directory]
/net/nar200/vol/vol3/essbasesxr/11122200/vobs/essexer/base/sh/agsf_createusrgrp.sh[19]: .: ./setWLSEnv.sh: cannot open [No such fi
le or directory]
~


64 bits 
++
++ sxr shell agsf_createusrgrp.sh /net/nar200/vol/vol3/essbasesxr/11122200/vobs/essexer/base/data/agsf_user_groups.py weblogic welcome1 
/net/nar200/vol/vol3/essbasesxr/11122200/vobs/essexer/base/data/agsf_usrgrp.properties
++ Essexer 2.20 - Production on Thu Jan 31 17:48:10 PST 2013
++

/net/nar200/vol/vol3/essbasesxr/11122200/vobs/essexer/base/data/agsf_usrgrp.properties
CLASSPATH=/scratch/anzhang/hyperion/11.1.2.2.200_FA_AMD64/patch_wls1035/profiles/default/sys_manifest_classpath/weblogic_patch.jar:
/scratch/anzhang/hyperion/11.1.2.2.200_FA_AMD64/Oracle_BI1/jdk/lib/tools.jar:/scratch/anzhang/hyperion/11.1.2.2.200_FA_AMD64/wlserver_10.3
/server/lib/weblogic_sp.jar:/scratch/anzhang/hyperion/11.1.2.2.200_FA_AMD64/wlserver_10.3/server/lib/weblogic.jar:/scratch/anzhang/hyperion/11.1.2.2.200_FA_AMD64
/modules/features/weblogic.server.modules_10.3.5.0.jar:/scratch/anzhang/hyperion/11.1.2.2.200_FA_AMD64/wlserver_10.3/server/lib/webservices.jar:/scratch/anzhang/hyperion
/11.1.2.2.200_FA_AMD64/modules/org.apache.ant_1.7.1/lib/ant-all.jar:/scratch/anzhang/hyperion/11.1.2.2.200_FA_AMD64/modules/net.sf.antcontrib_1.1.0.0_1-0b2/lib/ant-contrib.jar:

PATH=/scratch/anzhang/hyperion/11.1.2.2.200_FA_AMD64/wlserver_10.3/server/bin:/scratch/anzhang/hyperion/11.1.2.2.200_FA_AMD64/modules/org.apache.ant_1.7.1/bin:
/scratch/anzhang/hyperion/11.1.2.2.200_FA_AMD64/Oracle_BI1/jdk/jre/bin:/scratch/anzhang/hyperion/11.1.2.2.200_FA_AMD64/Oracle_BI1/jdk/bin:
/scratch/anzhang/views/agsfmain_5027/bin:/scratch/anzhang/hyperion/11.1.2.2.200_FA_AMD64/instances/instance1/bin:
/scratch/anzhang/hyperion/11.1.2.2.200_FA_AMD64/wlserver_10.3/common/bin:/scratch/anzhang/hyperion/11.1.2.2.200_FA_AMD64/Oracle_BI1/clients/epm/Essbase/EssbaseRTC/bin:
/scratch/anzhang/hyperion/11.1.2.2.200_FA_AMD64/Oracle_BI1/../instances/instance1/Essbase/essbaseserver1/bin:
/scratch/anzhang/hyperion/11.1.2.2.200_FA_AMD64/Oracle_BI1/products/Essbase/EssbaseServer/bin:/scratch/anzhang/hyperion/11.1.2.2.200_FA_AMD64/Oracle_BI1/jdk/jre/bin:
/usr/bin:/net/nar200/vol/vol3/essbasesxr/mainline/vobs/essexer/autopilot/bin:.:/bin:/usr/sbin:/usr/X11R6/bin:/etc:
/usr/local/bin:/net/nar200/vol/vol2/pre_rel/essbase/builds/common/bin:/net/nar200/vol/vol3/essbasesxr/11122200/vobs/essexer/latest/bin


 
 
sxr sh calculate.sh
mv $SXR_VIEWHOME/work $SXR_VIEWHOME/work_calculate1
mkdir  $SXR_VIEWHOME/work

sxr sh calculate.sh
mv $SXR_VIEWHOME/work $SXR_VIEWHOME/work_calculate2
mkdir $SXR_VIEWHOME/work

sxr sh calculate.sh
mv $SXR_VIEWHOME/work $SXR_VIEWHOME/work_calculate3
kdir $SXR_VIEWHOME/work

#sxr sh agsymain.sh
#mv $SXR_VIEWHOME/work $SXR_VIEWHOME/work_agsymain
#mkdir $SXR_VIEWHOME/work

sxr sh apbgmain.sh
mv $SXR_VIEWHOME/work $SXR_VIEWHOME/work_apbgmain
mkdir $SXR_VIEWHOME/work

sxr sh apgdmain.sh
mv $SXR_VIEWHOME/work $SXR_VIEWHOME/work_apgdmain
mkdir  $SXR_VIEWHOME/work

sxr sh apgemain.sh
mv $SXR_VIEWHOME/work $SXR_VIEWHOME/work_apgemain
mkdir $SXR_VIEWHOME/work




sxr sh dmudmain.sh
mv $SXR_VIEWHOME/work $SXR_VIEWHOME/work_dmudmain
mkdir $SXR_VIEWHOME/work

sxr sh dresmain.sh
mv $SXR_VIEWHOME/work $SXR_VIEWHOME/work_dresmain
mkdir $SXR_VIEWHOME/work

sxr sh dxbgmain.sh
mv $SXR_VIEWHOME/work $SXR_VIEWHOME/work_dxbgmain
mkdir $SXR_VIEWHOME/work

sxr sh dxmdmain.sh
mv $SXR_VIEWHOME/work $SXR_VIEWHOME/work_dxmdmain
mkdir $SXR_VIEWHOME/work

sxr sh dxrrmain.sh
mv $SXR_VIEWHOME/work $SXR_VIEWHOME/work_dxrrmain
mkdir $SXR_VIEWHOME/work

sxr sh dxssmain.sh
mv $SXR_VIEWHOME/work $SXR_VIEWHOME/work_dxssmain
mkdir $SXR_VIEWHOME/work

sxr sh maxlmain.sh
mv $SXR_VIEWHOME/work $SXR_VIEWHOME/work_maxlmain
mkdir $SXR_VIEWHOME/work

sxr sh msscmain.sh
mv $SXR_VIEWHOME/work $SXR_VIEWHOME/work_msscmain
mkdir $SXR_VIEWHOME/work

sxr sh sdatmain.sh
mv $SXR_VIEWHOME/work $SXR_VIEWHOME/work_sdatmain
mkdir $SXR_VIEWHOME/work

sxr sh sdbgmain.sh
mv $SXR_VIEWHOME/work $SXR_VIEWHOME/work_sdbgmain
mkdir $SXR_VIEWHOME/work

sxr sh sddbmain.sh
mv $SXR_VIEWHOME/work $SXR_VIEWHOME/work_sddbmain
mkdir $SXR_VIEWHOME/work

sxr sh sdremain.sh
mv $SXR_VIEWHOME/work $SXR_VIEWHOME/work_sdremain
mkdir $SXR_VIEWHOME/work


