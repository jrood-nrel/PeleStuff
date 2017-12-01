#!/bin/bash -l

# Script for running benchmark suite for Pele on a set of machines

# Control over printing and executing commands
print_cmds=true
execute_cmds=true

# Function for printing and executing commands
cmd() {
  if ${print_cmds}; then echo "+ $@"; fi
  if ${execute_cmds}; then eval "$@"; fi
}

# Function for benchmarking a single configuration
benchmark_loop_body() {
  printf "************************************************************\n"
  printf "Benchmarking Pele with:\n"
  printf "${COMPILER_NAME}@${COMPILER_VERSION}\n"
  printf "CASE: ${CASE}\n"
  printf "INPUT_FILE: ${INPUT_FILE}\n"
  printf "at $(date).\n"
  printf "************************************************************\n"
  printf "\n"

  cmd "cd ${ROOT_DIR}"

  printf "\nLoading modules...\n"
  if [ "${MACHINE_NAME}" == 'peregrine' ]; then
    cmd "module purge"
    cmd "module use /nopt/nrel/apps/modules/candidate/modulefiles"
    cmd "module load gcc/5.2.0"
    cmd "module load python/2.7.8 &> /dev/null"
    cmd "module unload mkl"
    cmd "module load git/2.6.3"
    cmd "module list"
  fi

  #printf "\nSetting OpenMP stuff...\n"
  #cmd "eval export OMP_NUM_THREADS=1"
  #cmd "eval export OMP_PROC_BIND=false"

  printf "\nRunning benchmark at $(date)...\n"
  cmd "cd ${PELEC_DIR}/Exec/Benchmarks/${CASE}"
  #cmd "git clean -df"
  #cmd "make realclean"
  #cmd "make -j8"
  #cmd "mpirun"
  printf "Returned from benchmark at $(date)...\n"

  printf "\n"
  printf "************************************************************\n"
  printf "Done benchmarking Pele with:\n"
  printf "${COMPILER_NAME}@${COMPILER_VERSION}\n"
  printf "CASE: ${CASE}\n"
  printf "INPUT_FILE: ${INPUT_FILE}\n"
  printf "at $(date).\n"
  printf "************************************************************\n"
}

