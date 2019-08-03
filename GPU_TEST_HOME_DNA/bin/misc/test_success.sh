export P_NUM=P_00_160813004931_s16-master_ac-analysis_v11.12.0
export station_name=ash
export run_name=160812_SIG-A_02_ash_WAQ24R13C13

grep success $RUN_LOC/$station_name/$run_name/$P_NUM/.merge.result

if [ $? -eq 0 ];then
    echo "Test is successful"
else
    echo "Test is faild!"
fi


