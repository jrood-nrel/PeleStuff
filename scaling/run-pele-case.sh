#!/bin/bash -l

set -e

# Function for printing and executing commands
cmd() {
  echo "+ $@"
  eval "$@"
}

echo "Running with ${RANKS} ranks and ${THREADS_PER_RANK} threads on ${NODES} nodes with a total of ${CORES} cores..."

if [ "${MACHINE}" == 'peregrine' ]; then
   cmd "module purge"
   cmd "module use /nopt/nrel/ecom/ecp/base/modules/gcc-6.2.0"
   cmd "module load gcc/6.2.0"
   cmd "module load git/2.17.0"
   cmd "module load python/2.7.14"
   if [ "${COMPILER}" == 'gnu' ]; then
      cmd "module load openmpi/1.10.4"
   elif [ "${COMPILER}" == 'intel' ]; then
      cmd "module load intel-parallel-studio/cluster.2018.1"
   fi
   
   cmd "export OMP_NUM_THREADS=${THREADS_PER_RANK}"
   cmd "export OMP_PLACES=threads"
   cmd "export OMP_PROC_BIND=spread"
   
   DESERIALISED_INPUT_FILE_ARGS=$(printf "%s" "${INPUT_FILE_ARGS}" | base64 --decode)
   
   if [ "${COMPILER}" == 'gnu' ]; then
      cmd "mpirun -np ${RANKS} --map-by ppr:${RANKS_PER_NODE}:node --bind-to core ${PELEC_EXE} ${INPUT_FILE} ${DESERIALISED_INPUT_FILE_ARGS}"
   elif [ "${COMPILER}" == 'intel' ]; then
      # Process binding should happen by default
      cmd "mpirun -n ${RANKS} -ppn ${RANKS_PER_NODE} ${PELEC_EXE} ${INPUT_FILE} ${DESERIALISED_INPUT_FILE_ARGS}"
   fi
elif [ "${MACHINE}" == 'cori' ]; then
   cmd "module load ipm"
   cmd "export IPM_REPORT=full IPM_LOG=full"
   cmd "export OMP_NUM_THREADS=${THREADS_PER_RANK}"
   cmd "export OMP_PLACES=threads"
   cmd "export OMP_PROC_BIND=spread"
   cmd "srun -n ${RANKS} -c ${CORES_PER_RANK} --cpu_bind=cores ${PELEC_EXE} ${INPUT_FILE} ${INPUT_FILE_ARGS}"
fi
