#!/bin/bash

accessions=`cat SRR_Acc_List.txt`

for i in $accessions; do
  fils=`ls -f`
  if !  echo "$fils" | grep -q "${i}.*fastq"; then
    echo -e "\n\e[92mfiles for accession $i not found, downloading now...\n\e[0m"
    ~/sratoolkit.2.9.6-1-ubuntu64/bin/fasterq-dump -e 4 $i -t ./${i}.tmp
else
  echo -e "\n\e[96mfiles for accession $i have been found, omitting download...\n\e[0m"
  fi
done
