#!/bin/sh
#SBATCH --job-name=advancingMS # Job name
#SBATCH --mail-type=NONE # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=rgovostes@whoi.edu # Where to send mail	
#SBATCH --nodes=1 #Number of nodes
#SBATCH --ntasks=36
#SBATCH --ntasks-per-node=36
#SBATCH --mem=180gb
#SBATCH --time=08:00:00
#SBATCH --output=%j.out # Standard output and error log
#SBATCH --partition=compute

module purge
module load default-environment
module load singularity/2.5.2

date

# Create files
rm -Rf $SCRATCH/data_$SLURM_JOB_ID
mkdir $SCRATCH/data_$SLURM_JOB_ID
echo "NUMBER OF DATA FILES = $1"
for file in $(ls -p for_is/mzML_withMSn_CubaFiles | grep -v / | head -n $1); do
    cp $(pwd)/for_is/mzML_withMSn_CubaFiles/$file $SCRATCH/data_$SLURM_JOB_ID/
done

# Create output directory
rm -Rf $SCRATCH/output_$SLURM_JOB_ID
mkdir $SCRATCH/output_$SLURM_JOB_ID
echo "$1" >> $SCRATCH/output_$SLURM_JOB_ID/n.txt

cp -ra advancingMS $SCRATCH/advancingMS_$SLURM_JOB_ID

time singularity run \
    --contain \
    --bind "$SCRATCH/advancingMS_$SLURM_JOB_ID:/ms:rw,$SCRATCH/data_$SLURM_JOB_ID:/data:ro,$SCRATCH/output_$SLURM_JOB_ID:/output" \
    whoi_advancingms.simg 
date
