# Set the default CRAN mirror
options(repos=structure(c(CRAN="https://cran.r-project.org")))

# Install dependencies from CRAN
install.packages(c(
    'ggdendro',
    'ggplot2',
    'magrittr',
    'pander',
    'RColorBrewer',
    'rmarkdown',
    'XLConnect'
))

# Install dependencies from Bioconductor
install.packages('BiocManager')
BiocManager::install(c(
    'BiocParallel',
    'CAMERA',
    'xcms'
), update=TRUE, ask=FALSE)

# The following prints off the set of packages we installed.
# ref: https://stackoverflow.com/a/40120266/145504
ip = as.data.frame(installed.packages()[,c(1,3:4)])
ip = ip[is.na(ip$Priority),1:2,drop=FALSE]
ip
