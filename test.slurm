#!/bin/bash -l

#SBATCH --cluster=hydra
#SBATCH --partition=zen4
#SBATCH --ntasks-per-node=8
#SBATCH --nodes=1
#SBATCH --time=01:00:00

# Instead of installing dependencies yourself, you can simply load modules on
# the cluster. The versions are just examples, you can check for available
# modules with a command like "module spider OpenSim"
module load MATLAB/2024a-r6

matlab -nodisplay -r "test_par"
