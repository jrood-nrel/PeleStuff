#!/bin/bash -l

set -e

# Function for printing and executing commands
cmd() {
  echo "+ $@"
  eval "$@"
}

echo "Running with ${RANKS} ranks and ${THREADS_PER_RANK} threads on ${NODES} nodes with a total of ${CORES} cores..."

cmd "module purge"
cmd "module use /nopt/nrel/ecom/ecp/base/modules/gcc-6.2.0"
cmd "module load gcc/6.2.0"
cmd "module load git/2.17.0"
cmd "module load python/2.7.14"
cmd "module load openmpi/1.10.4"

cmd "export OMP_NUM_THREADS=${THREADS_PER_RANK}"
cmd "export OMP_PLACES=threads"
cmd "export OMP_PROC_BIND=spread"

cmd "mpirun -np ${RANKS} --map-by ppr:${RANKS_PER_NODE}:node --bind-to core ${PELEC_EXE} ${INPUT_FILE} ${INPUT_FILE_ARGS}"
