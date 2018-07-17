#!/bin/bash

OWD=$(pwd)

# Basic job settings
EMAIL="jon.rood@nrel.gov"
COMPILER=intel
TEST_RUN="FALSE" # Only works for Slurm

# Create list of jobs with varying parameters to submit
EXAMPLE_JOB='job_name:queue:cpu_type:exe_path:input_file:nodes:ranks_per_node:minutes'
declare -a JOBS
declare -a PRE_ARGS
declare -a POST_ARGS
IDX=0

#Example Peregrine Haswell MPI+OMP Optimal 8 Node Job (4 MPI Ranks/6 Threads Per Node)
#JOBS[((IDX++))]="pelec-scaling:batch-h:haswell:${OWD}/PeleC3d.${COMPILER}.MPI.OMP.ex:${OWD}/input-3d:2:6:30"; PRE_ARGS[$IDX]=""; POST_ARGS[$IDX]="amr.probin_file=${OWD}/probin-3d amr.n_cell=256 256 256"

#Example Cori Haswell MPI+OMP Optimal 8 Node Job (8 MPI Ranks/4 Threads Per Node)
#JOBS[((IDX++))]="pelec-scaling:debug:haswell:${OWD}/PeleC3d.${COMPILER}.haswell.MPI.OMP.ex:${OWD}/input-3d:8:8:30"; PRE_ARGS[$IDX]=""; POST_ARGS[$IDX]="amr.probin_file=${OWD}/probin-3d amr.n_cell=256 256 256"

#Example Cori KNL MPI+OMP Optimal 8 Node Job (32 MPI Ranks/4 Threads Per Node)
#JOBS[((IDX++))]="pelec-scaling:debug:knl:${OWD}/PeleC3d.${COMPILER}.mic-knl.MPI.OMP.ex:${OWD}/input-3d:8:32:30"; PRE_ARGS[$IDX]=""; POST_ARGS[$IDX]="amr.probin_file=${OWD}/probin-3d amr.n_cell=256 256 256"

#Example Cori Haswell MPI/OMP Sweep
#JOBS[((IDX++))]="pelec-scaling:debug:haswell:${OWD}/PeleC3d.${COMPILER}.haswell.MPI.OMP.ex:${OWD}/input-3d:8:32:30"; PRE_ARGS[$IDX]=""; POST_ARGS[$IDX]="amr.probin_file=${OWD}/probin-3d amr.n_cell=256 256 256"
#JOBS[((IDX++))]="pelec-scaling:debug:haswell:${OWD}/PeleC3d.${COMPILER}.haswell.MPI.OMP.ex:${OWD}/input-3d:8:16:30"; PRE_ARGS[$IDX]=""; POST_ARGS[$IDX]="amr.probin_file=${OWD}/probin-3d amr.n_cell=256 256 256"
#JOBS[((IDX++))]="pelec-scaling:debug:haswell:${OWD}/PeleC3d.${COMPILER}.haswell.MPI.OMP.ex:${OWD}/input-3d:8:8:30"; PRE_ARGS[$IDX]=""; POST_ARGS[$IDX]="amr.probin_file=${OWD}/probin-3d amr.n_cell=256 256 256"
#JOBS[((IDX++))]="pelec-scaling:debug:haswell:${OWD}/PeleC3d.${COMPILER}.haswell.MPI.OMP.ex:${OWD}/input-3d:8:4:30"; PRE_ARGS[$IDX]=""; POST_ARGS[$IDX]="amr.probin_file=${OWD}/probin-3d amr.n_cell=256 256 256"
#JOBS[((IDX++))]="pelec-scaling:debug:haswell:${OWD}/PeleC3d.${COMPILER}.haswell.MPI.OMP.ex:${OWD}/input-3d:8:2:30"; PRE_ARGS[$IDX]=""; POST_ARGS[$IDX]="amr.probin_file=${OWD}/probin-3d amr.n_cell=256 256 256"

