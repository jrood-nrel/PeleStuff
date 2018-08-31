#!/bin/bash

# Collect memory samples with ps while a proces (mpirun) is running

FILENAME=memory_plot.txt

mpirun -np 16 --oversubscribe ./PeleC3d.gnu.MPI.ex input-3d &

while [[ -n $(jobs -r) ]]; do
  ps -U ${USER} -o pid= -o rss= -o command= | grep Pele | grep -v grep | grep -v mpirun | grep -v mpiexec >> ${FILENAME} 2>&1 || true;
  echo "" >> ${FILENAME} 2>&1;
  sleep 0.5;
done
