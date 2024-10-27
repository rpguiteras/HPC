#!/bin/tcsh
#BSUB -J simIndex[1-567]   #job name AND job array
#BSUB -n 4                 #number of cores
#BSUB -W 2:59           #walltime limit: hh:mm
#BSUB -R "span[hosts=1]"        ## all cores on same node
#BSUB -R "rusage[mem=4GB]"     ## Specify maximum memory required
#BSUB -o hpc_out/simIndex_%J_%I.out #output - %J is the job-id %I is the job-array index
#BSUB -e hpc_out/simIndex_%J_%I.err  #error - %J is the job-id %I is the job-array index 


module load stata-are/18.5

# Program_name_and_options
source ./csh/sim-Menzel-array-index-item.csh $LSB_JOBINDEX


