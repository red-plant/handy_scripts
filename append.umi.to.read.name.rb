#!/usr/bin/ruby
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
