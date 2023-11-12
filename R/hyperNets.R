# hypernets.R
# analysis of hypergraphs and hypernets
# October 2023
# Vladimir Batagelj

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

# hyperClus.R
# clustering in hypernets
# 11. November 2023
# -------------------------------------------------------------------------
# based on symclus.R
# clustering mixed symbolic data
# 30. October 2023
# Vladimir Batagelj

dMembers <- function(Y,p,q){
  P <- Y[[p]]$R; Q <- Y[[q]]$R; pp <- Y[[p]]$p; pq <- Y[[q]]$p
  R <- P+Q; M <- max(R); t <- as.integer(2*R >= M)
  ppq <- sum((1-t)*R + t*(M-R))
  return(ppq - pp - pq)
}

pMembers <- function(Y,p,q){
  P <- Y[[p]]$R; Q <- Y[[q]]$R; pp <- Y[[p]]$p; pq <- Y[[q]]$p
  R <- P+Q; M <- max(R); t <- as.integer(2*R >= M)
  return(sum((1-t)*R + t*(M-R)))
}

Lupdate <- function(Y,ip,iq){
  pp <- Y[[ip]]$p; pq <- Y[[iq]]$p
  P <- Y[[ip]]$R; Q <- Y[[iq]]$R
  R <- P+Q; M <- max(R); t <- as.integer(2*R >= M)
  s <- Y[[ip]]$s + Y[[iq]]$s
  ppq <- sum((1-t)*R + t*(M-R))
  return(list(L=t,R=R,f=Y[[ip]]$f+Y[[iq]]$f,s=Y[[ip]]$s+Y[[iq]]$s,p=ppq))
}

hyper.cluster <- function(HN,dist=pMembers,dtype="dSets",norm=FALSE,w=NA){
  orDendro <- function(i){if(i<0) return(-i)
    return(c(orDendro(m[i,1]),orDendro(m[i,2])))}

  nUnits <- nrow(HN$links); nmUnits <- nUnits-1; method <- "HiSets"
  npUnits <- nUnits+1; n2mUnits <- nUnits+nmUnits; nNodes <- nrow(HN$nodes)
  H <- HN$links$E; U <- vector("list",n2mUnits)
  names(U)[1:nUnits] <- HN$links$ID
  if(is.na(w[1])) w <- rep(1,nUnits) else method <- "HiSetsW"
  if(norm) method <- paste(method,"N",sep="")
  for(j in 1:nUnits) {v <- rep(0,nNodes); v[H[[j]]] <- 1
    k <- max(1,sum(v)); u <- if(norm) v*(w[j]/k) else v*w[j]  
    U[[j]] <- list(L=v,R=u,f=1,s=w[j],p=0)}
  D <- matrix(nrow=nUnits,ncol=nUnits)
  for(p in 1:nmUnits) for(q in (p+1):nUnits) D[q,p] <- D[p,q] <- dist(U,p,q)
  diag(D) <- Inf
  active <- 1:nUnits; m <- matrix(nrow=nmUnits,ncol=2)
  node <- rep(0,nUnits); h <- numeric(nmUnits)
  for(j in npUnits:n2mUnits) U[[j]] <- list(L=NA,R=NA,f=1,s=1,p=0)
  names(U)[npUnits:n2mUnits] <- paste("L",1:nmUnits,sep="")
  for(k in 1:nmUnits){
    ind <- active[sapply(active,function(i) which.min(D[i,active]))]
    dd <- sapply(active,function(i) min(D[i,active]))
    pq <- which.min(dd)
    p<-active[pq]; q <- ind[pq]; h[k] <- D[p,q]
    if(node[p]==0){m[k,1] <- -p; ip <- p} else {m[k,1] <- node[p]; ip <- node[p]}
    if(node[q]==0){m[k,2] <- -q; iq <- q} else {m[k,2] <- node[q]; iq <- node[q]}
    ik <- nUnits + k
    U[[ik]] <- Lupdate(U,ip,iq)
    active <- setdiff(active,p)
    for(s in setdiff(active,q)){
      is <- ifelse(node[s]==0,s,node[s])
      D[s,q] <- D[q,s] <- dist(U,ik,is)
    }
    node[[q]] <- ik
  }
  for(i in 1:nmUnits) for(j in 1:2) if(m[i,j]>nUnits) m[i,j] <- m[i,j]-nUnits 
  hc <- list(merge=m,height=h,order=orDendro(nmUnits),labels=HN$links$ID,
    method=method,call=NULL,dist.method=dtype,leaders=U[npUnits:n2mUnits],
    attrs=HN$nodes$ID)
  class(hc) <- "hclust"
  return(hc)
}

# set of units in cluster q in the hierarchy hc
cluster <- function(hc,q) {
  clu <- function(m,q) return(if(q < 0) -q else union(clu(m,m[q,1]),clu(m,m[q,2]))) 
  return(clu(hc$merge,q))
}

# indices of top k values in vector V
top <- function(V,k) return(order(V,decreasing=TRUE)[1:k])

# description of the top k attributes of cluster cl in the hierarchy hc
desc <- function(hc,cl,k){
  km <- min(k,sum(hc$leaders[[cl]]$L))
  I <- top(hc$leaders[[cl]]$R,km)
  T <- hc$leaders[[cl]]$R[I]; names(T) <- hc$attrs[I]
  return(T)
}

