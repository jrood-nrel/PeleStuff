#!/bin/bash -l

#PBS -N mpiperf_pele
#PBS -l nodes=2:ppn=24,walltime=4:00:00
#PBS -A ExaCT
#PBS -q short
#PBS -o $PBS_JOBNAME.log
#PBS -j oe
#PBS -W umask=002

set -e

cd ${HOME}

PELE_ROOT=${HOME}/combustion

cd ${PELE_ROOT}/PeleC
git checkout development
git pull
cd ${PELE_ROOT}/PelePhysics
git checkout development
git pull
cd ${PELE_ROOT}/BoxLib
git checkout development
git pull

ulimit -s 10240

printf "\nCycling through tests...\n\n"

for TEST in TG
do
  for DIM in 2
  do
    sed -i 's/^max_step.*/max_step = 4000/g' ${PELE_ROOT}/PeleC/Exec/${TEST}/inputs_${DIM}d
    for COMP_NAME in intel
    do
      for MPI in TRUE
      do
        for OMP in FALSE
        do
          if [ ${COMP_NAME} == 'gnu' ]; then
            #GCC environment
            {
            module purge
            module load gcc/5.2.0
            module load openmpi-gcc/1.10.0-5.2.0
            module load python/2.7.8
            source /home/jrood/combustion/mps_standalone/bin/mpsvars.sh
            } &> /dev/null
            COMP_COMMAND=gcc
            FCOMP_COMMAND=gfortran
          elif [ ${COMP_NAME} == 'intel' ]; then
            #Intel environment
            {
            module purge
            module load impi-intel/5.1.3-16.0.2 
            module load python/2.7.8
            source /home/jrood/combustion/mps_standalone/bin/mpsvars.sh
            } &> /dev/null
            COMP_COMMAND=intel
            FCOMP_COMMAND=ifort
          fi 

          if [ ${MPI} == 'TRUE' ]; then
            MPI_NAME=-mpi
            MPI_EXE=.MPI
          else
            MPI_NAME=
            MPI_EXE=
            MPI_CMD=
          fi

          if [ ${OMP} == 'TRUE' ]; then
            OMP_NAME=-omp
            OMP_EXE=.OMP
          else
            OMP_NAME=
            OMP_EXE=
          fi

          if [[ ${MPI} == 'TRUE' ]] && [[ ${OMP} == 'TRUE' ]]; then
            export OMP_NUM_THREADS=6
            MPI_CMD='mpirun -mps -np 8'
          elif [[ ${MPI} == 'TRUE' ]] && [[ ${OMP} == 'FALSE' ]]; then
            export OMP_NUM_THREADS=1
            MPI_CMD='mpirun -mps -np 48'
          elif [[ ${MPI} == 'FALSE' ]] && [[ ${OMP} == 'TRUE' ]]; then
            export OMP_NUM_THREADS=24
            MPI_CMD=
          else
            export OMP_NUM_THREADS=1
            MPI_CMD=
          fi

          printf "======================================================================\n"
          printf "${TEST}-${DIM}D-${COMP_NAME}${OMP_NAME}${MPI_NAME}\n\n"
         
          cd ${PELE_ROOT}/PeleC/Exec/${TEST}

          sed -i "s/^DIM.*/DIM        = ${DIM}/g; s/^COMP.*/COMP       = ${COMP_COMMAND}/g; s/^FCOMP.*/FCOMP      = ${FCOMP_COMMAND}/g; s/^USE_MPI.*/USE_MPI    = ${MPI}/g; s/^USE_OMP.*/USE_OMP    = ${OMP}/g" ${PELE_ROOT}/PeleC/Exec/${TEST}/GNUmakefile
          
          printf "Make...\n"
          make -j 24 &> ${TEST}-${DIM}d-${COMP_NAME}${OMP_NAME}${MPI_NAME}.make.txt
          printf "Done.\n\n"
          
          printf "Run...\n"
          printf "OMP_NUM_THREADS: $OMP_NUM_THREADS \n"
          set -x
          ${MPI_CMD} ./PeleC${DIM}d.${COMP_NAME}${MPI_EXE}${OMP_EXE}.ex inputs_${DIM}d &> ${TEST}-${DIM}d-${COMP_NAME}${OMP_NAME}${MPI_NAME}.run.txt
          #mps stat_pele _mps_pele -s -g
          set +x
          printf "Done.\n\n"
          
          printf "Clean...\n"
          {
          rm -r chk*
          rm -r plt*
          make clean
          } &> /dev/null
          printf "Done.\n\n"

        done
      done
    done
  done
done
