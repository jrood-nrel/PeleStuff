#!/bin/bash

OWD=$(pwd)

# Basic job settings
EMAIL="jon.rood@nrel.gov"
COMPILER=intel
TEST_RUN="FALSE"

# Create list of jobs with varying parameters to submit
EXAMPLE_JOB='job_name:queue:cpu_type:exe_path:input_file:nodes:ranks_per_node:hypercores_per_thread:minutes'
declare -a JOBS
declare -a INPUT_FILE_ARGS
JOBS[1]="pelec-scaling:short:haswell:${OWD}/PeleC3d.${COMPILER}.MPI.ex:${OWD}/input-3d:1:12:2:40"
INPUT_FILE_ARGS[1]='amr.n_cell=128 128 128'
#JOBS[2]="pelec-scaling:short:haswell:${OWD}/PeleC3d.${COMPILER}.MPI.ex:${OWD}/input-3d:4:24:2:40"
#INPUT_FILE_ARGS[2]='amr.n_cell=256 256 256'
#JOBS[3]="pelec-scaling:batch-h:haswell:${OWD}/PeleC3d.${COMPILER}.MPI.ex:${OWD}/input-3d:32:24:2:40"
#INPUT_FILE_ARGS[3]='amr.n_cell=512 512 512'
#JOBS[4]="pelec-scaling:batch-h:haswell:${OWD}/PeleC3d.${COMPILER}.MPI.ex:${OWD}/input-3d:256:24:2:400"
#INPUT_FILE_ARGS[4]='amr.n_cell=1024 1024 1024'
