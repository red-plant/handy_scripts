#!/usr/bin/ruby

# Usage: cat multiline.fa | ./multiline.to.single.line.fasta.stdinout.rb > single.line.fa

# Takes STDIN, removes line breaks in all lines not starting with the ">" character.
# Outputs to STDOUT

i=0
sl=""
ml = $stdin.readlines

for i in 0...(ml.size)

   if ml[i][0,1] != ">" 
     sl << ml[i].delete("\n")
   end
   
   if ml[i][0,1] == ">"
    sl << "\n"
    sl << ml[i]
   end
   
end
$stdout.puts(sl)