#Example Cori KNL MPI/OMP Sweep
#JOBS[((IDX++))]="pelec-scaling:debug:knl:${OWD}/PeleC3d.${COMPILER}.mic-knl.MPI.OMP.ex:${OWD}/input-3d:8:128:30"; PRE_ARGS[$IDX]=""; POST_ARGS[$IDX]="amr.probin_file=${OWD}/probin-3d amr.n_cell=256 256 256"
#JOBS[((IDX++))]="pelec-scaling:debug:knl:${OWD}/PeleC3d.${COMPILER}.mic-knl.MPI.OMP.ex:${OWD}/input-3d:8:64:30"; PRE_ARGS[$IDX]=""; POST_ARGS[$IDX]="amr.probin_file=${OWD}/probin-3d amr.n_cell=256 256 256"
#JOBS[((IDX++))]="pelec-scaling:debug:knl:${OWD}/PeleC3d.${COMPILER}.mic-knl.MPI.OMP.ex:${OWD}/input-3d:8:32:30"; PRE_ARGS[$IDX]=""; POST_ARGS[$IDX]="amr.probin_file=${OWD}/probin-3d amr.n_cell=256 256 256"
#JOBS[((IDX++))]="pelec-scaling:debug:knl:${OWD}/PeleC3d.${COMPILER}.mic-knl.MPI.OMP.ex:${OWD}/input-3d:8:16:30"; PRE_ARGS[$IDX]=""; POST_ARGS[$IDX]="amr.probin_file=${OWD}/probin-3d amr.n_cell=256 256 256"
#JOBS[((IDX++))]="pelec-scaling:debug:knl:${OWD}/PeleC3d.${COMPILER}.mic-knl.MPI.OMP.ex:${OWD}/input-3d:8:8:30"; PRE_ARGS[$IDX]=""; POST_ARGS[$IDX]="amr.probin_file=${OWD}/probin-3d amr.n_cell=256 256 256"

#Example Cori KNL Weak Scaling Study
#JOBS[((IDX++))]="pelec-scaling:debug:knl:${OWD}/PeleC3d.${COMPILER}.mic-knl.MPI.OMP.ex:${OWD}/input-3d:1:32:30"; PRE_ARGS[$IDX]=""; POST_ARGS[$IDX]="amr.probin_file=${OWD}/probin-3d amr.n_cell=160 160 160 geometry.prob_lo=-0.625 -0.625 -0.625 geometry.prob_hi=2.5 2.5 2.5"
#JOBS[((IDX++))]="pelec-scaling:debug:knl:${OWD}/PeleC3d.${COMPILER}.mic-knl.MPI.OMP.ex:${OWD}/input-3d:4:32:30"; PRE_ARGS[$IDX]=""; POST_ARGS[$IDX]="amr.probin_file=${OWD}/probin-3d amr.n_cell=256 256 256 geometry.prob_lo=-1.0 -1.0 -1.0 geometry.prob_hi=4.0 4.0 4.0"
#JOBS[((IDX++))]="pelec-scaling:debug:knl:${OWD}/PeleC3d.${COMPILER}.mic-knl.MPI.OMP.ex:${OWD}/input-3d:32:32:30"; PRE_ARGS[$IDX]=""; POST_ARGS[$IDX]="amr.probin_file=${OWD}/probin-3d amr.n_cell=512 512 512 geometry.prob_lo=-2.0 -2.0 -2.0 geometry.prob_hi=8.0 8.0 8.0"
#JOBS[((IDX++))]="pelec-scaling:debug:knl:${OWD}/PeleC3d.${COMPILER}.mic-knl.MPI.OMP.ex:${OWD}/input-3d:256:32:30": PRE_ARGS[$IDX]=""; POST_ARGS[$IDX]="amr.probin_file=${OWD}/probin-3d amr.n_cell=1024 1024 1024 geometry.prob_lo=-4.0 -4.0 -4.0 geometry.prob_hi=16.0 16.0 16.0"
#JOBS[((IDX++))]="pelec-scaling:regular:knl:${OWD}/PeleC3d.${COMPILER}.mic-knl.MPI.OMP.ex:${OWD}/input-3d:2048:32:40"; PRE_ARGS[$IDX]=""; POST_ARGS[$IDX]="amr.probin_file=${OWD}/probin-3d amr.n_cell=2048 2048 2048 geometry.prob_lo=-8.0 -8.0 -8.0 geometry.prob_hi=32.0 32.0 32.0"

