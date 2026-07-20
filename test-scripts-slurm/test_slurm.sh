#!/bin/bash
#SBATCH --job-name=slurm_test
#SBATCH --output=%x.%j.out
#SBATCH --error=%x.%j.err
#SBATCH --ntasks=1
#SBATCH --time=00:10:00

echo "Hello from $(hostname)"
echo "Job ID: $SLURM_JOB_ID"
date
