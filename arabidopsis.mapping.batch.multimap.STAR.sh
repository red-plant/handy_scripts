#!/bin/bash

#This script maps fastq files against the genome using STAR (must be in path). Considers multimappers and 
#uses the 2-pass mode. Is suited for arabidopsis, although considering multimappers and the two-pass mode might not be necesary
#for arabidopsis, depending on the application (usually only ~2% of reads are multimappers and there is basically no
#difference with two-pass mode). This was writen for a strain different than Col-0, for which splice sites might not be
#annotated. Will map all fastq.gz files and make a folder for each (or each pairof files -F -R). Requires pigz. Outputs BAM.

#Run inside the directory with the fastq files
#Expects the name format: sampleName-[FR].fastq.gz, if paired end, sampleName.fastq.gz if single

genomePath='FULL GENOME PATH HERE'
outPrefix='PATH TO FOLDER TO COUNTAIN STAR.quant FOLDER here'

echo 'starting mapping, considering multimappers'
files=($(ls | grep fastq.gz | sort))
fileNum=`ls | grep fastq.gz | wc -l`
counter=0

while [ $counter -lt $fileNum ]; do

  currentFile=`echo ${files[$counter]}`
  nextFile=`echo ${files[$counter + 1]}`
  fileBasename=`echo ${files[$counter]} | sed 's_\.fastq\.gz__' | sed 's_-[FR]__'`

  STARcommand='STAR --runThreadN 20 --genomeDir '$genomeDir' --alignIntronMax 900 --alignMatesGapMax 900 --readFilesCommand pigz -d -c --outSAMtype BAM Unsorted --twopassMode Basic  --readFilesIn '$currentFile
  if echo ${files[$counter]} | grep '\-F'
   then
    STARcommand=${STARcommand}' '$nextFile
    let counter=$counter+2

   else
    let counter=$counter+1
  fi

  mkdir ${outPrefix}${fileBasename}.STAR.quant/
  STARcommand=${STARcommand}' --outFileNamePrefix ${outPrefix}${fileBasename}.STAR.quant/
  echo $STARcommand
  $STARcommand
  echo '\nfinished '$counter' out of '$fileNum

done
