hyper.save2pajek <- function(HN,netFile){
  H <- HN$links; m <- nrow(H)
  V <- HN$nodes$ID; n <- length(V)
  net <- file(netFile,"w")
  cat("% hyper2pajek",date(),"\n*vertices",m+n,m,"\n",file=net)
  for(i in 1:m) cat(i,' "',H$ID[i],'"\n',sep="",file=net)
  for(i in 1:n) cat(m+i,' "',V[i],'"\n',sep="",file=net)
  cat("*arcs\n",file=net)
  for(i in 1:m){L <- E[[i]]; for(j in L) cat(i,m+j,"\n",file=net)}
  close(net)
}

