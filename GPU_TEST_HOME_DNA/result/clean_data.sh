# command line: "clean_data.sh 170222"
# remove all line start with anno_path

if [ $# != 1 ]; then
    echo "You need one argument of date in format like: 170222 (as Feb. 22, 2017)"
    exit
fi

echo "Your file to be converted is: $1"
sleep 1

# 1a) Remove the empty lines:
sed '/^$/d' anno_stat_result_${1}.csv > anno_stat_result_${1}.csv_no_space
mv anno_stat_result_${1}.csv_no_space anno_stat_result_${1}.csv

# 1) Remove the line with words "anno_path"
sed -e '/anno_path/d' anno_stat_result_${1}.csv  > anno_stat_result_${1}.csv_new
mv  anno_stat_result_${1}.csv_new anno_stat_result_${1}.csv 

# 2) Remove the line with run name only, such as: 
# "/home/genia/rigdata/aerodactyl/170221_TAG_01_aerodactyl_WAE22R13C08/P_00_170221202836_ggc3-k"
# see for reference: http://unix.stackexchange.com/questions/171091/remove-lines-based-on-duplicates-within-one-column-without-sort
awk -F' ' 'seen[$1]++' anno_stat_result_${1}.csv > anno_stat_result_${1}_mid.csv
mv  anno_stat_result_${1}_mid.csv anno_stat_result_${1}.csv

# 3) Add the line to the top:
echo "anno_path 1-neg_high_max 2-neg_high_min 3-neg_low_max 4-neg_low_min 5-pos_high_max 6-pos_high_min 7-pos_low_max 8-pos_low_min 9-num_functional_seq_pores 10-avg_homopolymer_edit_accuracy 11-avg_procession_length 12-N50_procession_length 13-total_procession_length 14-neg_low_mean 15-neg_low_std 16-neg_low_var" > new_file; cat  anno_stat_result_${1}.csv >> new_file; mv  new_file anno_stat_result_${1}.csv 

echo -e "\nThe converted file is anno_stat_result_filt_${1}.csv"

# now you can read the file by the pandas: 
# anno_result = pd.read_csv('../result/anno_stat_result_filt_170222.csv', delimiter = ' ')


