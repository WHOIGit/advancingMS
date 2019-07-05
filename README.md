# advancingMS

Advancing our mass spectrometry data analysis pipelines. Working with WHOI's Applications Development group to advance our pipelines for the analysis of ultrahigh resolution mass spectrometry data.


## Docker Container

The environment needed to process `.mzML` files is described by the Dockerfile. The resulting Docker container image contains all runtime dependencies, including the R packages described in `install.r`.

The `go.sh` script demonstrates how to mount the appropriate directories into the container and run the processing step.

    docker build --tag whoi/advancingms .
    ./go.sh


## Running on Poseidon

Poseidon is WHOI's high-performance computing (HPC) cluster. More information is available at https://hpc.whoi.edu/.

Poseidon does *not* support Docker, but instead supports [Singularity][].

[Singularity]: https://www.sylabs.io/singularity/

### Building a Singularity container

These instructions convert our Docker container to a Singularity container. They should be followed on a system that matches the Poseidon architecture, i.e., `x86_64`.

First we need to build a fork of `docker2singularity` tool that incorporates some bug fixes.

    git clone https://github.com/rgov/docker2singularity.git
    cd docker2singularity
    docker build -t rgov/docker2singularity .

Now we can build our Docker container and generate a `.simg` file from it:

    cd advancingMS
    docker build --tag whoi/advancingms .
    docker run \
        --privileged -t --rm \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v $(pwd):/output \
        rgov/docker2singularity \
            -m "/ms /data /output" \
            whoi/advancingms

The resulting `.simg` file can be copied from the build machine to the Poseidon scratch space:

    HPC_USER=rgovostes
    rsync -v -e ssh *.simg $HPC_USER@poseidon.whoi.edu:/vortexfs1/scratch/$HPC_USER/advancingMS

The file can be run on the login node

    module add singularity/2.5.2
    singularity run -B "$(pwd):/ms:rw,$(pwd)/../data:/data:ro,$(pwd):/output" $SCRATCH/advancingMS/*.simg

### TODO

* Make the code directory read-only (involves the final `pandoc` workspace)
* Distribute the task across multiple compute nodes
