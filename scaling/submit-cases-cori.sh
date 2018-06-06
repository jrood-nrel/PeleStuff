#!/bin/bash -l

set -e
OWD=$(pwd)

# Basic job settings
EMAIL="jon.rood@nrel.gov"
ALLOCATION="m2860"
TEST_RUN="FALSE"

# Create list of jobs with varying parameters to submit
EXAMPLE_JOB='job_name:queue:cpu_type:exe_path:input_file:nodes:ranks_per_node:hypercores_per_thread:minutes'
declare -a JOBS
declare -a INPUT_FILE_ARGS
JOBS[1]="pelec-scaling:debug:haswell:${OWD}/PeleC3d.intel.haswell.MPI.OMP.ex:${OWD}/input-3d:2:2:2:20"
INPUT_FILE_ARGS[1]=''
JOBS[2]="pelec-scaling:debug:haswell:${OWD}/PeleC3d.intel.haswell.MPI.OMP.ex:${OWD}/input-3d:2:4:2:20"
INPUT_FILE_ARGS[2]=''
JOBS[3]="pelec-scaling:debug:haswell:${OWD}/PeleC3d.intel.haswell.MPI.OMP.ex:${OWD}/input-3d:2:8:2:20"
INPUT_FILE_ARGS[3]=''
JOBS[4]="pelec-scaling:debug:haswell:${OWD}/PeleC3d.intel.haswell.MPI.OMP.ex:${OWD}/input-3d:2:16:2:20"
INPUT_FILE_ARGS[4]=''
JOBS[5]="pelec-scaling:debug:haswell:${OWD}/PeleC3d.intel.haswell.MPI.OMP.ex:${OWD}/input-3d:2:32:2:20"
INPUT_FILE_ARGS[5]=''

# If we're testing, do a fake job submission to slurm, otherwise log this script's output
if [ "${TEST_RUN}" == 'TRUE' ]; then
   EXTRA_ARGS="--test-only"
else
   # Put everything in a new directory labeled with a date
   CASE_SET="submit-cases-cori-$(date +%Y-%m-%d-%H-%M)"
   mkdir ${OWD}/${CASE_SET} && cd ${OWD}/${CASE_SET}
   (set -x; cp ${OWD}/*.dat ${OWD}/${CASE_SET}/ || true)
   exec &> >(tee "${OWD}/${CASE_SET}/${CASE_SET}.log")
fi

# Display list of jobs that will be submitted
printf "Submitting these job configurations:\n"
printf " - ${EXAMPLE_JOB}\n\n"
INDEX=1
for JOB in "${JOBS[@]}"; do
   printf "${INDEX}: ${JOB}\n"
   printf "     - ${INPUT_FILE_ARGS[$INDEX]}\n"
   INDEX=$((INDEX+1))
done
printf "\n"

# Do the job script submission for each job
INDEX=1
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

   printf "Submitting job ${INDEX}...\n"
   (set -x; sbatch \
            -A ${ALLOCATION} \
            -L SCRATCH \
            -C ${CPU_TYPE} \
            -J ${JOB_NAME}-${INDEX} \
            -o %x.o%j \
            -q ${QUEUE} \
            -N ${NODES} \
            -t ${JOB_TIME_IN_MINUTES} \
            --mail-user=${EMAIL} \
            --mail-type=NONE \
            --export=NODES=${NODES},RANKS=${RANKS},CORES_PER_RANK=${CORES_PER_RANK},CORES=${CORES},THREADS_PER_RANK=${THREADS_PER_RANK},PELEC_EXE="${PELEC_EXE}",INPUT_FILE="${INPUT_FILE}",INPUT_FILE_ARGS="${INPUT_FILE_ARGS[$INDEX]}" \
            ${KNL_CORE_SPECIALIZATION} \
            ${EXTRA_ARGS} \
            ${OWD}/run-case-cori.sh)
   INDEX=$((INDEX+1))
   printf "\n"
done

printf "\n"
