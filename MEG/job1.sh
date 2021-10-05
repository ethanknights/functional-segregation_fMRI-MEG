#!/bin/bash
#SBATCH -J job1_noOthog
#SBATCH -o job1.out
#SBATCH --mem-per-cpu 12G
#SBATCH --time 108:00:00
#SBATCH --mail-type=end          # email when job begin | fail | end |
#SBATCH --mail-type=fail         # email if job fails
#SBATCH --mail-user=ethan.knights@mrc-cbu.cam.ac.uk

/hpc-software/matlab/r2019a/bin/matlab -nodesktop -nosplash \
cd /imaging/camcan/sandbox/ek03/projects/functional-segregation_fMRI-MEG/MEG \
-r runAnalysis