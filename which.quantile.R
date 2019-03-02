#This function takes a vector of values and tells you, for each value, in which quantile of the vector it 
# falls in, can return the number of the quantile or the range which comprises such quantile. For example,
# feeding it c(40,20,30,10) will return c(4,2,3,1), since 40 would fall in the fourth quantile and so on,
# can separate by deciles or other fractions via 'quantile.sep'.
which.quantil <- function(values, quantiles=NULL, round.to=4, quantile.sep=0.25, quantile.index=T){
  
  if(is.null(quantiles)){
    quantiles <- quantile(values, probs=seq(0,1, quantile.sep))
  }
  
  these.quantiles <- sapply(values, function(z){
    for(i in 1:(length(quantiles)-1)){
      if(is.na(z)){
        return(NA)
      }
      if(between(z, quantiles[i], quantiles[i+1])){
        if(quantile.index){
          return(i)
        }else{
          return(paste0(round(quantiles[i], round.to),"_to_" , round(quantiles[i+1], round.to)))
        }
      }
    }
  })
  these.quantiles
}
