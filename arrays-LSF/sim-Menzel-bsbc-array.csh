#!/bin/tcsh
#BSUB -J bsbcBeta4[1-1728]   #job name AND job array
#BSUB -n 4                 #number of cores
#BSUB -W 23:59           #walltime limit: hh:mm
#BSUB -R "span[hosts=1]"        ## all cores on same node
#BSUB -R "rusage[mem=4GB]"     ## Specify maximum memory required
#BSUB -o hpc_out/bsbcBeta4_%J_%I.out #output - %J is the job-id %I is the job-array index
#BSUB -e hpc_out/bsbcBeta4_%J_%I.err  #error - %J is the job-id %I is the job-array index 


module load stata-are/18.5

# Program_name_and_options
source ./csh/sim-Menzel-bsbc-array-item.csh $LSB_JOBINDEX


