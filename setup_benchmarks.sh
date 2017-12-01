#!/bin/bash -l

# Script for setting up benchmark suite for Pele on a set of machines

set -e

# Control over printing and executing commands
print_cmds=true
execute_cmds=true

# Function for printing and executing commands
cmd() {
  if ${print_cmds}; then echo "+ $@"; fi
  if ${execute_cmds}; then eval "$@"; fi
}

print_loop_body_header() {
  printf "************************************************************\n"
  printf "Building Pele with:\n"
  printf "${COMPILER_NAME}@${COMPILER_VERSION}\n"
  printf "REPO_DATE: ${REPO_DATE}\n"
  printf "at $(date).\n"
  printf "************************************************************\n"
  printf "\n"
}

print_loop_body_footer() {
  printf "************************************************************\n"
  printf "Done setting up Pele benchmark case with:\n"
  printf "${COMPILER_NAME}@${COMPILER_VERSION}\n"
  printf "REPO_DATE: ${REPO_DATE}\n"
  printf "at $(date).\n"
  printf "************************************************************\n"
}

# Function for setting up a single configuration
benchmark_setup_loop_body() {
  print_loop_body_header

  cmd "cd ${CURRENT_BENCHMARK_DIR}"

  printf "\nCleaning AMReX repo...\n"
  cmd "cd ${AMREX_HOME} && git checkout development"
  cmd "cd ${AMREX_HOME} && pwd && git fetch --all && git reset --hard origin/development && git clean -df && git status -uno"
  printf "\nFinding AMReX commit for date ${REPO_DATE}...\n"
  cmd "AMREX_HASH=$(cd ${AMREX_HOME} && git rev-list -n 1 --before=${REPO_DATE} development)"
  cmd "AMREX_HASH_DATE=\"$(cd ${AMREX_HOME} && git log -1 --format=%cd --date=local ${AMREX_HASH})\""
  printf "AMREX_HASH: ${AMREX_HASH}\n"
  printf "AMREX_HASH_DATE: ${AMREX_HASH_DATE}\n"
  printf "\n"
  cmd "cd ${AMREX_HOME} && git checkout ${AMREX_HASH}"

  printf "\nCleaning PeleC repo...\n"
  cmd "cd ${PELEC_HOME} && git checkout development"
  cmd "cd ${PELEC_HOME} && pwd && git fetch --all && git reset --hard origin/development && git clean -df && git status -uno"
  printf "\nFinding PeleC commit for date ${REPO_DATE}...\n"
  cmd "PELEC_HASH=$(cd ${PELEC_HOME} && git rev-list -n 1 --before=${REPO_DATE} development)"
  cmd "PELEC_HASH_DATE=\"$(cd ${PELEC_HOME} && git log -1 --format=%cd --date=local ${PELEC_HASH})\""
  printf "PELEC_HASH: ${PELEC_HASH}\n"
  printf "PELEC_HASH_DATE: ${PELEC_HASH_DATE}\n"
  printf "\n"
  cmd "cd ${PELEC_HOME} && git checkout ${PELEC_HASH}"

  printf "\nCleaning PelePhysics repo...\n"
  cmd "cd ${PELE_PHYSICS_HOME} && git checkout development"
  cmd "cd ${PELE_PHYSICS_HOME} && pwd && git fetch --all && git reset --hard origin/development && git clean -df && git status -uno"
  printf "\nFinding PelePhysics commit for date ${REPO_DATE}...\n"
  cmd "PELE_PHYSICS_HASH=$(cd ${PELE_PHYSICS_HOME} && git rev-list -n 1 --before=${REPO_DATE} development)"
  cmd "PELE_PHYSICS_DATE=\"$(cd ${PELE_PHYSICS_HOME} && git log -1 --format=%cd --date=local ${PELE_PHYSICS_HASH})\""
  printf "PELE_PHYSICS_HASH: ${PELE_PHYSICS_HASH}\n"
  printf "PELE_PHYSICS_HASH_DATE: ${PELE_PHYSICS_HASH_DATE}\n"
  printf "\n"
  cmd "cd ${PELE_PHYSICS_HOME} && git checkout ${PELE_PHYSICS_HASH}"

  printf "\nLoading modules...\n"
  if [ "${MACHINE_NAME}" == 'peregrine' ]; then
    if [ "${COMPILER_NAME}" == 'gcc' ]; then
      cmd "module purge"
      cmd "module use /nopt/nrel/apps/modules/candidate/modulefiles"
      cmd "module load gcc/5.2.0"
      cmd "module load python/2.7.8 &> /dev/null"
      cmd "module unload mkl"
      cmd "module load git/2.6.3"
      cmd "module list"
    fi
  fi

  printf "\nBuilding benchmark binary at $(date)...\n"
  #cmd "cd ${PELEC_HOME}/Exec/Benchmarks/Benchmark && make -j8"
  #cmd "mv ${PELEC_HOME}/Exec/Benchmarks/Benchmark/Pele* ${CURRENT_BENCHMARK_DIR}/"
  printf "Done building benchmark binary at $(date)...\n"

  printf "\n"
  print_loop_body_footer
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
    declare -a LIST_OF_COMPILERS=('gcc' 'intel')
    declare -a LIST_OF_GCC_COMPILERS=('5.2.0')
    declare -a LIST_OF_INTEL_COMPILERS=('17.0.2')
    declare -a LIST_OF_REPO_DATES=('2017-03-01' '2017-07-01')
    ROOT_DIR=${HOME}/pelec_benchmark_suite
    RUN_DIR=${ROOT_DIR}/run
  elif [ "${MACHINE_NAME}" == 'edison' ]; then
    declare -a LIST_OF_COMPILERS=('gcc' 'intel')
    declare -a LIST_OF_GCC_COMPILERS=('6.3.0')
    declare -a LIST_OF_INTEL_COMPILERS=('17.0.2')
    declare -a LIST_OF_REPO_DATES=('2017-03-01' '2017-07-01')
    ROOT_DIR=${HOME}/pelec_benchmark_suite
    RUN_DIR=${ROOT_DIR}/run
  elif [ "${MACHINE_NAME}" == 'cori' ]; then
    declare -a LIST_OF_COMPILERS=('gcc' 'intel')
    declare -a LIST_OF_GCC_COMPILERS=('6.3.0')
    declare -a LIST_OF_INTEL_COMPILERS=('17.0.2')
    declare -a LIST_OF_REPO_DATES=('2017-03-01' '2017-07-01')
    ROOT_DIR=${HOME}/pelec_benchmark_suite
    RUN_DIR=${ROOT_DIR}/run
  else
    printf "\nMachine name not recognized.\n"
    exit 1
  fi

  # Set the three repo directories
  export PELEC_HOME=${ROOT_DIR}/PeleC
  export PELE_PHYSICS_HOME=${ROOT_DIR}/PelePhysics
  export AMREX_HOME=${ROOT_DIR}/AMReX

  printf "============================================================\n"
  printf "HOST_NAME: $(hostname)\n"
  printf "MACHINE_NAME: ${MACHINE_NAME}\n"
  printf "ROOT_DIR: ${ROOT_DIR}\n"
  printf "RUN_DIR: ${RUN_DIR}\n"
  printf "PELEC_HOME: ${PELEC_HOME}\n"
  printf "PELE_PHYSICS_HOME: ${PELE_PHYSICS_HOME}\n"
  printf "AMREX_HOME: ${AMREX_HOME}\n"
  printf "============================================================\n"

  if [ ! -d "${ROOT_DIR}" ]; then
    printf "============================================================\n"
    printf "Top level benchmark directory doesn't exist.\n"
    printf "Creating everything from scratch...\n"
    printf "============================================================\n"

    printf "Creating top level benchmarking directory...\n"
    cmd "mkdir -p ${ROOT_DIR}"

    printf "\nCloning AMReX repo...\n"
    cmd "git clone https://github.com/amrex-codes/amrex.git ${AMREX_HOME}"

    printf "\nCloning PeleC repo...\n"
    cmd "git clone git@code.ornl.gov:Pele/PeleC.git ${PELEC_HOME}"

    printf "\nCloning PelePhysics repo...\n"
    cmd "git clone git@code.ornl.gov:Pele/PelePhysics.git ${PELE_PHYSICS_HOME}"

    printf "\nMaking run output directory...\n"
    cmd "mkdir -p ${RUN_DIR}"

    printf "============================================================\n"
    printf "Done setting up root benchmarking directory.\n"
    printf "============================================================\n"
  fi

  printf "============================================================\n"
  printf "Benchmarking build configurations:\n"
  printf "LIST_OF_COMPILERS: ${LIST_OF_COMPILERS[*]}\n"
  printf "LIST_OF_GCC_COMPILERS: ${LIST_OF_GCC_COMPILERS[*]}\n"
  printf "LIST_OF_INTEL_COMPILERS: ${LIST_OF_INTEL_COMPILERS[*]}\n"
  printf "LIST_OF_REPO_DATES: ${LIST_OF_REPO_DATES[*]}\n"
  printf "============================================================\n"
 
  printf "\n"
  printf "============================================================\n"
  printf "Starting benchmarking setup loops...\n"
  printf "============================================================\n"

  # Setup Pele benchmark for the list of dates
  for REPO_DATE in "${LIST_OF_REPO_DATES[@]}"; do
    # Setup Pele benchmark for the list of compilers
    for COMPILER_NAME in "${LIST_OF_COMPILERS[@]}"; do
      # Move specific compiler version to generic compiler version
      if [ "${COMPILER_NAME}" == 'gcc' ]; then
        declare -a COMPILER_VERSIONS=("${LIST_OF_GCC_COMPILERS[@]}")
      elif [ "${COMPILER_NAME}" == 'intel' ]; then
        declare -a COMPILER_VERSIONS=("${LIST_OF_INTEL_COMPILERS[@]}")
      fi
      # Setup benchmark for the list of compiler versions
      for COMPILER_VERSION in "${COMPILER_VERSIONS[@]}"; do
        CURRENT_BENCHMARK_DIR=${RUN_DIR}/${REPO_DATE}/${COMPILER_NAME}/${COMPILER_VERSION}
        printf "\nMaking specific benchmark directory...\n"
        cmd "mkdir -p ${CURRENT_BENCHMARK_DIR}"
        if [ ! -z "${CURRENT_BENCHMARK_DIR}" ]; then
          printf "\nCleaning benchmark directory...\n"
          cmd "cd ${CURRENT_BENCHMARK_DIR} && rm -rf ${CURRENT_BENCHMARK_DIR}/*"
        fi
        (benchmark_setup_loop_body) > ${CURRENT_BENCHMARK_DIR}/pele-benchmark-setup-log.txt 2>&1
      done
    done
  done

  printf "============================================================\n"
  printf "Done with benchmarking setup loops.\n"
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
