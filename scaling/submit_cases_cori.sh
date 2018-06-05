#!/bin/bash -l

set -e

# Job settings
EMAIL="jon.rood@nrel.gov"
JOB_NAME="pelec-scaling"
QUEUE="debug"
CPU_TYPE="haswell"
ALLOCATION="m2860"
PELEC_EXE="./PeleC3d.intel.ivybridge.MPI.OMP.ex"
INPUT_FILE="inputs_3d"

# Create list of jobs with varying parameters to submit
declare -a JOBS
#JOBS[x]='nodes:minutes'
JOBS[0]='1:20'
JOBS[1]='2:10'

# Cori CPU logic
if [ "${CPU_TYPE}" == 'knl' ]; then
   #Machine defined
   CORES_PER_NODE=64
   HYPERTHREADS=4
   #User defined
   RANKS_PER_NODE=16
   HYPERCORES_PER_THREAD=4
   CORES_PER_RANK=$((${HYPERTHREADS} * ${CORES_PER_NODE} / ${RANKS_PER_NODE}))
   EXTRA_ARGS="-S 4"
elif [ "${CPU_TYPE}" == 'haswell' ]; then
   #Machine defined
   CORES_PER_NODE=32
   HYPERTHREADS=2
   #User defined
   RANKS_PER_NODE=4
   HYPERCORES_PER_THREAD=2
   CORES_PER_RANK=$((${HYPERTHREADS} * ${CORES_PER_NODE} / ${RANKS_PER_NODE}))
fi

# Job script submission
for JOB in "${JOBS[@]}"; do
   PARAMETER=(${JOB//:/ })
   NODES=${PARAMETER[0]}
   JOB_TIME_IN_MINUTES=${PARAMETER[1]}
   RANKS=$((${NODES} * ${RANKS_PER_NODE}))
   CORES=$((${CORES_PER_NODE} * ${NODES}))
   THREADS_PER_RANK=$((${CORES_PER_RANK} / ${HYPERCORES_PER_THREAD}))
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
            --mail-type=ALL \
            --export=NODES=${NODES},RANKS=${RANKS},CORES_PER_RANK=${CORES_PER_RANK},CORES=${CORES},THREADS_PER_RANK=${THREADS_PER_RANK},PELEC_EXE="${PELEC_EXE}",INPUT_FILE="${INPUT_FILE}" \
            ${EXTRA_ARGS} \
            run_case.sh)
   printf "\n"
done
