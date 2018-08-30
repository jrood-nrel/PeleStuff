#!/bin/bash

# Collect memory samples with ps while a proces (mpirun) is running
mpirun -np 16 --oversubscribe ./PeleC3d.gnu.MPI.ex input-3d &
while [[ -n $(jobs -r) ]]; do
  ps -U jrood -o pid=,rss=,command= | grep Pele | grep -v grep | grep -v mpirun >> memory_plot.txt 2>&1;
  echo "" >> memory_plot.txt 2>&1;
  sleep 0.25;
done
