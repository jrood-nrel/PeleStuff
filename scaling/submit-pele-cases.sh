#!/bin/bash -l

# Function for printing and executing commands
cmd() {
  echo "+ $@"
  eval "$@"
}

# Function for submitting job based on machine
submit_job() {
  if [ "${MACHINE}" == 'peregrine' ]; then
     (set -x; qsub \
              -A ${ALLOCATION} \
              -N ${JOB_NAME}-${INDEX} \
              -q ${QUEUE} \
              -l nodes=${NODES}:ppn=${CORES_PER_NODE} \
              -l walltime=${JOB_TIME} \
              -l feature=${CPU_TYPE} \
              -j oe \
              -m p \
              -M ${EMAIL} \
              -W umask=002 \
              -v MACHINE=${MACHINE},COMPILER=${COMPILER},NODES=${NODES},RANKS=${RANKS},CORES_PER_RANK=${CORES_PER_RANK},RANKS_PER_NODE=${RANKS_PER_NODE},CORES=${CORES},THREADS_PER_RANK=${THREADS_PER_RANK},PELEC_EXE=${PELEC_EXE},INPUT_FILE=${INPUT_FILE},INPUT_FILE_ARGS="${SERIALISED_INPUT_FILE_ARGS}" \
              ${EXTRA_ARGS} \
              ${OWD}/run-pele-case.sh)
  elif [ "${MACHINE}" == 'cori' ]; then
     # If we're testing, do a fake job submission to slurm, otherwise log this script's output
     if [ "${TEST_RUN}" == 'TRUE' ]; then
        EXTRA_ARGS="--test-only"
     fi
     (set -x; sbatch \
              -A ${ALLOCATION} \
              -L SCRATCH \
              -C ${CPU_TYPE} \
              -J ${JOB_NAME}-${INDEX} \
              -o %x.o%j \
              -q ${QUEUE} \
              -N ${NODES} \
              -t ${JOB_TIME} \
              --mail-user=${EMAIL} \
              --mail-type=NONE \
              --export=MACHINE=${MACHINE},NODES=${NODES},RANKS=${RANKS},CORES_PER_RANK=${CORES_PER_RANK},CORES=${CORES},THREADS_PER_RANK=${THREADS_PER_RANK},PELEC_EXE="${PELEC_EXE}",INPUT_FILE="${INPUT_FILE}",INPUT_FILE_ARGS="${INPUT_FILE_ARGS[$INDEX]}" \
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
   JOB_TIME=${PARAMETER[8]}

   if [ "${MACHINE}" == 'peregrine' ]; then
      JOB_TIME=$((${JOB_TIME} * 60))
      ALLOCATION="ExaCT"
      # Peregrine CPU logic
      if [ "${CPU_TYPE}" == 'haswell' ]; then
         CORES_PER_NODE=24
         HYPERTHREADS=2
      fi
      # Need to serialise the input file arguments because qsub can't
      # parse anything beyond a normal string when passing arguments
      SERIALISED_INPUT_FILE_ARGS=$(printf "\0%s" "${INPUT_FILE_ARGS[$INDEX]}" | base64)
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
   fi

   RANKS=$((${NODES} * ${RANKS_PER_NODE}))
   CORES=$((${CORES_PER_NODE} * ${NODES}))
   CORES_PER_RANK=$((${HYPERTHREADS} * ${CORES_PER_NODE} / ${RANKS_PER_NODE}))
   THREADS_PER_RANK=$((${CORES_PER_RANK} / ${HYPERCORES_PER_THREAD}))

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
