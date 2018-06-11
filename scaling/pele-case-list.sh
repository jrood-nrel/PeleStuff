#!/bin/bash

OWD=$(pwd)

# Basic job settings
EMAIL="jon.rood@nrel.gov"
COMPILER=intel
TEST_RUN="FALSE" # Only works for Slurm

# Create list of jobs with varying parameters to submit
EXAMPLE_JOB='job_name:queue:cpu_type:exe_path:input_file:nodes:ranks_per_node:hypercores_per_thread:minutes'
declare -a JOBS
declare -a PRE_ARGS
declare -a POST_ARGS
IDX=0

#Cori Haswell MPI/OMP Balance
#JOBS[((IDX++))]="pelec-scaling:debug:haswell:${OWD}/PeleC3d.${COMPILER}.haswell.MPI.OMP.ex:${OWD}/input-3d:8:32:2:30"; PRE_ARGS[$IDX]=""; POST_ARGS[$IDX]="amr.probin_file=${OWD}/probin-3d amr.n_cell=256 256 256"
#JOBS[((IDX++))]="pelec-scaling:debug:haswell:${OWD}/PeleC3d.${COMPILER}.haswell.MPI.OMP.ex:${OWD}/input-3d:8:16:2:30"; PRE_ARGS[$IDX]=""; POST_ARGS[$IDX]="amr.probin_file=${OWD}/probin-3d amr.n_cell=256 256 256"
#JOBS[((IDX++))]="pelec-scaling:debug:haswell:${OWD}/PeleC3d.${COMPILER}.haswell.MPI.OMP.ex:${OWD}/input-3d:8:8:2:30"; PRE_ARGS[$IDX]=""; POST_ARGS[$IDX]="amr.probin_file=${OWD}/probin-3d amr.n_cell=256 256 256"
#JOBS[((IDX++))]="pelec-scaling:debug:haswell:${OWD}/PeleC3d.${COMPILER}.haswell.MPI.OMP.ex:${OWD}/input-3d:8:4:2:30"; PRE_ARGS[$IDX]=""; POST_ARGS[$IDX]="amr.probin_file=${OWD}/probin-3d amr.n_cell=256 256 256"
#JOBS[((IDX++))]="pelec-scaling:debug:haswell:${OWD}/PeleC3d.${COMPILER}.haswell.MPI.OMP.ex:${OWD}/input-3d:8:2:2:30"; PRE_ARGS[$IDX]=""; POST_ARGS[$IDX]="amr.probin_file=${OWD}/probin-3d amr.n_cell=256 256 256"

#Cori KNL MPI/OMP Balance
#JOBS[((IDX++))]="pelec-scaling:debug:knl:${OWD}/PeleC3d.${COMPILER}.mic-knl.MPI.OMP.ex:${OWD}/input-3d:8:128:2:30"; PRE_ARGS[$IDX]=""; POST_ARGS[$IDX]="amr.probin_file=${OWD}/probin-3d amr.n_cell=256 256 256"
#JOBS[((IDX++))]="pelec-scaling:debug:knl:${OWD}/PeleC3d.${COMPILER}.mic-knl.MPI.OMP.ex:${OWD}/input-3d:8:64:2:30"; PRE_ARGS[$IDX]=""; POST_ARGS[$IDX]="amr.probin_file=${OWD}/probin-3d amr.n_cell=256 256 256"
#JOBS[((IDX++))]="pelec-scaling:debug:knl:${OWD}/PeleC3d.${COMPILER}.mic-knl.MPI.OMP.ex:${OWD}/input-3d:8:32:2:30"; PRE_ARGS[$IDX]=""; POST_ARGS[$IDX]="amr.probin_file=${OWD}/probin-3d amr.n_cell=256 256 256"
#JOBS[((IDX++))]="pelec-scaling:debug:knl:${OWD}/PeleC3d.${COMPILER}.mic-knl.MPI.OMP.ex:${OWD}/input-3d:8:16:2:30"; PRE_ARGS[$IDX]=""; POST_ARGS[$IDX]="amr.probin_file=${OWD}/probin-3d amr.n_cell=256 256 256"
#JOBS[((IDX++))]="pelec-scaling:debug:knl:${OWD}/PeleC3d.${COMPILER}.mic-knl.MPI.OMP.ex:${OWD}/input-3d:8:8:2:30"; PRE_ARGS[$IDX]=""; POST_ARGS[$IDX]="amr.probin_file=${OWD}/probin-3d amr.n_cell=256 256 256"

