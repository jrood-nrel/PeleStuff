#!/bin/bash -l

#SBATCH -q debug
#SBATCH -N 1
#SBATCH -t 00:30:00
#SBATCH -o %x.o%j
#SBATCH -L SCRATCH
#SBATCH -A m2860

set -e

# Slurm script for submitting a job chain that will run jobs sequentially
# Execute as ./script.sh and it will start submitting at INDEX_MIN+1 and end at INDEX_MAX

# Job chain options
JOB_CHAIN_NAME="pc-filter-loop-order"
THIS_SCRIPT_NAME="run_cases.sh"
INDEX_MIN=0
INDEX_MAX=5

do_work () {
    PELECBIN=./PeleC3d.intel.ivybridge.PROF.MPI.OMP.${INDEX}.ex
    INAME=inputs_3d
    RANKS_PER_NODE=24
    THREADS=1
    RANKS=$((${SLURM_JOB_NUM_NODES} * ${RANKS_PER_NODE}))
    CORES_PER_RANK=2
    CORES=$((${RANKS} * ${THREADS}))
    echo "Running with ${RANKS} ranks and ${RANKS_PER_NODE} ranks and ${THREADS} threads per node on ${SLURM_JOB_NUM_NODES} nodes (${CORES} cores)"
    (set -x; export OMP_NUM_THREADS=${THREADS}; export OMP_PROC_BIND=spread; export OMP_PLACES=threads; srun -n ${RANKS} -c ${CORES_PER_RANK} --cpu_bind=cores ${PELECBIN} ${INAME} pelec.use_explicit_filter=0 > 0pts_loop${INDEX}.out 2>&1 ;)
    (set -x; export OMP_NUM_THREADS=${THREADS}; export OMP_PROC_BIND=spread; export OMP_PLACES=threads; srun -n ${RANKS} -c ${CORES_PER_RANK} --cpu_bind=cores ${PELECBIN} ${INAME} pelec.les_filter_type=0 > 1pts_loop${INDEX}.out 2>&1 ;)
    (set -x; export OMP_NUM_THREADS=${THREADS}; export OMP_PROC_BIND=spread; export OMP_PLACES=threads; srun -n ${RANKS} -c ${CORES_PER_RANK} --cpu_bind=cores ${PELECBIN} ${INAME} pelec.les_filter_fgr=2 > 3pts_loop${INDEX}.out 2>&1 ;)
    (set -x; export OMP_NUM_THREADS=${THREADS}; export OMP_PROC_BIND=spread; export OMP_PLACES=threads; srun -n ${RANKS} -c ${CORES_PER_RANK} --cpu_bind=cores ${PELECBIN} ${INAME} pelec.les_filter_fgr=4 > 5pts_loop${INDEX}.out 2>&1 ;)
    (set -x; export OMP_NUM_THREADS=${THREADS}; export OMP_PROC_BIND=spread; export OMP_PLACES=threads; srun -n ${RANKS} -c ${CORES_PER_RANK} --cpu_bind=cores ${PELECBIN} ${INAME} pelec.les_filter_fgr=6 > 7pts_loop${INDEX}.out 2>&1 ;)
}

: ${INDEX:=${INDEX_MIN}}
NEXT_INDEX=$((INDEX+1))

if ((INDEX==INDEX_MIN)); then
  # Submit the first job
  NEXT_JOB=$(sbatch -J ${JOB_CHAIN_NAME}${NEXT_INDEX} --export=INDEX=${NEXT_INDEX} ${THIS_SCRIPT_NAME} | awk '{print $4}')
  echo "Submitted ${NEXT_JOB}"
elif ((INDEX>INDEX_MIN && INDEX<INDEX_MAX)); then
  # Submit the next job
  NEXT_JOB=$(sbatch -J ${JOB_CHAIN_NAME}${NEXT_INDEX} --export=INDEX=${NEXT_INDEX} -d afterok:${SLURM_JOB_ID} ${THIS_SCRIPT_NAME} | awk '{print $4}')
  echo "Submitted ${NEXT_JOB} depending on success of ${SLURM_JOB_ID}"
fi

# Do the actual work in the script
if ((INDEX>INDEX_MIN)); then
 do_work
fi
