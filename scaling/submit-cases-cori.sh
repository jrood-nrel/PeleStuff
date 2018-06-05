#!/bin/bash -l

set -e

# Job settings
EMAIL="jon.rood@nrel.gov"
ALLOCATION="m2860"
TEST_RUN="TRUE"

# Create list of jobs with varying parameters to submit
declare -a JOBS
#JOBS[x]='job_name:queue:cpu_type:exe_path:input_file:nodes:ranks_per_node:hypercores_per_thread:minutes'
JOBS[0]='pelec-scaling:debug:haswell:./PeleC3d.intel.haswell.MPI.OMP.ex:input-3d:1:8:2:20'

if [ "${TEST_RUN}" == 'TRUE' ]; then
   EXTRA_ARGS="--test-only"
else
   exec &> >(tee -a "submit-cases-cori-$(date +%M-%H-%d-%m-%Y).log")
fi

printf "Submitting these job configurations:\n"
for JOB in "${JOBS[@]}"; do
   printf " ${JOB}\n"
done

# Job script submission
for JOB in "${JOBS[@]}"; do
   PARAMETER=(${JOB//:/ })
   JOB_NAME=${PARAMETER[0]}
   QUEUE=${PARAMETER[1]}
   CPU_TYPE=${PARAMETER[2]}
   PELEC_EXE=${PARAMETER[3]}
   INPUT_FILE=${PARAMETER[4]}
   NODES=${PARAMETER[5]}
   RANKS_PER_NODE=${PARAMETER[6]}
   HYPERCORES_PER_THREAD=${PARAMETER[7]}
   JOB_TIME_IN_MINUTES=${PARAMETER[8]}

   # Cori CPU logic
   if [ "${CPU_TYPE}" == 'knl' ]; then
      CORES_PER_NODE=64
      HYPERTHREADS=4
      KNL_CORE_SPECIALIZATION="-S 4"
   elif [ "${CPU_TYPE}" == 'haswell' ]; then
      CORES_PER_NODE=32
      HYPERTHREADS=2
   fi

   RANKS=$((${NODES} * ${RANKS_PER_NODE}))
   CORES=$((${CORES_PER_NODE} * ${NODES}))
   CORES_PER_RANK=$((${HYPERTHREADS} * ${CORES_PER_NODE} / ${RANKS_PER_NODE}))
   THREADS_PER_RANK=$((${CORES_PER_RANK} / ${HYPERCORES_PER_THREAD}))

   printf "Submitting ${NODES} node job...\n"
   (set -x; sbatch \
            -A ${ALLOCATION} \
            -L SCRATCH \
            -C ${CPU_TYPE} \
            -J ${JOB_NAME}-${NODES} \
            -o %x.o%j \
            -q ${QUEUE} \
            -N ${NODES} \
            -t ${JOB_TIME_IN_MINUTES} \
            --mail-user=${EMAIL} \
            --mail-type=NONE \
            --export=NODES=${NODES},RANKS=${RANKS},CORES_PER_RANK=${CORES_PER_RANK},CORES=${CORES},THREADS_PER_RANK=${THREADS_PER_RANK},PELEC_EXE="${PELEC_EXE}",INPUT_FILE="${INPUT_FILE}" \
            ${KNL_CORE_SPECIALIZATION} \
            ${EXTRA_ARGS} \
            run-case.sh)
   printf "\n"
done
