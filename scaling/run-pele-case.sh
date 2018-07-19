#!/bin/bash -l

# #DW jobdw capacity=500GB access_mode=striped type=scratch
# #DW stage_out source=$DW_JOB_STRIPED/$THIS_JOB_NAME destination=$THIS_JOB_DIR/output type=directory

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
   cmd "module load git"
   cmd "module load python"
   if [ "${COMPILER}" == 'gnu' ]; then
      cmd "module load openmpi"
   elif [ "${COMPILER}" == 'intel' ]; then
      cmd "module load intel-parallel-studio/cluster.2018.1"
   fi
   
   cmd "export OMP_NUM_THREADS=${THREADS_PER_RANK}"
   
   if [ "${COMPILER}" == 'gnu' ]; then
      cmd "${DESERIALISED_PRE_ARGS} mpirun -np ${RANKS} --map-by ppr:${RANKS_PER_NODE}:node:pe=${THREADS_PER_RANK} -bind-to core -x OMP_NUM_THREADS ${PELEC_EXE} ${INPUT_FILE} ${DESERIALISED_POST_ARGS}"
   elif [ "${COMPILER}" == 'intel' ]; then
      MY_TMP_DIR=/scratch/${USER}/.tmp
      NODE_LIST=${MY_TMP_DIR}/node_list.${PBS_JOBID}
      cmd "mkdir -p ${MY_TMP_DIR}"
      cmd "cat ${PBS_NODEFILE} > ${NODE_LIST}"
      #cmd "export I_MPI_DEBUG=5"
      cmd "export I_MPI_FABRIC_LIST=ofa,dapl"
      cmd "export I_MPI_FABRICS=shm:ofa"
      cmd "export I_MPI_FALLBACK=0"
      cmd "export I_MPI_PIN=1"
      cmd "export I_MPI_PIN_DOMAIN=omp"
      cmd "export KMP_AFFINITY=compact,granularity=core"
      cmd "${DESERIALISED_PRE_ARGS} mpirun -genvall -f ${NODE_LIST} -n ${RANKS} -ppn ${RANKS_PER_NODE} ${PELEC_EXE} ${INPUT_FILE} ${DESERIALISED_POST_ARGS}"
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

   # Without burst buffer
   cmd "${DESERIALISED_PRE_ARGS} srun -n ${RANKS} -c ${CORES_PER_RANK} --cpu_bind=${CPU_BIND} ${MY_EXE} ${INPUT_FILE} ${DESERIALISED_POST_ARGS}"
   # With burst buffer
   #cmd "${DESERIALISED_PRE_ARGS} srun -n ${RANKS} -c ${CORES_PER_RANK} --cpu_bind=${CPU_BIND} ${MY_EXE} ${INPUT_FILE} ${DESERIALISED_POST_ARGS} amr.plot_file=${DW_JOB_STRIPED}/${THIS_JOB_NAME}/plt amr.check_file=${DW_JOB_STRIPED}/${THIS_JOB_NAME}/chk"
fi
