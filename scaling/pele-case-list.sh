#!/bin/bash

OWD=$(pwd)

# Basic job settings
EMAIL="jon.rood@nrel.gov"
COMPILER=intel
TEST_RUN="FALSE" # Only works for Slurm

# Create list of jobs with varying parameters to submit
EXAMPLE_JOB='job_name:queue:cpu_type:exe_path:input_file:nodes:ranks_per_node:hypercores_per_thread:minutes'
declare -a JOBS
declare -a INPUT_FILE_ARGS

#Cori Haswell MPI/OMP Balance
#JOBS[1]="pelec-scaling:debug:haswell:${OWD}/PeleC3d.${COMPILER}.haswell.MPI.OMP.ex:${OWD}/input-3d:8:32:2:30"
#INPUT_FILE_ARGS[1]="amr.probin_file=${OWD}/probin-3d amr.n_cell=256 256 256"
#JOBS[2]="pelec-scaling:debug:haswell:${OWD}/PeleC3d.${COMPILER}.haswell.MPI.OMP.ex:${OWD}/input-3d:8:16:2:30"
#INPUT_FILE_ARGS[2]="amr.probin_file=${OWD}/probin-3d amr.n_cell=256 256 256"
#JOBS[3]="pelec-scaling:debug:haswell:${OWD}/PeleC3d.${COMPILER}.haswell.MPI.OMP.ex:${OWD}/input-3d:8:8:2:30"
#INPUT_FILE_ARGS[3]="amr.probin_file=${OWD}/probin-3d amr.n_cell=256 256 256"
#JOBS[4]="pelec-scaling:debug:haswell:${OWD}/PeleC3d.${COMPILER}.haswell.MPI.OMP.ex:${OWD}/input-3d:8:4:2:30"
#INPUT_FILE_ARGS[4]="amr.probin_file=${OWD}/probin-3d amr.n_cell=256 256 256"
#JOBS[5]="pelec-scaling:debug:haswell:${OWD}/PeleC3d.${COMPILER}.haswell.MPI.OMP.ex:${OWD}/input-3d:8:2:2:30"
#INPUT_FILE_ARGS[5]="amr.probin_file=${OWD}/probin-3d amr.n_cell=256 256 256"

#Cori KNL MPI/OMP Balance
JOBS[1]="pelec-scaling:debug:knl:${OWD}/PeleC3d.${COMPILER}.mic-knl.MPI.OMP.ex:${OWD}/input-3d:8:128:2:30"
INPUT_FILE_ARGS[1]="amr.probin_file=${OWD}/probin-3d amr.n_cell=256 256 256"
JOBS[2]="pelec-scaling:debug:knl:${OWD}/PeleC3d.${COMPILER}.mic-knl.MPI.OMP.ex:${OWD}/input-3d:8:64:2:30"
INPUT_FILE_ARGS[2]="amr.probin_file=${OWD}/probin-3d amr.n_cell=256 256 256"
JOBS[3]="pelec-scaling:debug:knl:${OWD}/PeleC3d.${COMPILER}.mic-knl.MPI.OMP.ex:${OWD}/input-3d:8:32:2:30"
INPUT_FILE_ARGS[3]="amr.probin_file=${OWD}/probin-3d amr.n_cell=256 256 256"
JOBS[4]="pelec-scaling:debug:knl:${OWD}/PeleC3d.${COMPILER}.mic-knl.MPI.OMP.ex:${OWD}/input-3d:8:16:2:30"
INPUT_FILE_ARGS[4]="amr.probin_file=${OWD}/probin-3d amr.n_cell=256 256 256"
JOBS[5]="pelec-scaling:debug:knl:${OWD}/PeleC3d.${COMPILER}.mic-knl.MPI.OMP.ex:${OWD}/input-3d:8:8:2:30"
INPUT_FILE_ARGS[5]="amr.probin_file=${OWD}/probin-3d amr.n_cell=256 256 256"

