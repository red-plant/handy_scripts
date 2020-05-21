library(data.table); setDTthreads(4)
library(stringr)

#Load annotation
ara11 <- fread("grep -v '^#' ~/Documents/datasets/Araport11_GFF3_genes_transposons.201606.gff")
setnames(ara11, c("chromosome", "db", "type", "start" ,"end", "score", "strand", "frame", "descript"))
ara11[,"gene":=sub(".*ID=(AT.G[0-9]{5}).*", "\\1", descript)]
ara11.ex <- ara11[type=="exon"]

#Get the non-redundant exon span, by steps:
##1- ID each exon
ara11.ex[,"ex.id":=seq(1, .N)]
##2- Find continuous overlaps of exons, by steps:
###2.1- Overlaps between any 2 exons
setkey(ara11.ex, chromosome, start, end)
ara11.ex.ov <- foverlaps(ara11.ex, ara11.ex)
ara11.ex.ov <- ara11.ex.ov[ex.id != i.ex.id, .(ex.id, i.ex.id)]
setorder(ara11.ex.ov, ex.id) #just for visualization
###2.2- stablish, per exon id, all overlapping exons with it
ara11.ex.ov <- dcast(ara11.ex.ov, ex.id~1, value.var="i.ex.id", fun.aggregate = list)
setnames(ara11.ex.ov, ".", "overlaps.with")
###2.3- add the exons that overlap with any of the already overlapping exons to this list: extending the connections,
# this is going to be quite recursive, should be a better way, but still runs in the reasonable time of ~5 min
ids <- ara11.ex.ov[,ex.id]
evaled.exons <- numeric()
grpd.exns <- data.table()

for(i in ids){
  
  if(i %in% evaled.exons){
    next()
  }
  
  this.lev <- unlist(ara11.ex.ov[ex.id==i, overlaps.with])
  next.lev <- unique(unlist(ara11.ex.ov[ex.id %in% this.lev, overlaps.with]))
  
  while(sum(! next.lev %in% this.lev) > 0){
    this.lev <- unique(c(this.lev, next.lev))
    next.lev <- unique(unlist(ara11.ex.ov[ex.id %in% this.lev, overlaps.with]))
  }
  
  grpd.exns <- rbindlist(list(grpd.exns, list(i, list(this.lev)))) 
  ind.star <- length(evaled.exons)+1
  ind.end <- ind.star+length(this.lev)-1
  evaled.exons[ind.star:ind.end] <- this.lev
  
}

setnames(grpd.exns, c("grp.head", "ovlp.grp"))
##3- For each group get the min start and max ends
  # also like 4 min, 'd do better integrated inside last for loop, probably
setkey(ara11.ex, ex.id)
grp.span <- t(sapply(grpd.exns[,ovlp.grp], function(z){
  ara11.ex[ex.id %in% z, .(min(start), max(end))]
}))

grp.span <- as.data.table(grp.span)
setnames(grp.span, c("grp.start","grp.end"))
grpd.exns <- cbind(grpd.exns, grp.span)

##4- Add exons with no overlaps
lone.ex <- ara11.ex[!ex.id %in% grpd.exns[,unlist(ovlp.grp)], .(ex.id, start, end)]
lone.ex[,"ovlp.grp":=ex.id]
setnames(lone.ex, c("grp.head", "grp.start", "grp.end", "ovlp.grp"))
grpd.exns <- rbind(grpd.exns, lone.ex)

##5- Add chromosome and gene (probably should not have dropped it)
grpd.exns <- merge(grpd.exns, ara11.ex[,.(gene, chromosome, ex.id)], by.x="grp.head", by.y="ex.id")
exon.span <- grpd.exns[,.(gene, chromosome, grp.start, grp.end)]
exon.span[,"ex.grp.no":=seq(1, .N)]
exon.span[,grp.start:=as.numeric(grp.start)]
exon.span[,grp.end:=as.numeric(grp.end)]
exon.span[,"ex.grp.span":= grp.end - grp.start]
#Calculate the span per gene
collapsed.span <- exon.span[,sum(ex.grp.span), by="gene"]
setnames(collapsed.span, c("gene", "collapsed.span"))

#Nice, now I can pull the sequence (if I ever need to)

#Get the longest transcript span per gene, to convert to TPMs
ara11.ex[,"transcript":=sub(".*Parent=(AT.G[0-9]{5}\\.[0-9]*).*", "\\1", descript)]
ara11.ex[,"span":=end-start]
per.transcript.span <- ara11.ex[,sum(span), by=transcript]
per.transcript.span[,"gene":=str_sub(transcript, 1, 9)]
longest.iso.per.gene <- per.transcript.span[,max(V1), by="gene"]
collapsed.span <- merge(collapsed.span, longest.iso.per.gene, by="gene")
setnames(collapsed.span, "V1", "longest.transcript.span")

write.table(file = "~/Documents/datasets/exonic.span.per.gene.tsv", collapsed.span, sep="\t", quote = F, row.names = F, col.names = T)
write.table(file = "~/Documents/datasets/collapsed.exon.coordinates.tsv", exon.span, sep="\t", quote = F, row.names = F, col.names = T)





