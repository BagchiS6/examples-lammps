#!/bin/bash

#SBATCH -A cph162
#SBATCH -J test
#SBATCH -o %x-%j.out
#SBATCH -e %x-%j.err
#SBATCH -t 02:00:00
#SBATCH -N 1

module load PrgEnv-amd
# PrgEnv-amd uses the `amd` module to load a version of ROCm compilers, so load an `amd` version that we're happy with
module load amd/5.5.1

# HWLOC is optional. No real performance benefit or gain
module load hwloc

# The `cmake` module is needed for building with `cmake`
module load cmake

# FFTW3 for host-based FFT
module load cray-fftw

export HIPCC_LINK_FLAGS_APPEND="-Wl,-rpath,/tmp/lmp_${LMPMACH}_libs"
export OMp_NUM_THREADS=1

export lmp=/autofs/nccs-svm1_proj/cph162/lammps_Jun12_2024/lammps/build/lmp
export lmp_input=in.MoS_cryst_opt.lmp
export NTASKS=56


#================================
## FOR RUNUNING ON CPUS
srun -n$NTASKS $lmp -in $lmp_input
#================================

#===================================
## FOR RUNNING ON GPUS (WITH KOKKOS)
export NGPUS=8
export NGPUS_PER_NODE=8
srun -n$NGPUS $lmp -k on g $NGPUS_PER_NODE -sf kk -pk kokkos neigh half newton on -in $lmp_input
#===================================
