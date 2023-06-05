#!/usr/bin/ruby

#This code takes 3 input arguments (3 fastq files) one with mate1, one with mate2 and one with an UMI.
# And 2 output arguments: tagged mate 1 and tagged mate2 fastq files. This is for when you have them
# in different fastq files and need to append the UMI to the read name in their mate 1 and mate 2 
# files to use with standard de-duplication tools.

#To run this in multiple files do something like the following (assuming you have them named 
# .*_R1_.* for mate1, .*_R2_.* for UMI, and .*_R3_.* for mate2).

#for sampl in $sampls; do

#  mateOneTag="${sampl}_R1_001.tagged.fastq"
#  mateTwoTag="${sampl}_R3_001.tagged.fastq"
#  mateOne="${sampl}_R1_001.fastq"
#  mateTwo="${sampl}_R3_001.fastq"
#  UMI="${sampl}_R2_001.fastq"
#  pigz -d -p 4 -b 500000 ${mateOne}.gz ${mateTwo}.gz ${UMI}.gz
#  eval "~/Documents/embryo.in.seed.project/scripts/append.umi.to.read.name.rb $mateOne $mateTwo $UMI $mateOneTag $mateTwoTag"
#  rm $mateOne $mateTwo $UMI
#  pigz -p 4 -b 500000 $mateOneTag $mateTwoTag

#done

mateOneFq = File.open(ARGV[0])
mateTwoFq = File.open(ARGV[1])
umiFq = File.open(ARGV[2])
mateOneFqTagged = File.open(ARGV[3], "w")
mateTwoFqTagged = File.open(ARGV[4], "w")

until umiFq.eof

  umiSeq = umiFq.take(4)[1].chomp
  mateOneFqTagged.puts (mateOneFq.gets.chomp.sub(" ", ("_" + umiSeq + " ")) + "\n")
  mateOneFqTagged.puts (mateOneFq.take(3))
  mateTwoFqTagged.puts (mateTwoFq.gets.chomp.sub(" ", ("_" + umiSeq + " ")) + "\n")
  mateTwoFqTagged.puts (mateTwoFq.take(3))

end

mateOneFq.close
mateTwoFq.close
umiFq.close
mateOneFqTagged.close
mateTwoFqTagged.close
