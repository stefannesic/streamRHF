#!/bin/bash

i=5;
j=$#;
pref=$1
shift 1;
suff=$1
shift 1;
init=$1;
shift 1;
shuff=$1
shift 1;
const=$1
shift 1;
while [ $i -le $j ] 
do
    eval "nohup nice python3 -u insertion.py $1 100 5 10 ${init} ${shuff} ${const} > ${pref}/${1}_infres_init${init}_x10_s${shuff}_c${const}_${suff}.txt &";
    i=$((i + 1));
    shift 1;
done
