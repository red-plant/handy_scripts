#This script takes an annotation file (gff or gtf) and a variant file in variant annotation format (vcf),
#and 'updates' the coordinates of the annotation according to the variants in the vcf. This is, indels in 
#each chromosome will affect the annotations downstream (5' to 3'), a gene whose start is at chromosome
#1, base 1000 will start at chromosome 1, base 999, if theres a 1bp deletion before it. This script therefore takes an
#annotation regarding the reference strain, and returns it regarding the alternative strain. An indel inside
#a feature, will only modify the end position, and therefore this can rarely cause negative widths: if there is a
#deletion bigger than 3bp inside a start/end codon in a gtf file, this features are not excluded in "gff <- gff[end>=start]".

#If you enable 'fitted.variants.only', it will return only the features in your annotation that
#overlap a variant, will change the coordinates to include only the variant, and will adapt them regarding to be
#regarding the alternative. This is, if gene A starts is at chromosome A, from bp 100 to bp 500, has an indel of 1bp 
#beefore it, and a SNP at base 200, the script will return that gene A starts at base 199 and ends at base 199: the 
#gene has been reduced to only the variant and put in the alternative strain coordinates. This is useful if you want,
#for example, to count reads aligned to variants.
#The script will return 1 row per each variant in the gene; thus, a gene can appear as many times
#as variants it has, and each time, its coordinates will be reduced to include only the variant.

#This script handles different chromosome names in each format, such as "Chr1" in the vcf and "chr1" in the gff.

#You must have data.table installed and loaded. and objects (vcf and gff/gtf) must be data.table objects.

fit.coordinates <- function(feature.coordinates.gff, variants.vcf, fitted.variants.only=F){
  
  require(data.table)
  
  vcf <- copy(variants.vcf)
  setnames(vcf, c("chromosome", "start", "ID", "ref", "alt", "qual", "fiter", "info", "format", "call.data"))
  chromosomes.alias.vcf <- vcf[,levels(factor(chromosome))]
  chromosomes.vcf <- seq(1, length(chromosomes.alias.vcf)) 
  names(chromosomes.vcf) <- chromosomes.alias.vcf
  vcf[,chromosome:=chromosomes.vcf[chromosome]]
  indels <- vcf[nchar(ref)!=nchar(alt), .(chromosome, start, ref, alt)]
  indels[,"offset":=nchar(alt)-nchar(ref)]
  
  gff <- copy(feature.coordinates.gff)
  setnames(gff, c("chromosome", "db", "type", "start", "end", "score", "strand", "frame", "descript"))
  starts <- split(gff[,start], gff[,chromosome])
  ends <- split(gff[,end], gff[,chromosome])
  chromosomes.alias.gff <- gff[,levels(factor(chromosome))]
  chromosomes.gff <- seq(1, length(chromosomes.alias.gff)) 
  names(chromosomes.gff) <- chromosomes.alias.gff
  gff[,chromosome:=chromosomes.gff[chromosome]]
  
  if(! fitted.variants.only){
    
    for(i in 1:nrow(indels)){
      
      chr <- indels[i, chromosome]
      var.start <- indels[i, start]
      offset <- indels[i, offset]
      start.selector <- starts[[chr]]>var.start
      end.selector <- ends[[chr]]>var.start
      indels[chromosome==chr & start>var.start, start:=start+indel.size]
      starts[[chr]][start.selector] <- starts[[chr]][start.selector]+offset
      ends[[chr]][end.selector] <- ends[[chr]][end.selector]+offset
    }
    gff[,start:=unlist(starts)]
    gff[,end:=unlist(ends)]
    gff[,chromosome:=names(chromosomes.gff[chromosome])]
    gff[]
    
  }else{
    
    vcf.starts <- split(vcf[,start], vcf[,chromosome])
    
    for(i in 1:nrow(indels)){
      
      chr <- indels[i, chromosome]
      var.start <- indels[i, start]
      offset <- indels[i, offset]
      start.selector <- starts[[chr]]>var.start
      vcf.start.selector <- vcf.starts[[chr]]>var.start
      
      end.selector <- ends[[chr]]>var.start
      starts[[chr]][start.selector] <- starts[[chr]][start.selector]+offset
      indels[chromosome==chr & start>var.start, start:=start+indel.size]
      vcf.starts[[chr]][vcf.start.selector] <- vcf.starts[[chr]][vcf.start.selector]+offset
      ends[[chr]][end.selector] <- ends[[chr]][end.selector]+offset
    }
    gff[,start:=unlist(starts)]
    gff[,end:=unlist(ends)]
    gff <- gff[end>=start]
    vcf[,start:=unlist(vcf.starts)]
    vcf[,"end":=start+nchar(alt)-1]
    
    vcf <- vcf[,.(chromosome, start, end)]
    setkey(gff, chromosome, start, end)
    setkey(vcf, chromosome, start, end)    
    
    fitted.vars <- foverlaps(vcf, gff)
    fitted.vars <- fitted.vars[!is.na(descript), .(chromosome, db, type, i.start, i.end, score, strand, frame, descript)]  
    setnames(fitted.vars, c("i.start", "i.end"), c("start", "end"))
    fitted.vars[,chromosome:=names(chromosomes.gff[chromosome])]
    fitted.vars[]
  }
}
