
# gpuTestMain.sh $1 $2 $3 $4
# gpuTestMain.sh 160729 aipom 160729_SIG-A_01_aipom_WAG25R08C19 00
# 
# Command line: getTodayAnnotations.sh 160727 gpu_list.txt
# Then: sed -i 's/160729/160728/g' run_command_line_160728.sh

# 2016/08/08 Re-run after the fix:
gpuTest2-1_compare.sh 160722 flareon 160722_SIG-A_01_flareon_WAQ20R13C04 P_00_160722193623_s16-master_ac-analysis_v11.10.0.dev.siga_3.2

gpuTest2-1_compare.sh 160729 aipom 160729_SIG-A_01_aipom_WAG25R08C19 P_02_160802010452_spore1-master_ac-analysis_v11.12.0
gpuTestMain.sh 160727 aipom 160727_SIG-A_02_aipom_WAG25R08C19
gpuTestMain.sh 160728 beedril 160728_SIG-A_01_beedril_WAQ22R07C10


gpuTest2-1_compare.sh
gpuTest2-1_compare.sh
gpuTest2-1_compare.sh

# Failed with KeyError: u'oc_calibration_rail_fraction'. still  a lot from nohup_0804.out
gpuTestMain.sh 160803 zubat 160803_ENG-SYS_01_zubat_WAQ23R11C11 P_00_160804002514_s16-master_ac-analysis_v11.12.0


# 0806: This one sees hanging:
gpuTest2-1_compare.sh 160804 aipom 160804_SIG-A_02_aipom_WAQ19R09C19 P_00_160804191405_s16-master_ac-analysis_v11.10.0.dev.siga_3.2


gpuTest2-1_compare.sh 160804 alakazam 160804_TAG_02_alakazam_WAQ19R06C07 P_00_160804225016_s16-master_ac-analysis_v11.12.0

gpuTest2-1_compare.sh 160804 alakazam 160804_TAG_02_alakazam_WAQ19R06C07 P_00_160804225016_s16-master_ac-analysis_v11.12.0


# Good samples:

gpuTest2-1_compare.sh 160804 aerodactyl 160804_TAG_01_aerodactyl_WAQ24R09C06 P_00_160804183653_s16pre-master_ac-analysis_v11.12.0


# New issus with KeyError:

gpuTest2-1_compare.sh 160804 zubat 160804_ENG-SYS_01_zubat_WAQ24R06C15 P_00_160804175649_s16pre-master_ac-analysis_v11.12.0

gpuTest2-1_compare.sh 160812 slowking 160815_ENG-SYS_02_slowking_WAQ23R09C07 P_00_160816001844_s16pre-master_ac-analysis_v11.12.0

# test snai_1720
gpuTest2-1_compare.sh 160804 gary 160804_SIG-A_02_gary_WAQ23R05C12 P_00_160804192520_s16pre-master_ac-analysis_v11.10.0.dev.siga_3.2

# 160810 Test snail 1702
gpuTest2-1_compare.sh 160804 eevee 160802_SW_02_eevee_WT05R13C12 P_00_160802231301_s16pre-master_ac-analysis_v11.12.0
gpuTest2-1_compare.sh 160804 eevee 160802_SW_02_eevee_WT05R13C12 P_02_160811172413_spore1-master_ac-analysis_v11.12.2

gpuTest2-1_compare.sh 160804 cleffa 160802_ENG-SYS_05_cleffa_WAG19R07C02 P_00_160803001535_s16-master_ac-analysis_v11.12.0 

gpuTest2-1_compare.sh 160804 cleffa 160802_ENG-SYS_03_cleffa_WAG19R07C02 P_00_160802201454_s16-master_ac-analysis_v11.12.0

gpuTest2-1_compare.sh 160804 diglett 160802_TAG_03_diglett_WAQ19R10C11 P_00_160803011140_spotty-master_ac-analysis_v11.12.0

# 160811 
gpuTest2-1_compare.sh 160811 aipom 160811_SIG-A_04_aipom_WAQ24R14C09 P_00_160812010759_s16-master_ac-analysis_v11.12.0

gpuTest2-1_compare.sh 160812 spearow 160812_ENG-SYS_04_spearow_WAQ24R11C12 P_00_160812213601_s16-master_ac-analysis_v11

# # 160817 Debug for "Error: Annotation is missing from annotation.snail file: oc_calibration_rail_fraction"
 160817_SIG-A_01_ash_WAG20R10C01 

# 161103_SW_01_eevee_WAI11R11C16
gpuTest2-1_compare.sh 161103 eevee 161103_SW_01_eevee_WAI11R11C16 P_00_161103153221_s16pre-master_ac-analysis_v11.16.0

# 161102_SW_02_eevee_WAI11R11C16
gpuTest2-1_compare.sh 161103 eevee 161102_SW_02_eevee_WAI11R11C16 P_00_161103154857_ggc5-keeper_ac-analysis_v11.16.0 


