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

hyper.dual <- function(HN){
  HD <- HN
  HD$info$creator <- c(HN$info$creator,"hyper.dual")
  HD$info$date <- c(HN$info$date,date())
  HD$info$nNodes <- HN$info$nLinks; m <- HD$info$nLinks <- HN$info$nNodes
  HD$nodes <- subset(HN$links,select=-c(E)); HD$links <- HN$nodes
  E = vector(mode="list",m)
  for(i in 1:m) E[[i]] <- which(sapply(HN$links$E,function(x) i %in% x)) 
  HD$links$E <- E
  return(HD)
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

distul <- function(X,Y){
  P <- X$R; Q <- Y$L
  R <- P+Q; M <- max(R); t <- Y$L # t <- as.integer(2*R >= M)
  return(sum((1-t)*R + t*(M-R)))
}

reportCl <- function(HN,Cl){
  C <- Cl$clust; LN <- names(Cl$leaders); nl <- length(LN)
  tot <- sum(sapply(Cl$leaders,function(x) x$p))
  cat(HN$info$title,"\ntot =",tot,"\n\n")
  for(k in 1:nl)cat("C",k," r =",Cl$R[k],"f =",Cl$leaders[[k]]$f,
    "c =",sum(Cl$leaders[[k]]$L),"p =",Cl$leaders[[k]]$p,"\n",LN[k],":",
    HN$nodes$ID[Cl$leaders[[k]]$L==1],"\nC:",HN$links$ID[which(C==k)],"\n\n")
}

# adapted leaders method
#---------------------------------------------
# VB, 16. julij 2010
#   dodaj omejitev na najmanjše število enot v skupini
#   omejeni polmer

hyper.leader <- function(HN,maxL,trace=2,tim=1,empty=0,clust=NULL,w=NA,norm=FALSE){
  nUnits <- nrow(HN$links); nmUnits <- nUnits-1; method <- "Leader"
  nNodes <- nrow(HN$nodes); best <- Inf
  v <- rep(0,nNodes); temp <- list(L=v,R=v,f=0,s=0,p=0)  
  H <- HN$links$E; U <- vector("list",nUnits)
  names(U)[1:nUnits] <- HN$links$ID
  if(is.na(w[1])) w <- rep(1,nUnits) else method <- "LeaderW"
  if(norm) method <- paste(method,"N",sep="")
  for(j in 1:nUnits) {v <- rep(0,nNodes); v[H[[j]]] <- 1
    k <- max(1,sum(v)); u <- if(norm) v*(w[j]/k) else v*w[j]  
    U[[j]] <- list(L=v,R=u,f=1,s=w[j],p=0)}
    
  L <- vector("list",maxL); Ro <- numeric(maxL); K <- integer(maxL)
# if not given, random partition into maxL clusters
  if(is.null(clust)) clust <- sample(1:(maxL-empty),nUnits,replace=TRUE)
  step <- 0 
  cat("Hypernets / leader",date(),"\n\n"); flush.console()
  repeat {
    step <- step+1; K <- 0
  # new leaders - determine the leaders of clusters in current partition
    for(k in 1:maxL){L[[k]] <- temp; names(L)[[k]] <- paste("L",k,sep="")}
    for(i in 1:nUnits){j <- clust[[i]]; L[[j]]$R <- L[[j]]$R + U[[i]]$R }
    for(k in 1:maxL){M <- max(L[[k]]$R); L[[k]]$L <- as.integer(2*L[[k]]$R >= M)}
  # new partition - assign each unit to the nearest new leader
  # for(k in 1:maxL) print(L[[k]]$L); flush.console() # TEST
    clust <- integer(nUnits); R <- numeric(maxL)
    for(i in 1:nUnits){d <- double(maxL)
      for(k in 1:maxL){d[[k]] <- distul(U[[i]],L[[k]])}
      r <- min(d); j <- which(d==r)
      if(is.infinite(r)){cat("Infinite unit=",i,"\n"); print(U[[i]]); flush.console()}
      if(length(j)==0){
        cat("unit",i,"\n",d,"\n"); flush.console(); print(U[[i]]); flush.console()
        u <- which(is.na(d))[[1]]; cat("leader",u,"\n"); print(L[[u]])
        stop()}
      j <- which(d==r)[[1]];
      clust[[i]] <- j; L[[j]]$p <- L[[j]]$p + r; L[[j]]$f <- L[[j]]$f + 1
      if(R[[j]]<r) {R[[j]] <- r; K[[j]] <- i}
    }
  # report
    cat("\nStep",step,date(),"\n"); flush.console()
    if(trace>1) {print(table(clust)); print(R); print(Ro-R)
    print(sapply(L,function(x) x$p))} 
    tot <- sum(sapply(L,function(x) x$p)); print(tot); flush.console()
    if(tot<best){best <- tot; Cb <- clust; Lb <- L; Rb <- R}
    if(sum(abs(Ro-R))<0.0000001) break
    Ro <- R; tim <- tim-1
    if(tim<1){
      ans <- readline("Times repeat = ")
      tim <- as.integer(ans); if (tim < 1)  break
    }
  # in the case of empty clusters use the most distant SOs as seeds
    t <- table(clust)
    em <- setdiff(1:maxL,as.integer(names(t)))
    if(length(em)>0){
      cat("*** empty clusters",em,":"); lem <- length(em)
      if(2*lem>maxL){cat(" more than half clusters\n"); stop()}
      iem <- K[rev(order(R))[1:lem]]; clust[iem] <- em
      cat(" Units",iem," used as seeds\n"); flush.console()
    }
  }
  return (list(clust=Cb,leaders=Lb,R=Rb))
}


