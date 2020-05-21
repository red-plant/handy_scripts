library(data.table)
library(stringr)

setwd("~/Documents/embryo_in_seed_project/results/")
samples <- list.dirs(full.names = F, recursive = F)

all.mapping.stats <- data.table()
all.counts <- data.table(gene=character())

for(sampl in samples){
  
  sampl.base.nam <- sub(".STAR.map", "", sampl)
  
  #retrieve mapping stats
  star.log <- fread(cmd= paste0("grep '|' ", sampl, "/Log.final.out"), sep="\t", blank.lines.skip = T, header = F)
  input.reads <- as.numeric(star.log[grepl("Number of input reads", V1), V2])

  #retrieve counts
  counts.vars <- fread(paste0(sampl, "/STAR.FC.counts"), select = c("Geneid", "Aligned.out.bam"))
  counts.vars[,"read.origin":= str_sub(Geneid, -4)]
  counts.vars[,"gene":= str_sub(Geneid, 1, -6)]
  counts.vars <- dcast(counts.vars, gene~read.origin, value.var = "Aligned.out.bam")
  setnames(counts.vars, c("gene", "col0.counts", "cvi0.counts"))
  
  counts.genes <- fread(paste0(sampl, "/multimap/STAR.FC.counts"), select = c("Geneid", "Aligned.out.bam"))
  counts.genes[,"gene":= str_sub(Geneid, 1, -6)]
  counts.genes <- counts.genes[,sum(Aligned.out.bam), by="gene"]
  setnames(counts.genes, "V1", "gene.counts")
  
  counts <- merge(counts.genes, counts.vars, all=T, by="gene")
  setnames(counts, c("gene", paste(sampl.base.nam, colnames(counts[,!"gene"]), sep = ".")))
  
  #merge the sample data to a general table
  mapping.stats <- data.table("library"=sampl.base.nam,"input.reads"=input.reads, "counted.to.genes"=counts.genes[,sum(gene.counts)],
                              "counted.to.vars"=counts.vars[,sum(col0.counts, cvi0.counts, na.rm = T)],
                              "col.counts"=counts.vars[,sum(col0.counts, na.rm = T)],
                              "cvi.counts"=counts.vars[,sum(cvi0.counts, na.rm = T)])
  mapping.stats[,"percent.of.input.mapped.to.cvi":=cvi.counts/input.reads*100]
  all.mapping.stats <- rbind(all.mapping.stats, mapping.stats)
  
  all.counts <- merge(all.counts, counts, by="gene", all=T)
  
}

write.table(all.mapping.stats, "mapping.stats.tsv", sep = "\t", row.names = F, col.names = T,
            quote = F)
write.table(all.counts, "counts.tsv", sep="\t", row.names = F, col.names = T,
            quote = F)
