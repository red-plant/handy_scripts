#This script takes a genomic sequence as fasta (single line per sequence), and a GFF annotation and returns
# the transcripts in a fasta format. i.e. genome.fa + annotation.gff = transcripts.fa.
#It will deal with different chromosome names in annotation and genomic fasta even in they are in different order
# as long as chromosome names follow the same alphabetic order in both files and there is the same number of chromosomes in
# both. Unless say there's an extra "ChrM" at the end of your fasta that is not in your GFF for whatever reason, then
# it will be fine IF it is at the end in alphabetic order (like after Chr1....)
#With minor modifications should work for GTF, haven't tried. 
#Fasta must be 1 line per seq name 1 line per sequence, not that splitted sequence thing nobody needs

#There is an example at the bottom.

require(data.table)
require(stringr)
extract.transcript.fa <- function(genome, gff){
  
  #deal with original gff file
  genome.i <- copy(genome)
  gff.i <- copy(gff)
  setnames(gff.i, c("chromosome", "db", "type", "start", "end", "score", "strand", "frame", "descript"))
  gff.i <- gff.i[type=="exon"]
  #deal with chromosome names in the gff
  setorder(gff.i, chromosome, start, end)
  chromosomes.alias <- gff.i[,levels(factor(chromosome))]
  chromosomes <- seq(1, length(chromosomes.alias)) 
  names(chromosomes) <- chromosomes.alias
  gff.i[,chromosome:=chromosomes[chromosome]]
  #extract transcript names
  gff.i[,"transcript":=sub(".*Parent=([^;,]*).*", "\\1", descript)]
  
  #Order chromosomes, in case they are not
  chr.nam.lins <- grep("^>", genome.i)
  chr.nam.order <- order(genome.i[grepl("^>", genome.i)])
  genome.i.o <- character()
  j <- 1
  for(i in 1:length(chr.nam.lins)){
    next.chr.lin <- chr.nam.lins[chr.nam.order][i]
    genome.i.o[j:(j+1)] <- genome.i[next.chr.lin:(next.chr.lin+1)]
    j <- j+2
  }
  rm(genome.i)
  #Extract the sequence per exon
  gff.i[,"seq.exon":=apply(.SD, 1, function(z){
    z <- as.numeric(z)
    str_sub(genome.i.o[z[1]*2], z[2], z[3])
  }), .SDcols=c("chromosome", "start", "end")]
  #Join the exonic sequences
  transcripts <- gff.i[,.(paste(seq.exon, collapse = "")), by="transcript"]
  setnames(transcripts, "V1", "seq")
  transcripts[,transcript:=paste0(">", transcript)]
  t(transcripts)
  
}



#gff <- fread("grep -v '^#' ~/Documents/datasets/Araport11_GFF3_genes_transposons.201606.gff")
#genome <- readLines("~/Documents/datasets/tair10.fa")
#transcripts <- extract.transcript.fa(genome, gff)
#writeLines(transcripts, "~/Documents/datasets/ara11.fa")



