#!/bin/bash -l

#PBS -N profile_pele
#PBS -l nodes=1:ppn=24,walltime=1:00:00
#PBS -A ExaCT
#PBS -q short
#PBS -o $PBS_JOBNAME.log
#PBS -j oe
#PBS -W umask=002

set -e

cd ${HOME}

PELE_ROOT=${HOME}/combustion

source /nopt/intel/16.0/vtune_amplifier_xe/amplxe-vars.sh &> /dev/null

cd ${PELE_ROOT}/PeleC
git checkout development
git pull
cd ${PELE_ROOT}/PelePhysics
git checkout development
git pull
cd ${PELE_ROOT}/BoxLib
git checkout development
git pull

printf "\nCycling through tests...\n"

for TEST in TG
do
  for DIM in 2
  do
    sed -i 's/^max_step.*/max_step = 4000/g' ${PELE_ROOT}/PeleC/Exec/${TEST}/inputs_${DIM}d
    for COMP_NAME in gnu intel
    do
      for MPI in FALSE TRUE
      do
        for OMP in FALSE TRUE
        do
          if [ ${COMP_NAME} = 'gnu' ]
          then
            #GCC environment
            {
            module purge
            module load gcc/5.2.0
            module load openmpi-gcc/1.10.0-5.2.0
            module load python/2.7.8
            } &> /dev/null
            COMP_COMMAND=gcc
            FCOMP_COMMAND=gfortran
          else
            #Intel environment
            {
            module purge
            module load gcc/5.2.0
            module load compiler/intel/16.0.2
            module load impi-intel/5.1.3-16.0.2 
            module load python/2.7.8
            module load 
            } &> /dev/null
            COMP_COMMAND=intel
            FCOMP_COMMAND=ifort
          fi 

          if [ ${MPI} = 'TRUE' ]
          then
            MPI_NAME=-mpi
            MPI_EXE=.MPI
          else
            MPI_NAME=
          fi

          if [ ${OMP} = 'TRUE' ]
          then
            OMP_NAME=-omp
            OMP_EXE=.OMP
          else
            OMP_NAME=-serial
          fi

          printf "\n======================================================================\n"
          printf "\n${TEST}-${DIM}D-${COMP_NAME}${OMP_NAME}${MPI_NAME}\n"
         
          cd ${PELE_ROOT}/PeleC/Exec/${TEST}

          sed -i "s/^DIM.*/DIM        = ${DIM}/g; s/^COMP.*/COMP       = ${COMP_COMMAND}/g; s/^FCOMP.*/FCOMP      = ${FCOMP_COMMAND}/g; s/^USE_MPI.*/USE_MPI    = ${MPI}/g; s/^USE_OMP.*/USE_OMP    = ${OMP}/g" ${PELE_ROOT}/PeleC/Exec/${TEST}/GNUmakefile
          
          printf "Make...\n"
          make -j 16 &> /dev/null
          printf "Done.\n\n"
          
          printf "Run...\n"
          ls -alh ${PELE_ROOT}/PeleC/Exec/${TEST} | grep PeleC
          printf "PeleC${DIM}d.${COMP_NAME}${MPI_EXE}${OMP_EXE}.ex"
          #amplxe-cl -collect hotspots -result-dir r001hs-${TEST}-${DIM}d-${COMP_NAME}${OMP_NAME}${MPI_NAME} ./PeleC${DIM}d.${COMP_NAME}${MPI_EXE}${OMP_EXE}.ex inputs_${DIM}d &> /dev/null
          printf "Done.\n\n"
          #amplxe-cl -R hotspots -result-dir r001hs-${TEST}-${DIM}d-${COMP_NAME}${OMP_NAME}${MPI_NAME} -format=csv 2>&1 > r001hs-${TEST}-${DIM}d-${COMP_NAME}${OMP_NAME}${MPI_NAME}.txt
          
          printf "Clean...\n"
          {
          #rm -r chk*
          #rm -r plt*
          #rm -r r001hs-${TEST}-${DIM}d-${COMP_NAME}${OMP_NAME}${MPI_NAME}
          make clean
          } &> /dev/null
          printf "Done.\n\n"

        done
      done
    done
  done
done
