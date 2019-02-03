#!/usr/bin/ruby

# Usage: cat sequence.to.edit.fa | ./replace.methylation.rb target.coordinates.csv character_to_replace_c character_to_replace_G > methylated.sequence.fa

# This will take a sequence (say chromosome fasta) from STDIN and a file with
# coordinates to replace as first argument. The coordinates file must be a csv
# table with the first column being the line number and the second the character number.
# F. example 1,2 will replace the second character of the first line. A character to replace 
# "C" is taken as second argument and a character to replace "G" is taken as third, they
# default to "M" and "L", respectively. Fasta file should not contain line breaks within 
# the sequence, unless you take that into account for the line coordinates (confusing).
# fasta sequence should be in all uppercase leters. 
# Outputs to STDOUT

require "csv"

sequence_to_edit = $stdin.readlines
target_coordinates = CSV.read(ARGV.shift)
methyl_c_char = ARGV.shift || "M"
methyl_g_char = ARGV.shift || "L"

for i in 0...(target_coordinates.size-1)

  lin = target_coordinates[i][0].to_i-1
  char = target_coordinates[i][1].to_i-1

  sequence_to_edit[lin][char] = sequence_to_edit[lin][char].sub("C", methyl_c_char).sub("G",methyl_g_char)

end

$stdout.puts(sequence_to_edit)
