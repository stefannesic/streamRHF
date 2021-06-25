#!/bin/bash

i=3;
j=$#;
pref=$1
shift 1;
suff=$1
shift 1;
init=$1
shift 1;
while [ $i -le $j ] 
do
    eval "nohup nice python3 -u windowed_batch_script.py $1 $init > ${pref}/${1}_infres_windowed_batch_size${init}_x10_${suff}.txt &";
    i=$((i + 1));
    shift 1;
done
