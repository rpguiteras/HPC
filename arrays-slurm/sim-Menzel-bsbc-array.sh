#!/bin/bash
#SBATCH --job-name=bsbcBeta4
#SBATCH --array=1-1728%50        ## total rows in index file; %50 throttles concurrency
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --nodes=1
#SBATCH --time=24:00:00
#SBATCH --mem=4G
#SBATCH --partition=compute      ## ARE's Slurm partition/QOS name is not yet published by NCSU -- confirm with `sa`/`sqos -v` or HPC support before relying on this
#SBATCH --output=hpc_out/bsbcBeta4_%A_%a.out
#SBATCH --error=hpc_out/bsbcBeta4_%A_%a.err

module load stata-are/19

bash ./sim-Menzel-bsbc-array-item.sh $SLURM_ARRAY_TASK_ID
