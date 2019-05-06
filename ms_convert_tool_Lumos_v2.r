################ ms convert tool #############
#use this to have an r script to convert the RAW files into whatever format I want
# KL 3/27/2014 from code I found online
#this version should work its way through the two folders with the data
#modify for AAIW experiment during DeepDOM, KL 4/10/2014
# KL 2/22/2018 modify for use with UPLC Lumos data...the <vendor> peak picker will do better than msConvert's peak picker
# KL 3/21/2018 corrected syntax for use with the 'vendor' peak picker

##remember that the pattern in the file name will need to be changed in addition to the file location.

here<- getwd()
 
#note that for this to work, msconvert must be in a folder that has no spaces in the file name
#msconvert <- c("C:/temp/msconvert.exe") #this is the correct path for peaberry
msconvert <- c("C:/pwiz/msconvert.exe") #this is the correct path for arabica


folders <- c("C:/Users/KLongnecker/Documents/Current projects/updateXCMS/testData_Weber/RAWfiles")

for (ii in 1:length(folders)) {
    
setwd(folders[ii])
FILES <- list.files(recursive=FALSE, full.names=TRUE, pattern="*RAW")

#Notes on the 'filters' in msconvert:
#this filter must be first; this is the peak picking (convert to centroid):--filter \"peakPicking true 1-\"
#this filter will only keep peaks > 1000 (absolute intensity) --filter \"threshold absolute 1000 most-intense\"
  
  for (i in 1:length(FILES)) {
    #Use threshold with Lumos to help keep file sizes reasonable and bc have much higher noise (in absolute numbers cfd to FT)

    #use this for the Lumos...
    system(paste(msconvert, "--mzML --filter \"peakPicking true 1-3 vendor\" --filter \"msLevel 1\" -o ../mzML_Lumos_MS1_updated", FILES[i]))

    #need to run this twice since the first version will only have MS1 data in the interest of keeping file sizes somewhat reasonable    
    #system(paste(msconvert, "--mzML --filter \"peakPicking true vendor 1-3\" --filter \"msLevel 1-3\" -o mzML_Lumos_withMSn", FILES[i]))
  }
  
  rm(i,FILES)

}
rm(ii)
setwd(here)

#do some housecleaning
rm(here,msconvert)

