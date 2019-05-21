#!/bin/sh

docker run \
    -v $(pwd):/ms:ro \
    -v $(pwd)/../data:/data:ro \
    -v $(pwd)/../output:/output \
    whoi/advancingms