# Second Example Cori KNL Weak Scaling Study
#JOBS[((IDX++))]="pelec-scaling:debug:knl:${OWD}/PeleC3d.${COMPILER}.mic-knl.MPI.OMP.ex:${OWD}/input-3d:1:32:30"; PRE_ARGS[$IDX]=""; POST_ARGS[$IDX]="amr.probin_file=${OWD}/probin-3d amr.n_cell=160 160 160 geometry.prob_lo=-0.625 -0.625 -0.625 geometry.prob_hi=2.5 2.5 2.5"
#JOBS[((IDX++))]="pelec-scaling:debug:knl:${OWD}/PeleC3d.${COMPILER}.mic-knl.MPI.OMP.ex:${OWD}/input-3d:8:32:30"; PRE_ARGS[$IDX]=""; POST_ARGS[$IDX]="amr.probin_file=${OWD}/probin-3d amr.n_cell=320 320 320 geometry.prob_lo=-1.25 -1.25 -1.25 geometry.prob_hi=5.0 5.0 5.0"
#JOBS[((IDX++))]="pelec-scaling:regular:knl:${OWD}/PeleC3d.${COMPILER}.mic-knl.MPI.OMP.ex:${OWD}/input-3d:64:32:30"; PRE_ARGS[$IDX]=""; POST_ARGS[$IDX]="amr.probin_file=${OWD}/probin-3d amr.n_cell=640 640 640 geometry.prob_lo=-2.5 -2.5 -2.5 geometry.prob_hi=10.0 10.0 10.0"
#JOBS[((IDX++))]="pelec-scaling:regular:knl:${OWD}/PeleC3d.${COMPILER}.mic-knl.MPI.OMP.ex:${OWD}/input-3d:512:32:40"; PRE_ARGS[$IDX]=""; POST_ARGS[$IDX]="amr.probin_file=${OWD}/probin-3d amr.n_cell=1280 1280 1280 geometry.prob_lo=-5.0 -5.0 -5.0 geometry.prob_hi=20.0 20.0 20.0"
#JOBS[((IDX++))]="pelec-scaling:regular:knl:${OWD}/PeleC3d.${COMPILER}.mic-knl.MPI.OMP.ex:${OWD}/input-3d:4096:32:50"; PRE_ARGS[$IDX]=""; POST_ARGS[$IDX]="amr.probin_file=${OWD}/probin-3d amr.n_cell=2560 2560 2560 geometry.prob_lo=-10.0 -10.0 -10.0 geometry.prob_hi=40.0 40.0 40.0"
#JOBS[((IDX++))]="pelec-scaling:regular:knl:${OWD}/PeleC3d.${COMPILER}.mic-knl.MPI.OMP.ex:${OWD}/input-3d:7078:32:60"; PRE_ARGS[$IDX]=""; POST_ARGS[$IDX]="amr.probin_file=${OWD}/probin-3d amr.n_cell=3072 3072 3072 geometry.prob_lo=-12.0 -12.0 -12.0 geometry.prob_hi=48.0 48.0 48.00"
#JOBS[((IDX++))]="pelec-scaling:regular:knl:${OWD}/PeleC3d.${COMPILER}.mic-knl.MPI.OMP.ex:${OWD}/input-3d:8000:32:60"; PRE_ARGS[$IDX]=""; POST_ARGS[$IDX]="amr.probin_file=${OWD}/probin-3d amr.n_cell=3200 3200 3200 geometry.prob_lo=-12.5 -12.5 -12.5 geometry.prob_hi=50.0 50.0 50.00"
#JOBS[((IDX++))]="pelec-scaling:regular:knl:${OWD}/PeleC3d.${COMPILER}.mic-knl.MPI.OMP.ex:${OWD}/input-3d:8866:32:60"; PRE_ARGS[$IDX]=""; POST_ARGS[$IDX]="amr.probin_file=${OWD}/probin-3d amr.n_cell=3312 3312 3312 geometry.prob_lo=-12.9375 -12.9375 -12.9375 geometry.prob_hi=51.75 51.75 51.75"

#Example Cori Haswell Weak Scaling Study
#JOBS[((IDX++))]="pelec-scaling:debug:haswell:${OWD}/PeleC3d.${COMPILER}.haswell.MPI.ex:${OWD}/input-3d:1:32:30"; PRE_ARGS[$IDX]=""; POST_ARGS[$IDX]="amr.probin_file=${OWD}/probin-3d amr.n_cell=160 160 160 geometry.prob_lo=-0.625 -0.625 -0.625 geometry.prob_hi=2.5 2.5 2.5"
#JOBS[((IDX++))]="pelec-scaling:debug:haswell:${OWD}/PeleC3d.${COMPILER}.haswell.MPI.ex:${OWD}/input-3d:4:32:30"; PRE_ARGS[$IDX]=""; POST_ARGS[$IDX]="amr.probin_file=${OWD}/probin-3d amr.n_cell=256 256 256 geometry.prob_lo=-1.0 -1.0 -1.0 geometry.prob_hi=4.0 4.0 4.0"
#JOBS[((IDX++))]="pelec-scaling:debug:haswell:${OWD}/PeleC3d.${COMPILER}.haswell.MPI.ex:${OWD}/input-3d:32:32:30"; PRE_ARGS[$IDX]=""; POST_ARGS[$IDX]="amr.probin_file=${OWD}/probin-3d amr.n_cell=512 512 512 geometry.prob_lo=-2.0 -2.0 -2.0 geometry.prob_hi=8.0 8.0 8.0"
#JOBS[((IDX++))]="pelec-scaling:regular:haswell:${OWD}/PeleC3d.${COMPILER}.haswell.MPI.ex:${OWD}/input-3d:256:32:30"; PRE_ARGS[$IDX]=""; POST_ARGS[$IDX]="amr.probin_file=${OWD}/probin-3d amr.n_cell=1024 1024 1024 geometry.prob_lo=-4.0 -4.0 -4.0 geometry.prob_hi=16.0 16.0 16.0"