#Cori KNL
#JOBS[1]="pelec-scaling:debug:knl:${OWD}/PeleC3d.${COMPILER}.mic-knl.MPI.OMP.ex:${OWD}/input-3d:1:16:2:30"
#INPUT_FILE_ARGS[1]="amr.probin_file=${OWD}/probin-3d amr.n_cell=128 128 128"
#JOBS[2]="pelec-scaling:debug:knl:${OWD}/PeleC3d.${COMPILER}.mic-knl.MPI.OMP.ex:${OWD}/input-3d:4:32:2:30"
#INPUT_FILE_ARGS[2]="amr.probin_file=${OWD}/probin-3d amr.n_cell=256 256 256"
#JOBS[3]="pelec-scaling:debug:knl:${OWD}/PeleC3d.${COMPILER}.mic-knl.MPI.OMP.ex:${OWD}/input-3d:32:32:2:30"
#INPUT_FILE_ARGS[3]="amr.probin_file=${OWD}/probin-3d amr.n_cell=512 512 512"
#JOBS[4]="pelec-scaling:debug:knl:${OWD}/PeleC3d.${COMPILER}.mic-knl.MPI.OMP.ex:${OWD}/input-3d:256:32:2:30"
#INPUT_FILE_ARGS[4]="amr.probin_file=${OWD}/probin-3d amr.n_cell=1024 1024 1024"
#JOBS[5]="pelec-scaling:regular:knl:${OWD}/PeleC3d.${COMPILER}.mic-knl.MPI.OMP.ex:${OWD}/input-3d:2048:32:2:40"
#INPUT_FILE_ARGS[5]="amr.probin_file=${OWD}/probin-3d amr.n_cell=2048 2048 2048"

#Cori Haswell
#JOBS[1]="pelec-scaling:debug:haswell:${OWD}/PeleC3d.${COMPILER}.haswell.MPI.ex:${OWD}/input-3d:1:16:2:30"
#INPUT_FILE_ARGS[1]="amr.probin_file=${OWD}/probin-3d amr.n_cell=128 128 128"
#JOBS[2]="pelec-scaling:debug:haswell:${OWD}/PeleC3d.${COMPILER}.haswell.MPI.ex:${OWD}/input-3d:4:32:2:30"
#INPUT_FILE_ARGS[2]="amr.probin_file=${OWD}/probin-3d amr.n_cell=256 256 256"
#JOBS[3]="pelec-scaling:debug:haswell:${OWD}/PeleC3d.${COMPILER}.haswell.MPI.ex:${OWD}/input-3d:32:32:2:30"
#INPUT_FILE_ARGS[3]="amr.probin_file=${OWD}/probin-3d amr.n_cell=512 512 512"
#JOBS[4]="pelec-scaling:regular:haswell:${OWD}/PeleC3d.${COMPILER}.haswell.MPI.ex:${OWD}/input-3d:256:32:2:30"
#INPUT_FILE_ARGS[4]="amr.probin_file=${OWD}/probin-3d amr.n_cell=1024 1024 1024"

#Peregrine Haswell
#JOBS[1]="pelec-scaling:short:haswell:${OWD}/PeleC3d.${COMPILER}.MPI.ex:${OWD}/input-3d:1:12:2:40"
#INPUT_FILE_ARGS[1]="amr.probin_file=${OWD}/probin-3d amr.n_cell=128 128 128"
#JOBS[2]="pelec-scaling:short:haswell:${OWD}/PeleC3d.${COMPILER}.MPI.ex:${OWD}/input-3d:4:24:2:40"
#INPUT_FILE_ARGS[2]="amr.probin_file=${OWD}/probin-3d amr.n_cell=256 256 256"
#JOBS[3]="pelec-scaling:batch-h:haswell:${OWD}/PeleC3d.${COMPILER}.MPI.ex:${OWD}/input-3d:32:24:2:40"
#INPUT_FILE_ARGS[3]="amr.probin_file=${OWD}/probin-3d amr.n_cell=512 512 512"
#JOBS[4]="pelec-scaling:batch-h:haswell:${OWD}/PeleC3d.${COMPILER}.MPI.ex:${OWD}/input-3d:256:24:2:40"
#INPUT_FILE_ARGS[4]="amr.probin_file=${OWD}/probin-3d amr.n_cell=1024 1024 1024"
