#!/usr/bin/ruby
i=0
str=""
arg = $stdin.readlines
for i in 0...(arg.size)

   if arg[i][0,1] != ">" 
     str << arg[i].delete("\n")
   end
   
   if arg[i][0,1] == ">"
    str << "\n"
    str << arg[i]
   end
   
end
$stdout.puts(str[1,(str.size)-1])
