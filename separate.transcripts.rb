#!/usr/bin/ruby

hybridTranscriptFa = File.open(ARGV[0]).readlines
desiredEco = ARGV[1]
targetFile = File.open(ARGV[2], 'w')

hybridTranscriptFa.each_slice(2) do |transcript|
  if transcript[0].include? desiredEco then
    if transcript[1].length > 50 then
      targetFile.puts transcript[0]
      targetFile.puts transcript[1]
    end
  end
end

targetFile.close
