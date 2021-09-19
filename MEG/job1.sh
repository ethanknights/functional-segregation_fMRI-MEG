#!/bin/bash
#SBATCH -J job1
#SBATCH -o job1.out
#SBATCH --mem-per-cpu 2G
#SBATCH --time 108:00:00

/hpc-software/matlab/r2019a/bin/matlab -nodesktop -nosplash \
cd /imaging/camcan/sandbox/ek03/projects/functional-segregation_fMRI-MEG/MEG \
-r preproc_beamform_ROI