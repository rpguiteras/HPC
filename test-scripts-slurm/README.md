# Slurm test scripts

Two minimal Slurm batch scripts for confirming your access to the NCSU Hazel
cluster after the LSF-to-Slurm migration. Each prints the node hostname, the
Slurm job ID, and the date, then exits -- just enough to confirm a job was
scheduled and ran.

| Script | What it tests |
| --- | --- |
| `test_slurm.sh` | General Slurm access. Submits to your default partition. |
| `test_slurm_are.sh` | Access to the ARE partner node (`p_are`). Adds `#SBATCH --partition=compute_partners` to route the job to the partner partition. |

## Usage

~~~
sbatch test_slurm.sh
sbatch test_slurm_are.sh
~~~

Check progress with `squeue -u $USER` or `sj JOBID`. When a job finishes it
writes `<job-name>.<jobid>.out` (and `<job-name>.<jobid>.err` if anything went to
stderr) in the directory you submitted from -- e.g. `slurm_test.12345.out`. The
`Hello from ...` line in the `.out` file tells you which node ran it.

Only ARE users granted access to the `are` node can run `test_slurm_are.sh`; if
you lack access the job will be rejected or stay pending. See
[Using partner nodes](https://hpc.ncsu.edu/RunningJobs/PartnerJobs.php) for
details on the `compute_partners` partition.

## Line endings

These scripts must use Unix (LF) line endings. A `.sh` script saved with Windows
(CRLF) endings fails with a `bad interpreter` error because the `#!/bin/bash`
shebang line is misparsed.
