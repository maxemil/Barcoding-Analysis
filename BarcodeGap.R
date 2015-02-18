barcode_gap = function(mat, spec,filename){
    unique = levels(spec$V2)
    unique.max = c()
    unique.min = c()
    unique.mean = c()
    for(i in 1:length(unique)){
        sp.ind = which(spec$V2 == unique[i])
        if(length(sp.ind) > 0 ){
            unique.max[i] = max(mat[sp.ind,sp.ind])
            unique.mean[i] = mean(as.matrix(mat[sp.ind,sp.ind]))
            unique.min[i] = min(mat[sp.ind,-sp.ind])
        }else{
            unique.max[i] = NA
            unique.min[i] = NA
            unique.mean[i] = NA
        }
        
    }
    sink(file=paste(filename,'_below_line.txt', sep=''))
        print('species below line:')
        write.table(format(unique[unique.max>unique.min], justify="right"),
            row.names=F, col.names=F, quote=F)
    sink(NULL)
    return(as.data.frame(cbind('Max'=unique.max, 'Min'=unique.min, 'Mean'=unique.mean)))
}

barcode_gap_plot = function(df){
    Maxlab="Maximum Intraspecific Divergence"
    Minlab="Distance to Nearest Neighbour"
    x=0:100
    plot(x,x,type="l",ylim=c(0,30),xlim=c(0,10),xaxs='i',yaxs='i',xlab=Maxlab,ylab=Minlab)
    points(df$Max*100,df$Min*100,xpd=TRUE,cex=0.7, las = 1,col="red",pch=18)
}

barcode_gap_regression = function(df, counts, filename){
    size = counts$V2[counts$V2 > 1]
    means = df$Mean[counts$V2 > 1]
    maxs = df$Max[counts$V2 > 1]

    regMax=lm(maxs*100~size)
    reg=lm(means*100~size)
    plot(size,maxs*100,col="red",
        pch=18,xlab="Species Size",ylab="Intraspecific Divergence",
        ylim=c(0,7),xlim=c(0,35))
    abline(regMax,col="red")

    abline(reg,col="orange")
    points(size,means*100,col="orange",pch=18)
    sink(file=paste(filename,'_summary.txt', sep=''))
        print(summary(regMax))
        print(summary(reg))
    sink(NULL)
}

