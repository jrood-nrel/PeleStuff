#!/bin/bash -l

set -e
OWD=$(pwd)

# Basic job settings
EMAIL="jon.rood@nrel.gov"
ALLOCATION="ExaCT"

# Create list of jobs with varying parameters to submit
COMPILER=intel
EXAMPLE_JOB='job_name:queue:cpu_type:exe_path:input_file:nodes:ranks_per_node:hypercores_per_thread:seconds'
declare -a JOBS
declare -a INPUT_FILE_ARGS
JOBS[1]="pelec-scaling:short:haswell:${OWD}/PeleC3d.${COMPILER}.MPI.ex:${OWD}/input-3d:1:12:2:1800"
INPUT_FILE_ARGS[1]='amr.n_cell=128 128 128'
JOBS[2]="pelec-scaling:short:haswell:${OWD}/PeleC3d.${COMPILER}.MPI.ex:${OWD}/input-3d:4:24:2:1800"
INPUT_FILE_ARGS[2]='amr.n_cell=256 256 256'
#JOBS[3]="pelec-scaling:batch-h:haswell:${OWD}/PeleC3d.${COMPILER}.MPI.ex:${OWD}/input-3d:32:24:2:1800"
#INPUT_FILE_ARGS[3]='amr.n_cell=512 512 512'
#JOBS[4]="pelec-scaling:batch-h:haswell:${OWD}/PeleC3d.${COMPILER}.MPI.ex:${OWD}/input-3d:256:24:2:1800"
#INPUT_FILE_ARGS[4]='amr.n_cell=1024 1024 1024'

# Put everything in a new directory labeled with a date
CASE_SET="submit-cases-peregrine-$(date +%Y-%m-%d-%H-%M)"
mkdir ${OWD}/${CASE_SET} && cd ${OWD}/${CASE_SET}
(set -x; cp ${OWD}/*.dat ${OWD}/${CASE_SET}/ || true)
exec &> >(tee "${OWD}/${CASE_SET}/${CASE_SET}.log")

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
   JOB_TIME_IN_SECONDS=${PARAMETER[8]}

   # Peregrine CPU logic
   if [ "${CPU_TYPE}" == 'haswell' ]; then
      CORES_PER_NODE=24
      HYPERTHREADS=2
   fi

   RANKS=$((${NODES} * ${RANKS_PER_NODE}))
   CORES=$((${CORES_PER_NODE} * ${NODES}))
   CORES_PER_RANK=$((${HYPERTHREADS} * ${CORES_PER_NODE} / ${RANKS_PER_NODE}))
   THREADS_PER_RANK=$((${CORES_PER_RANK} / ${HYPERCORES_PER_THREAD}))

   # Need to serialise the input file arguments because qsub can't
   # parse anything beyond a normal string when passing arguments
   SERIALISED_INPUT_FILE_ARGS=$(printf "\0%s" "${INPUT_FILE_ARGS[$INDEX]}" | base64)

   printf "Submitting job ${INDEX}...\n"
   (set -x; qsub \
            -A ${ALLOCATION} \
            -N ${JOB_NAME}-${INDEX} \
            -q ${QUEUE} \
            -l nodes=${NODES}:ppn=${CORES_PER_NODE} \
            -l walltime=${JOB_TIME_IN_SECONDS} \
            -l feature=${CPU_TYPE} \
            -j oe \
            -m p \
            -M ${EMAIL} \
            -W umask=002 \
            -v COMPILER=${COMPILER},NODES=${NODES},RANKS=${RANKS},CORES_PER_RANK=${CORES_PER_RANK},RANKS_PER_NODE=${RANKS_PER_NODE},CORES=${CORES},THREADS_PER_RANK=${THREADS_PER_RANK},PELEC_EXE=${PELEC_EXE},INPUT_FILE=${INPUT_FILE},INPUT_FILE_ARGS="${SERIALISED_INPUT_FILE_ARGS}" \
            ${EXTRA_ARGS} \
            ${OWD}/run-case-peregrine.sh)
   INDEX=$((INDEX+1))
   printf "\n"
done

printf "\n"
