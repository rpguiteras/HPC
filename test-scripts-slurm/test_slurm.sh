#!/bin/bash
#SBATCH --job-name=slurm_test
#SBATCH --output=test.out.%j
#SBATCH --error=test.err.%j
#SBATCH --ntasks=1
#SBATCH --time=00:10:00

echo "Hello from $(hostname)"
echo "Job ID: $SLURM_JOB_ID"
date
