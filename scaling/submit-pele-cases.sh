#!/bin/bash -l

# Function for printing and executing commands
cmd() {
  echo "+ $@"
  eval "$@"
}

# Function for submitting job based on machine
submit_job() {
  THIS_JOB_NAME=${JOB_NAME}-${INDEX}
  if [ "${MACHINE}" == 'peregrine' ]; then
     (set -x; qsub \
              -A ${ALLOCATION} \
              -N ${THIS_JOB_NAME} \
              -q ${QUEUE} \
              -l nodes=${NODES}:ppn=${CORES_PER_NODE} \
              -l walltime=${JOB_TIME} \
              -l feature=${CPU_TYPE} \
              -j oe \
              -m p \
              -M ${EMAIL} \
              -W umask=002 \
              -v THIS_JOB_DIR=${THIS_JOB_DIR},THIS_JOB_NAME=${THIS_JOB_NAME},MACHINE=${MACHINE},COMPILER=${COMPILER},NODES=${NODES},RANKS=${RANKS},CORES_PER_NODE=${CORES_PER_NODE},CORES_PER_RANK=${CORES_PER_RANK},RANKS_PER_NODE=${RANKS_PER_NODE},CORES=${CORES},THREADS_PER_RANK=${THREADS_PER_RANK},CPU_TYPE=${CPU_TYPE},PELEC_EXE=${PELEC_EXE},INPUT_FILE=${INPUT_FILE},PRE_ARGS="${SERIALISED_PRE_ARGS}",POST_ARGS="${SERIALISED_POST_ARGS}" \
              ${EXTRA_ARGS} \
              ${OWD}/run-pele-case.sh)
  elif [ "${MACHINE}" == 'cori' ]; then
     # If we're testing, do a fake job submission to slurm
     if [ "${TEST_RUN}" == 'TRUE' ]; then
        EXTRA_ARGS="--test-only"
     fi
     (set -x; sbatch \
              -A ${ALLOCATION} \
              -L SCRATCH \
              -C ${CPU_TYPE} \
              -J ${THIS_JOB_NAME} \
              -o %x.o%j \
              -q ${QUEUE} \
              -N ${NODES} \
              -t ${JOB_TIME} \
              --mail-user=${EMAIL} \
              --mail-type=NONE \
              --export=THIS_JOB_DIR=${THIS_JOB_DIR},THIS_JOB_NAME=${THIS_JOB_NAME},MACHINE=${MACHINE},NODES=${NODES},RANKS=${RANKS},CORES_PER_NODE=${CORES_PER_NODE},CORES_PER_RANK=${CORES_PER_RANK},RANKS_PER_NODE=${RANKS_PER_NODE},CORES=${CORES},THREADS_PER_RANK=${THREADS_PER_RANK},CPU_BIND=${CPU_BIND},CPU_TYPE=${CPU_TYPE},PELEC_EXE=${PELEC_EXE},INPUT_FILE=${INPUT_FILE},PRE_ARGS="${SERIALISED_PRE_ARGS}",POST_ARGS="${SERIALISED_POST_ARGS}" \
              ${KNL_CORE_SPECIALIZATION} \
              ${EXTRA_ARGS} \
              ${OWD}/run-pele-case.sh)
  fi
}

if [ "${NERSC_HOST}" == 'cori' ]; then
   MACHINE='cori'
elif [ "$(hostname -d)" == 'hpc.nrel.gov' ]; then
   MACHINE='peregrine'
else
  printf "Can't detect machine.\n"
  exit 1
fi

# Stop on all errors
set -e
# Save original working directory
OWD=$(pwd)
# Get job case list from external file
source ${OWD}/pele-case-list.sh

# Put everything in a new directory labeled with a date
CASE_SET="pele-cases-$(date +%Y-%m-%d-%H-%M)"
cmd "mkdir ${OWD}/${CASE_SET} && cd ${OWD}/${CASE_SET}"
printf "\n"
exec &> >(tee "${OWD}/${CASE_SET}/${CASE_SET}.log")

printf "Machine detected as ${MACHINE}.\n\n"

# Display list of jobs that will be submitted
printf "Submitting these job configurations:\n"
printf " - ${EXAMPLE_JOB}\n\n"
INDEX=1
for JOB in "${JOBS[@]}"; do
   printf "${INDEX}: ${JOB}\n"
   printf "     - PRE_ARGS: ${PRE_ARGS[$INDEX]}\n"
   printf "     - POST_ARGS: ${POST_ARGS[$INDEX]}\n"
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
   JOB_TIME=${PARAMETER[7]}

   if [ "${MACHINE}" == 'peregrine' ]; then
      JOB_TIME=$((${JOB_TIME} * 60))
      ALLOCATION="ExaCT"
      # Peregrine CPU logic
      if [ "${CPU_TYPE}" == 'haswell' ]; then
         CORES_PER_NODE=24
         HYPERTHREADS=2
      fi
   elif [ "${MACHINE}" == 'cori' ]; then
      ALLOCATION="m2860"
      # Cori CPU logic
      if [ "${CPU_TYPE}" == 'knl' ]; then
         CORES_PER_NODE=64
         HYPERTHREADS=4
         KNL_CORE_SPECIALIZATION="-S 4"
      elif [ "${CPU_TYPE}" == 'haswell' ]; then
         CORES_PER_NODE=32
         HYPERTHREADS=2
      fi
      if ((RANKS_PER_NODE<=CORES_PER_NODE)); then
         CPU_BIND=cores
      else
         CPU_BIND=threads
      fi
   fi

   # Serializing pre and post arguments so we don't have worry about quoting, etc.
   SERIALISED_PRE_ARGS=$(printf "\0%s" "${PRE_ARGS[$INDEX]}" | base64 --wrap=0)
   SERIALISED_POST_ARGS=$(printf "\0%s" "${POST_ARGS[$INDEX]}" | base64 --wrap=0)

   RANKS=$((${NODES} * ${RANKS_PER_NODE}))
   CORES_PER_RANK=$((${HYPERTHREADS} * ${CORES_PER_NODE} / ${RANKS_PER_NODE}))
   HYPERCORES_PER_THREAD=2 # Don't use hyperthreading on haswell, but use two hyperthreads on KNL
   THREADS_PER_RANK=$((${CORES_PER_RANK} / ${HYPERCORES_PER_THREAD}))
   CORES=$((${THREADS_PER_RANK} * ${RANKS}))

   # Check that exe and input file exist before submitting
   if [ ! -f "${PELEC_EXE}" ]; then
      printf "${PELEC_EXE} does not exist.\n"
      exit 1
   fi
   if [ ! -f "${INPUT_FILE}" ]; then
      printf "${INPUT_FILE} does not exist.\n"
      exit 1
   fi

   printf "Creating directory for job ${INDEX} and copying files...\n"
   THIS_JOB_DIR=${OWD}/${CASE_SET}/${JOB_NAME}-${INDEX}
   cmd "mkdir ${THIS_JOB_DIR} && cd ${THIS_JOB_DIR}"
   (set -x; cp ${OWD}/*.dat ${THIS_JOB_DIR}/ || true)

   printf "Submitting job ${INDEX}...\n"
   submit_job

   INDEX=$((INDEX+1))
   printf "\n"
done
