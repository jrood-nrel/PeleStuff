#!/bin/bash -l

set -e

# Function for printing and executing commands
cmd() {
  echo "+ $@"
  eval "$@"
}

echo "Running with ${RANKS} ranks and ${THREADS_PER_RANK} threads on ${NODES} nodes with a total of ${CORES} cores..."

cmd "export OMP_NUM_THREADS=${THREADS_PER_RANK}"
cmd "export OMP_PLACES=threads"
cmd "export OMP_PROC_BIND=spread"

(set -x; srun -n ${RANKS} -c ${CORES_PER_RANK} --cpu_bind=cores ${PELEC_EXE} ${INPUT_FILE})
