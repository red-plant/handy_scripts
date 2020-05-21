#!/usr/bin/ruby

#This script takes a colour-space fasta file and a Phred scaled quality file, and converts them to a single fastq in colour
# space but with Phred33 scaled quality. 

#This was only possible thanks to Cary Swoveland from SO, because he is the best at ruby and I am a noob. Thanks Cary <3.

csFaFile = File.open(ARGV[0])
qualFile = File.open(ARGV[1])
csFqFile = File.open(ARGV[2], "w")

until csFaFile.eof
  line1 = csFaFile.gets.tr(">", "@")
  line2 = csFaFile.gets
  line3 = qualFile.gets.tr(">", "+")
  phredsAsList = qualFile.gets.split(" ")
  phred33 = phredsAsList.map{ |phredsAsList| (phredsAsList.to_i + 33).chr }
  line4 = phred33.join
  csFqFile.puts line1
  csFqFile.puts line2
  csFqFile.puts line3
  csFqFile.puts line4
end

csFaFile.close
qualFile.close
csFqFile.close
