#!/bin/bash

# Collect memory samples with ps while a proces (mpirun) is running

FILENAME=memory_plot.txt

mpirun -np 16 --oversubscribe ./PeleC3d.gnu.MPI.ex input-3d &

while [[ -n $(jobs -r) ]]; do
  ps -U ${USER} -o pid=,rss=,command= | grep Pele | grep -v grep | grep -v mpirun >> ${FILENAME} 2>&1;
  echo "" >> ${FILENAME} 2>&1;
  sleep 0.25;
done