#Example Peregrine Haswell Weak Scaling Study
#JOBS[((IDX++))]="pelec-scaling:short:haswell:${OWD}/PeleC3d.${COMPILER}.MPI.OMP.ex:${OWD}/input-3d:1:6:40"; PRE_ARGS[$IDX]=""; POST_ARGS[$IDX]="amr.probin_file=${OWD}/probin-3d amr.n_cell=160 160 160 geometry.prob_lo=-0.625 -0.625 -0.625 geometry.prob_hi=2.5 2.5 2.5"
#JOBS[((IDX++))]="pelec-scaling:short:haswell:${OWD}/PeleC3d.${COMPILER}.MPI.OMP.ex:${OWD}/input-3d:4:6:40"; PRE_ARGS[$IDX]=""; POST_ARGS[$IDX]="amr.probin_file=${OWD}/probin-3d amr.n_cell=256 256 256 geometry.prob_lo=-1.0 -1.0 -1.0 geometry.prob_hi=4.0 4.0 4.0"
#JOBS[((IDX++))]="pelec-scaling:batch-h:haswell:${OWD}/PeleC3d.${COMPILER}.MPI.OMP.ex:${OWD}/input-3d:32:6:40"; PRE_ARGS[$IDX]=""; POST_ARGS[$IDX]="amr.probin_file=${OWD}/probin-3d amr.n_cell=512 512 512 geometry.prob_lo=-2.0 -2.0 -2.0 geometry.prob_hi=8.0 8.0 8.0"
#JOBS[((IDX++))]="pelec-scaling:batch-h:haswell:${OWD}/PeleC3d.${COMPILER}.MPI.OMP.ex:${OWD}/input-3d:256:6:40"; PRE_ARGS[$IDX]=""; POST_ARGS[$IDX]="amr.probin_file=${OWD}/probin-3d amr.n_cell=1024 1024 1024 geometry.prob_lo=-4.0 -4.0 -4.0 geometry.prob_hi=16.0 16.0 16.0"

#Example Peregrine MPI/OMP sweep
#JOBS[((IDX++))]="pelec-scaling:batch-h:haswell:${OWD}/PeleC3d.${COMPILER}.MPI.OMP.ex:${OWD}/input-3d:8:24:30"; PRE_ARGS[$IDX]=""; POST_ARGS[$IDX]="amr.probin_file=${OWD}/probin-3d amr.n_cell=256 256 256 geometry.prob_lo=-1.0 -1.0 -1.0 geometry.prob_hi=4.0 4.0 4.0 max_step=5"
#JOBS[((IDX++))]="pelec-scaling:batch-h:haswell:${OWD}/PeleC3d.${COMPILER}.MPI.OMP.ex:${OWD}/input-3d:8:12:30"; PRE_ARGS[$IDX]=""; POST_ARGS[$IDX]="amr.probin_file=${OWD}/probin-3d amr.n_cell=256 256 256 geometry.prob_lo=-1.0 -1.0 -1.0 geometry.prob_hi=4.0 4.0 4.0 max_step=5"
#JOBS[((IDX++))]="pelec-scaling:batch-h:haswell:${OWD}/PeleC3d.${COMPILER}.MPI.OMP.ex:${OWD}/input-3d:8:6:30"; PRE_ARGS[$IDX]=""; POST_ARGS[$IDX]="amr.probin_file=${OWD}/probin-3d amr.n_cell=256 256 256 geometry.prob_lo=-1.0 -1.0 -1.0 geometry.prob_hi=4.0 4.0 4.0 max_step=5"
#JOBS[((IDX++))]="pelec-scaling:batch-h:haswell:${OWD}/PeleC3d.${COMPILER}.MPI.OMP.ex:${OWD}/input-3d:8:4:30"; PRE_ARGS[$IDX]=""; POST_ARGS[$IDX]="amr.probin_file=${OWD}/probin-3d amr.n_cell=256 256 256 geometry.prob_lo=-1.0 -1.0 -1.0 geometry.prob_hi=4.0 4.0 4.0 max_step=5"
#JOBS[((IDX++))]="pelec-scaling:batch-h:haswell:${OWD}/PeleC3d.${COMPILER}.MPI.OMP.ex:${OWD}/input-3d:8:2:30"; PRE_ARGS[$IDX]=""; POST_ARGS[$IDX]="amr.probin_file=${OWD}/probin-3d amr.n_cell=256 256 256 geometry.prob_lo=-1.0 -1.0 -1.0 geometry.prob_hi=4.0 4.0 4.0 max_step=5"
