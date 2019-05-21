FROM r-base:3.6.0

# Install system dependencies
RUN apt-get update \
    && apt-get install -y \
        default-jdk \
        libnetcdf-dev \
        libxml2-dev \
        pandoc \
        r-cran-rmpi \
    && rm -rf /var/lib/apt/lists/*

# Install R dependencies
COPY install.r /install.r
RUN Rscript /install.r \
    && rm -f /install.r

# When executed, knit the Rmarkdown file to HTML
WORKDIR /ms
CMD Rscript -e 'library(rmarkdown); rmarkdown::render("simple_XCMS3.2019.05.08.Rmd", output_format = "html_document", output_file = "/output/simple_XCMS3.2019.05.08.html")'
