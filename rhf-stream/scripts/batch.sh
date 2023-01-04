#!/bin/bash

i=3;
j=$#;
pref=$1
shift 1;
suff=$1
shift 1;
while [ $i -le $j ] 
do
    eval "nohup nice python -u batch_time_script.py $1 > ${pref}/${1}_infres_batch_x10_${suff}.txt &";
    i=$((i + 1));
    shift 1;
done
