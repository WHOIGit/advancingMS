#xdata <- peakShape_XCMS3(my_data,cor.val=0.9, useNoise = setNoise)

#and then proceed with retention time correction and correspondence/grouping
# Decreasing cor.val will allow more non-gaussian peaks through the filter

#original file version from the Google Groups for xcms from Tony Larson
#KL corrected this version 8/23/2011 for XCMS < 3
#KL updating to using XCMS3, 11/5/2018

#original peakShape function to remove non-gaussian peaks from an xcmsSet
#code originally had cor.val = 0.9; 0.5 is too low (not doing enough pruning)
#object is updated to be an XCMSnExp class

peakShape_XCMS3 <- function(object, cor.val=0.9, useNoise = setNoise)
{
require(xcms)

#files <- object@filepaths #old code
files <- fileNames(object)
  
#peakmat <- object@peaks #old code
peakmat <- chromPeaks(object) #extract everything

peakmat.new <- matrix(-1,1,ncol(peakmat)) 
colnames(peakmat.new) <- colnames(peakmat)

for(f in 1:length(files))
        {
        #xraw <- xcmsRaw(files[f], profstep=0) #old code
        raw_data <- readMSData(files[f],msLevel = 1, mode = "onDisk") #use 'onDisk' to make the next step faster
        sub.peakmat <- peakmat[which(peakmat[,"sample"]==f),,drop=F]
        corr <- numeric()
        for (p in 1:nrow(sub.peakmat))
                {
                #old code
                #tempEIC <-
                    #as.integer(rawEIC(xraw,mzrange=c(sub.peakmat[p,"mzmin"]-0.001,sub.peakmat[p,"mzmax"]+0.001))$intensity)
                #minrt.scan <- which.min(abs(xraw@scantime-sub.peakmat[p,"rtmin"]))[1]
                #maxrt.scan <- which.min(abs(xraw@scantime-sub.peakmat[p,"rtmax"]))[1]
                #eics <- tempEIC[minrt.scan:maxrt.scan]
          
                mzRange = c(sub.peakmat[p,"mzmin"]-0.001,sub.peakmat[p,"mzmax"]+0.001)
                subsetOnMZ <- filterMz(raw_data, mz = mzRange)
                
                #now set the Rt range...use sub.peakmat min and max RT
                rtRange = c(sub.peakmat[p,"rtmin"],sub.peakmat[p,"rtmax"])
                subsetOnMZandRT <- filterRt(subsetOnMZ, rt = rtRange)
 
                eics <- intensity(subsetOnMZandRT) #get the intensity values
                eics[sapply(eics, function(x) length(x)==0)] <- 0 #if empty in a scan, convert to 0
                eics <- as.integer(unlist(eics)) #use as.double for Lumos

                #filter out features that are less than the noise level I have already set...
                setThreshold <- which(eics < useNoise)
                eics <- eics[-setThreshold]
                rm(setThreshold)

                #remove any NA (easier bc downstream leaving it in causes issues)
                eics <- eics[!is.na(eics)]
                
                getIdx <- which(eics == min(eics))[1] #if multiple values, just need the first match
                #set min to 0 and normalise
                eics <- eics-eics[getIdx]
                
                if(max(eics,na.rm=TRUE)>0)
                        {
                        eics <- eics/max(eics, na.rm=TRUE)
                        }
                #fit gauss and let failures to fit through as corr=1
                fit <- try(nls(y ~ SSgauss(x, mu, sigma, h), 
                               data.frame(x = 1:length(eics), y = eics)),silent=T)
                
                if(class(fit) == "try-error")
                        {
                        corr[p] <- 1
                        } else {
                        #calculate correlation of eics against gaussian fit
                        if (length(which(!is.na(eics - fitted(fit)))) > 4 &&
                            length(!is.na(unique(eics)))>4 && 
                            length(!is.na(unique(fitted(fit))))>4)
                                {
                                cor <- NULL
                                options(show.error.messages = FALSE)
                                cor <- try(cor.test(eics,fitted(fit),method="pearson",use="complete"))
                                options(show.error.messages = TRUE)
                                if (!is.null(cor))
                                        {
                                        if(cor$p.value <= 0.05) {
                                          corr[p] <- cor$estimate 
                                        } else {
                                          corr[p] <- 0 }
                                        } 
                                  else corr[p] <- 0
                                } else corr[p] <- 0
                        }
                } #this ends to the 'p' loop (going through one mzRT feature at a time)
        
        filt.peakmat <- sub.peakmat[which(corr >= cor.val),]
        peakmat.new <- rbind(peakmat.new, filt.peakmat)
        n.rmpeaks <- nrow(sub.peakmat)-nrow(filt.peakmat)
        cat("Peakshape evaluation: sample ", 
            basename(files[f]),"
            ",n.rmpeaks,"/",nrow(sub.peakmat)," peaks removed","\n")
        
        if (.Platform$OS.type == "windows") flush.console()
        
        
        } #this ends the 'f' loop (going through one file at a time())

peakmat.new <- peakmat.new[-1,] #all but the first row that is all -1
object.new <- object #copy to a new object

#object.new@peaks <- peakmat.new #old code
chromPeaks(object.new) <- peakmat.new #this will return an answer, but losing information

#add this line to retain the history information
object.new@.processHistory <- object@.processHistory

return(object.new) 
} #this ends the function itself