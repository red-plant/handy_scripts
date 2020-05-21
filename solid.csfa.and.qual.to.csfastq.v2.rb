#!/usr/bin/ruby
csFaFile = File.open(ARGV[0])
qualFile = File.open(ARGV[1])
csFqFile = File.open(ARGV[2], "w")

until csFaFile.eof
  line1 = csFaFile.gets.tr(">", "@")
  line2 = csFaFile.gets
  line3 = qualFile.gets.tr(">", "+")
  phredsAsList=qualFile.gets.split(" ")
  phred33=phredsAsList.map{ |phredsAsList| (phredsAsList.to_i+33).chr}
  line4=phred33.join
  csFqFile.puts "%s" % line1
  csFqFile.puts "%s" % line2
  csFqFile.puts "%s" % line3
  csFqFile.puts "%s" % line4
end

csFaFile.close
qualFile.close
csFqFile.close