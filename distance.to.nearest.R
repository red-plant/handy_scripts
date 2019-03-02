# Distance to nearest finder. This function takes 2 numeric vectors and returns, for each of the values of one
# vector (query) the distance to the nearest value in the second vector (subject). Say I want to find the nearest
# transposon or gene to certain positions in a genome. I feed the positions of interests as query and the locations of the
# transposons as subject, function will make, for each position of interest, a binary search to identify the nearest
# position in the second vector (f example, positions of transposons or other features),
# and calculate the distance between these 2 positions. I think it could be easily modified to return the actual 
# nearest position/identity of the nearest member in the second vector.

to.nearest <- function(query, subject){
  
  subject <- sort(subject)
  ans <- NULL
  if(length(subject)==1){
    stop("Error: subject of length 1 has been fed")
  }

  for(counter in 1:length(query)){
    n <- as.integer(floor(length(subject)/2))
    delta <- as.integer(n/2)
    
    while(length(ans)<counter){
      
      if(delta<1){
        delta <- 1
      }
      
      if(query[counter]>subject[n]){
        if(n==length(subject)){
          ans[counter] <- query[counter]-subject[n]
          names(ans)[counter] <- names(subject[n])
          break
        }
        if(query[counter]<=subject[n+1]){
          ans[counter]<- min(abs(c(query[counter]-subject[n], query[counter]-subject[n+1])))
          names(ans)[counter] <- names(subject[n-1+which.min(abs(c(query[counter]-subject[n], query[counter]-subject[n+1])))])
          
        }
        n <- floor(n+ delta)
        delta  <- delta/2
      }
      
      
      if(query[counter]<subject[n]){
        if(n==1){
          ans[counter] <- subject[n]-query[counter]
          names(ans)[counter] <- names(subject[n])
          break
        }
        if(query[counter]>=subject[n-1]){
          ans[counter]<- min(abs(c(query[counter]-subject[n], query[counter]-subject[n-1])))
          names(ans)[counter] <- names(subject[n+1-which.min(abs(c(query[counter]-subject[n], query[counter]-subject[n+1])))])
        }
        n <- ceiling(n-delta)
        delta  <- delta/2
      }
      
      if(query[counter]==subject[n]){
        ans[counter] <- 0
        names(ans)[counter] <- names(subject[n])
      }
    }
  }
  
  return(ans)
}
