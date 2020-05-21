#!/usr/bin/ruby
csFqFile = File.open(ARGV[0], 'r')
fixedCsFqFile = File.open(ARGV[0].dup.concat('.fixed.fq'), 'w')
readLength = ARGV[1].to_i

i=1
until csFqFile.eof
  readSeqNam = csFqFile.gets.chomp
  if ! readSeqNam.start_with? '@'
      $stderr.puts("Bad seq name line skipped: ".concat(i.to_s))
      i=i+1
    next
  end
  readSeq = csFqFile.gets.chomp
  if ! readSeq.start_with? 'T'
      $stderr.puts("Bad seq line skipped: ".concat(i.to_s))
      i=i+1
    next
  end
  readQualNam = csFqFile.gets.chomp
  if ! readQualNam.start_with? '+'
      $stderr.puts("Bad read qual line name skipped: ".concat(i.to_s))
      i=i+1
    next
  end
  readQual = csFqFile.gets.chomp
  if readSeq.length == readLength + 1 then
    if readQual.length == readLength then
      fixedCsFqFile.puts readSeqNam
      fixedCsFqFile.puts readSeq
      fixedCsFqFile.puts readQualNam
      fixedCsFqFile.puts readQual
    else
      $stderr.puts("Bad qual skipped: ".concat(i.to_s))
    end
  else
    $stderr.puts("Bad seq skipped: ".concat(i.to_s))
  end
  i=i+1
end

csFqFile.close
fixedCsFqFile.close
