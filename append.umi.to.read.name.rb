#!/usr/bin/ruby

#This code takes 3 input arguments (3 fastq files) one with mate1, one with mate2 and one with an UMI.
# And 2 output arguments: tagged mate 1 and tagged mate2 fastq files. This is for when you have them
# in different fastq files and need to append the UMI to the read name in their mate 1 and mate 2 
# files to use with standard de-duplication tools

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
