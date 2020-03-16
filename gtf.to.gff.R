#only tested for araport11, with some editing it should work for any annotation. requires data.table package
gff.to.gtf <- function(gff, write.to.file=F, file.path=NULL, gene.tag="ID=", transcript.tag="Parent="){
  require(data.table)
  gff <- data.table(gff)
  if(ncol(gff)!=9){
    stop("gff does not contain 9 columns, function expect a gff table: chromosome, db, type, start, end, score, strand, frame, description")
  }
  gtf <- gff
  setnames(gtf, paste0("V", 1:9))
  gtf <- gtf[grep("UTR|exon|codon|CDS", V3),]
  gtf[,"transcript":= sub(paste0(".*", transcript.tag,  "([^;]*).*"), "\\1", V9)]
  gtf[,"gene":= sub(paste0(".*", gene.tag, "([^:;]*).*"), "\\1", V9)]
  gtf[,'tags':=paste0('gene_id ', paste0('"', gene, '"'), "; ", 'transcript_id ', 
                              paste0('"', transcript, '"'), "; ")]
  gtf <- subset(gtf, T, c(1:8, 12))
    if(write.to.file){
    write.table(gtf, file.path, row.names = F, col.names = F, sep='\t', qmethod = "escape", quote = F)  
    }else{
      print("If you want to write the gtf to a file be sure to use write.table with row.names and col.names=F, sep='\t',
              qmethod='escape', and quote=F")
      gtf
    }
  
}
