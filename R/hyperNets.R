hyper.save2pajek <- function(HN,netFile){
  H <- HN$links; m <- nrow(H); N <- names(H)
  V <- HN$nodes$ID; n <- length(V)
  net <- file(netFile,"w")
  cat("% hyper2pajek",date(),"\n*vertices",m+n,m,"\n",file=net)
  for(i in 1:m) cat(i,' "',H$ID[i],'"\n',sep="",file=net)
  for(i in 1:n) cat(m+i,' "',V[i],'"\n',sep="",file=net)
  if("E" %in% N){ cat("*edges\n",file=net)
    for(i in 1:m){L <- H$E[[i]]; 
    if(!is.na(L[1])) for(j in L) cat(i,m+j,"\n",file=net)}}
  if("In" %in% N){ cat("*arcs\n",file=net)
    for(i in 1:m){L <- H$In[[i]]; 
    if(!is.na(L[1])) for(j in L) cat(m+j,i,"\n",file=net)}}
  if("Out" %in% N){ cat("*arcs\n",file=net)
    for(i in 1:m){L <- H$Out[[i]]; 
    if(!is.na(L[1])) for(j in L) cat(i,m+j,"\n",file=net)}}
  close(net)
}

