#!/bin/bash -l

set -e

# Function for printing and executing commands
cmd() {
  echo "+ $@"
  eval "$@"
}

echo "Running with ${RANKS} ranks and ${THREADS_PER_RANK} threads on ${NODES} nodes with a total of ${CORES} cores..."

DESERIALISED_POST_ARGS=$(printf "%s" "${POST_ARGS}" | base64 --decode --wrap=0)
DESERIALISED_PRE_ARGS=$(printf "%s" "${PRE_ARGS}" | base64 --decode --wrap=0)

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
   
   if [ "${COMPILER}" == 'gnu' ]; then
      cmd "${DESERIALISED_PRE_ARGS} mpirun -x OMP_NUM_THREADS -x OMP_PLACES -x OMP_PROC_BIND -np ${RANKS} --map-by ppr:${RANKS_PER_NODE}:node --bind-to core ${PELEC_EXE} ${INPUT_FILE} ${DESERIALISED_POST_ARGS}"
   elif [ "${COMPILER}" == 'intel' ]; then
      cmd "mkdir -p /scratch/${USER}/.tmp"
      cmd "cat ${PBS_NODEFILE} > /scratch/${USER}/.tmp/node_list"
      cmd "export I_MPI_FABRICS=shm:dapl"
      cmd "export I_MPI_FALLBACK=0"
      #cmd "export I_MPI_PIN_DOMAIN=omp"
      cmd "${DESERIALISED_PRE_ARGS} mpirun -machine /scratch/${USER}/.tmp/node_list -n ${RANKS} -ppn ${RANKS_PER_NODE} ${PELEC_EXE} ${INPUT_FILE} ${DESERIALISED_POST_ARGS}"
   fi
elif [ "${MACHINE}" == 'cori' ]; then
   cmd "module load ipm"
   cmd "export IPM_REPORT=full IPM_LOG=full"
   cmd "export OMP_NUM_THREADS=${THREADS_PER_RANK}"
   cmd "export OMP_PLACES=threads"
   cmd "export OMP_PROC_BIND=spread"

   if [ "${CPU_TYPE}" == 'knl' ]; then
      cmd "module swap craype-haswell craype-mic-knl || true"
   fi

   if [ "${CPU_TYPE}" == 'knl' ] && ((NODES>156)); then
      MY_EXE=/tmp/pelec.ex
      cmd "sbcast -f -F2 -t 300 --compress=lz4 ${PELEC_EXE} ${MY_EXE}"
   else
      MY_EXE=${PELEC_EXE}
   fi

   cmd "${DESERIALISED_PRE_ARGS} srun -n ${RANKS} -c ${CORES_PER_RANK} --cpu_bind=${CPU_BIND} ${MY_EXE} ${INPUT_FILE} ${DESERIALISED_POST_ARGS}"
fi