#Cori KNL
JOBS[((IDX++))]="pelec-scaling:debug:knl:${OWD}/PeleC3d.${COMPILER}.mic-knl.MPI.OMP.ex:${OWD}/input-3d:1:16:2:30"; PRE_ARGS[$IDX]="export OMP_NUM_THREADS=4;"; POST_ARGS[$IDX]="amr.probin_file=${OWD}/probin-3d amr.n_cell=128 128 128"
JOBS[$((IDX++))]="pelec-scaling:debug:knl:${OWD}/PeleC3d.${COMPILER}.mic-knl.MPI.OMP.ex:${OWD}/input-3d:4:32:2:30"; PRE_ARGS[$IDX]=""; POST_ARGS[$IDX]="amr.probin_file=${OWD}/probin-3d amr.n_cell=256 256 256"
JOBS[((IDX++))]="pelec-scaling:debug:knl:${OWD}/PeleC3d.${COMPILER}.mic-knl.MPI.OMP.ex:${OWD}/input-3d:32:32:2:30"; PRE_ARGS[$IDX]=""; POST_ARGS[$IDX]="amr.probin_file=${OWD}/probin-3d amr.n_cell=512 512 512"
JOBS[((IDX++))]="pelec-scaling:debug:knl:${OWD}/PeleC3d.${COMPILER}.mic-knl.MPI.OMP.ex:${OWD}/input-3d:256:32:2:30": PRE_ARGS[$IDX]=""; POST_ARGS[$IDX]="amr.probin_file=${OWD}/probin-3d amr.n_cell=1024 1024 1024"
JOBS[((IDX++))]="pelec-scaling:regular:knl:${OWD}/PeleC3d.${COMPILER}.mic-knl.MPI.OMP.ex:${OWD}/input-3d:2048:32:2:40"; PRE_ARGS[$IDX]=""; POST_ARGS[$IDX]="amr.probin_file=${OWD}/probin-3d amr.n_cell=2048 2048 2048"

#Cori Haswell
#JOBS[((IDX++))]="pelec-scaling:debug:haswell:${OWD}/PeleC3d.${COMPILER}.haswell.MPI.ex:${OWD}/input-3d:1:16:2:30"; PRE_ARGS[$IDX]=""; POST_ARGS[$IDX]="amr.probin_file=${OWD}/probin-3d amr.n_cell=128 128 128"
#JOBS[((IDX++))]="pelec-scaling:debug:haswell:${OWD}/PeleC3d.${COMPILER}.haswell.MPI.ex:${OWD}/input-3d:4:32:2:30"; PRE_ARGS[$IDX]=""; POST_ARGS[$IDX]="amr.probin_file=${OWD}/probin-3d amr.n_cell=256 256 256"
#JOBS[((IDX++))]="pelec-scaling:debug:haswell:${OWD}/PeleC3d.${COMPILER}.haswell.MPI.ex:${OWD}/input-3d:32:32:2:30"; PRE_ARGS[$IDX]=""; POST_ARGS[$IDX]="amr.probin_file=${OWD}/probin-3d amr.n_cell=512 512 512"
#JOBS[((IDX++))]="pelec-scaling:regular:haswell:${OWD}/PeleC3d.${COMPILER}.haswell.MPI.ex:${OWD}/input-3d:256:32:2:30"; PRE_ARGS[$IDX]=""; POST_ARGS[$IDX]="amr.probin_file=${OWD}/probin-3d amr.n_cell=1024 1024 1024"

#Peregrine Haswell
#JOBS[((IDX++))]="pelec-scaling:short:haswell:${OWD}/PeleC3d.${COMPILER}.MPI.ex:${OWD}/input-3d:1:12:2:40"; PRE_ARGS[$IDX]=""; POST_ARGS[$IDX]="amr.probin_file=${OWD}/probin-3d amr.n_cell=128 128 128"
#JOBS[((IDX++))]="pelec-scaling:short:haswell:${OWD}/PeleC3d.${COMPILER}.MPI.ex:${OWD}/input-3d:4:24:2:40"; PRE_ARGS[$IDX]=""; POST_ARGS[$IDX]="amr.probin_file=${OWD}/probin-3d amr.n_cell=256 256 256"
#JOBS[((IDX++))]="pelec-scaling:batch-h:haswell:${OWD}/PeleC3d.${COMPILER}.MPI.ex:${OWD}/input-3d:32:24:2:40"; PRE_ARGS[$IDX]=""; POST_ARGS[$IDX]="amr.probin_file=${OWD}/probin-3d amr.n_cell=512 512 512"
#JOBS[((IDX++))]="pelec-scaling:batch-h:haswell:${OWD}/PeleC3d.${COMPILER}.MPI.ex:${OWD}/input-3d:256:24:2:40"; PRE_ARGS[$IDX]=""; POST_ARGS[$IDX]="amr.probin_file=${OWD}/probin-3d amr.n_cell=1024 1024 1024"
