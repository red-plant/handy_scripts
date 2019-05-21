#This function takes a vector of values and tells you, for each value, in which quantile of the vector it 
# falls in, can return the number of the quantile or the range which comprises such quantile. For example,
# feeding it c(40,20,30,10) will return c(4,2,3,1), since 40 would fall in the fourth quantile and so on.
# -'quantile.sep' controls de distance between quantiles, i.e. it can separate in deciles or other.
# -'return.quantile.no' controls wheter the function should return the number of the quantile or the range which comprises such quantile.
# -'round.to' controls, when quantile ranges are returned, the presicion with which they are reported.
# -'quantile.lim.val' controls what to do with the values that fall in the limit between quantiles, by default, they are assigned NA, 'first' or 'last' may be chosen.
# -'more.than.less.than' controls, when quantile ranges are returned, if the first and last quantile ranges are changed to '< than $first.quantile.upper.limit' and '> than $last.quantile.lower.limit', respectively

which.quantil <- function(values, quantile.sep=0.25,  return.quantile.no=T, round.to=2, quantile.lim.val=NA,
                          more.than.less.than=F){
  
  require(data.table)
  
  mult <- "first"
  
  if(!is.na(quantile.lim.val)){
    mult <- quantile.lim.val
  }
  if(! mult %in% c("first","last")){
    stop("values in quantile limit must be assigned to the first or last quantile, or NA returned")
  }
  
  quantiles <- quantile(na.omit(values), probs=seq(0,1, quantile.sep))
  values <- data.table("start"=values, "end"=values, "value.id"=seq(1, length(values)))
  quantiles <- data.table("start"=quantiles[1:(length(quantiles)-1)], "end"=quantiles[2:length(quantiles)])
  quantiles[,"quantile.nth":=seq(1, nrow(quantiles))]
  setkey(values, start, end)
  setkey(quantiles, start, end)
  value.quantiles <- foverlaps(values, quantiles, mult=mult, type = "within")
  setorder(value.quantiles, value.id)
  if(is.na(quantile.lim.val)){
    value.quantiles[quantile.nth==1 & i.start==end, quantile.nth:=NA ]
    value.quantiles[quantile.nth==max(quantile.nth) & i.start==start, quantile.nth:=NA]
    value.quantiles[!(quantile.nth %in% c(1, max(quantile.nth))) & i.start %in% c(start, end), quantile.nth:=NA]
  }
  if(return.quantile.no){
    value.quantiles[,factor(quantile.nth, levels=1:nrow(quantiles))]
  }else{
    quantiles[,"quantile.rang":=paste(round(start, round.to), "to", round(end, round.to))]
    if(more.than.less.than){
      quantiles[quantile.nth==1, quantile.rang:=paste("<=", round(end, round.to))]
      quantiles[quantile.nth==max(quantile.nth), quantile.rang:=paste(">=", round(start, round.to))]
    }
    value.quantiles <- merge(value.quantiles, quantiles[,.(quantile.nth, quantile.rang)], by="quantile.nth", all.x = T)
    setorder(value.quantiles, value.id)
    value.quantiles[,factor(quantile.rang, levels=unique(quantiles[,quantile.rang]))]
  }
  
}