main() {
  printf "============================================================\n"
  printf "$(date)\n"
  printf "============================================================\n"
  printf "Job is running on $(hostname)\n"
  printf "============================================================\n"
  if [ ! -z "${PBS_JOBID}" ]; then
    printf "PBS: Qsub is running on ${PBS_O_HOST}\n"
    printf "PBS: Originating queue is ${PBS_O_QUEUE}\n"
    printf "PBS: Executing queue is ${PBS_QUEUE}\n"
    printf "PBS: Working directory is ${PBS_O_WORKDIR}\n"
    printf "PBS: Execution mode is ${PBS_ENVIRONMENT}\n"
    printf "PBS: Job identifier is ${PBS_JOBID}\n"
    printf "PBS: Job name is ${PBS_JOBNAME}\n"
    printf "PBS: Node file is ${PBS_NODEFILE}\n"
    printf "PBS: Current home directory is ${PBS_O_HOME}\n"
    printf "PBS: PATH = ${PBS_O_PATH}\n"
    printf "============================================================\n"
  fi
 
  if [ $# -ne 1 ]; then
      printf "$0: usage: $0 <machine>\n"
      exit 1
  else
    MACHINE_NAME="$1"
  fi
 
  # Set configurations to test for each machine
  if [ "${MACHINE_NAME}" == 'peregrine' ]; then
    declare -a LIST_OF_CASES=('Jet')
    declare -a LIST_OF_PELEC_HASHES=('123')
    declare -a LIST_OF_PELE_PHYSICS_HASHES=('123')
    declare -a LIST_OF_AMREX_HASHES=('123')
    declare -a LIST_OF_INPUT_FILES=('input1' 'input2')
    declare -a LIST_OF_COMPILERS=('intel')
    declare -a LIST_OF_GCC_COMPILERS=('5.2.0')
    declare -a LIST_OF_INTEL_COMPILERS=('17.0.2')
    declare -a LIST_OF_DATES=('2009-07-27 13:37')
    ROOT_DIR=${HOME}/combustion
  elif [ "${MACHINE_NAME}" == 'edison' ]; then
    declare -a LIST_OF_CASES=('Jet')
    declare -a LIST_OF_PELEC_HASHES=('123')
    declare -a LIST_OF_PELE_PHYSICS_HASHES=('123')
    declare -a LIST_OF_AMREX_HASHES=('123')
    declare -a LIST_OF_INPUT_FILES=('input1' 'input2')
    declare -a LIST_OF_COMPILERS=('intel')
    declare -a LIST_OF_GCC_COMPILERS=('4.9.2')
    declare -a LIST_OF_INTEL_COMPILERS=('17.0.2')
    declare -a LIST_OF_DATES=('2009-07-27 13:37')
    ROOT_DIR=${HOME}/combustion
  elif [ "${MACHINE_NAME}" == 'cori' ]; then
    declare -a LIST_OF_CASES=('Jet')
    declare -a LIST_OF_PELEC_HASHES=('123')
    declare -a LIST_OF_PELE_PHYSICS_HASHES=('123')
    declare -a LIST_OF_AMREX_HASHES=('123')
    declare -a LIST_OF_INPUT_FILES=('input1' 'input2')
    declare -a LIST_OF_COMPILERS=('intel')
    declare -a LIST_OF_GCC_COMPILERS=('7.2.0')
    declare -a LIST_OF_INTEL_COMPILERS=('17.0.2')
    declare -a LIST_OF_DATES=('2009-07-27 13:37')
    ROOT_DIR=${HOME}/combustion
  else
    printf "\nMachine name not recognized.\n"
  fi

  PELEC_DIR=${ROOT_DIR}/PeleC
  PELE_PHYSICS_DIR=${ROOT_DIR}/PelePhysics
  AMREX_DIR=${ROOT_DIR}/AMReX
 
  printf "\nMaking run output directory...\n"
  cmd "mkdir -p ${ROOT_DIR}/runs"

  printf "============================================================\n"
  printf "HOST_NAME: $(hostname)\n"
  printf "ROOT_DIR: ${ROOT_DIR}\n"
  printf "PELEC_DIR: ${PELEC_DIR}\n"
  printf "PELE_PHYSICS_DIR: ${PELE_PHYSICS_DIR}\n"
  printf "AMREX_DIR: ${AMREX_DIR}\n"
  #printf "PeleC Hash: $(cd ${PELEC_DIR} && git log --pretty=format:'%H' -n 1)\n"
  #printf "PelePhysics Hash: $(cd ${PELE_PHYSICS_DIR} && git log --pretty=format:'%H' -n 1)\n"
  #printf "AMReX Hash: $(cd ${AMREX_DIR} && git log --pretty=format:'%H' -n 1)\n"
  printf "Benchmarking configurations:\n"
  printf "LIST_OF_CASES: ${LIST_OF_CASES[*]}\n"
  printf "LIST_OF_INPUT_FILES: ${LIST_OF_INPUT_FILES[*]}\n"
  printf "LIST_OF_COMPILERS: ${LIST_OF_COMPILERS[*]}\n"
  printf "LIST_OF_GCC_COMPILERS: ${LIST_OF_GCC_COMPILERS[*]}\n"
  printf "LIST_OF_INTEL_COMPILERS: ${LIST_OF_INTEL_COMPILERS[*]}\n"
  printf "LIST_OF_DATES: ${LIST_OF_DATES[*]}\n"
  printf "============================================================\n"
 
  printf "\n"
  printf "============================================================\n"
  printf "Starting benchmarking loops...\n"
  printf "============================================================\n"

  # Benchmark Pele for the list of dates
  for DATE in "${LIST_OF_DATES[@]}"; do
    # Benchmark Pele for the list of compilers
    for COMPILER_NAME in "${LIST_OF_COMPILERS[@]}"; do
      # Move specific compiler version to generic compiler version
      if [ "${COMPILER_NAME}" == 'gcc' ]; then
        declare -a COMPILER_VERSIONS=("${LIST_OF_GCC_COMPILERS[@]}")
      elif [ "${COMPILER_NAME}" == 'intel' ]; then
        declare -a COMPILER_VERSIONS=("${LIST_OF_INTEL_COMPILERS[@]}")
      fi
      # Benchmark Pele for the list of compiler versions
      for COMPILER_VERSION in "${COMPILER_VERSIONS[@]}"; do
        # Benchmark Pele for the list of cases
        for CASE in "${LIST_OF_CASES[@]}"; do
          # Benchmark Pele for the list of input files
          for INPUT_FILE in "${LIST_OF_INPUT_FILES[@]}"; do
            # Document latest hashes
            set +e; rm ${ROOT_DIR}/runs/benchmark-hashes.txt; set -e
            {
            printf "PeleC Hash: $(cd ${PELEC_DIR} && git log --pretty=format:'%H' -n 1 && git log -2 --pretty=tformat:%aD:%H $(git log --pretty=format:'%H' -n 1))\n"
            printf "PelePhysics Hash: $(cd ${PELE_PHYSICS_DIR} && git log --pretty=format:'%H' -n 1 && git log -2 --pretty=tformat:%aD:%H $(git log --pretty=format:'%H' -n 1))\n"
            printf "AMReX Hash: $(cd ${AMREX_DIR} && git log --pretty=format:'%H' -n 1 && git log -2 --pretty=tformat:%aD:%H $(git log --pretty=format:'%H' -n 1))\n"
            } > ${ROOT_DIR}/runs/repo-hashes.txt
 
            git checkout $(git rev-list -n 1 --before="${DATE}" development)
            PELE_BENCHMARK_CASE="pele-benchmark-${COMPILER_NAME}-${COMPILER_VERSION}-${CASE}-${INPUT_FILE}"
            printf "\nMaking run output directory for ${PELE_BENCHMARK_CASE}...\n"
            cmd "mkdir -p ${ROOT_DIR}/runs/${PELE_BENCHMARK_CASE}"
            (benchmark_loop_body) 2>&1 | tee -i ${ROOT_DIR}/runs/${PELE_BENCHMARK_CASE}/pele-benchmark-log.txt
          done
        done
      done
    done
  done

  printf "============================================================\n"
  printf "Done with benchmarking loops.\n"
  printf "============================================================\n"
  printf "============================================================\n"
  printf "Final Steps.\n"
  printf "============================================================\n"
 
  #Any final steps

  printf "============================================================\n"
  printf "Done!\n"
  printf "$(date)\n"
  printf "============================================================\n"
}

main "$@"
