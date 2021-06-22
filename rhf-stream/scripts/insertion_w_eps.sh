#!/bin/bash

i=3;
j=$#;
pref=$1
shift 1;
suff=$1
shift 1;
eps=$1
shift 1;
while [ $i -le $j ] 
do
    eval "nohup nice python3 -u insertion_script.py $1 100 5 10 ${eps} 0 1 > ${pref}/${1}_infres_eps${eps}_x10_${suff}.txt &";
    i=$((i + 1));
    shift 1;
done
