#!/bin/bash -l

#SBATCH --job-name=piston-bowl-0
#SBATCH --account=exact
#SBATCH --nodes=4
#SBATCH --time=4:00:00
#SBATCH --partition=short
#SBATCH -o %x.o%j

cmd() {
  echo "+ $@"
  eval "$@"
}

JOB_CHAIN_NAME="piston-bowl"
THIS_SCRIPT_NAME="submit.sh"
INDEX_MIN=0
INDEX_MAX=5

: ${INDEX:=${INDEX_MIN}}
NEXT_INDEX=$((INDEX+1))

if ((INDEX==INDEX_MIN)); then
  NEXT_JOB=$(sbatch --job-name=${JOB_CHAIN_NAME}-${NEXT_INDEX} --export=ALL,INDEX=${NEXT_INDEX} ${THIS_SCRIPT_NAME} | awk '{print $4}')
  echo "Submitted ${NEXT_JOB}"
elif ((INDEX>INDEX_MIN && INDEX<INDEX_MAX)); then
  NEXT_JOB=$(sbatch --job-name=${JOB_CHAIN_NAME}-${NEXT_INDEX} --export=ALL,INDEX=${NEXT_INDEX} --dependency=afterany:${SLURM_JOB_ID} ${THIS_SCRIPT_NAME} | awk '{print $4}')
  echo "Submitted ${NEXT_JOB} depending on termination of ${SLURM_JOB_ID}"
else
  echo "Last job in job chain"
fi

# Do stuff based on first or subsequent step
if ((INDEX==INDEX_MIN)); then
  RESTART_STRING=""
elif ((INDEX>INDEX_MIN)); then
  LATEST_CHECKPOINT=$(ls -1tr | grep chk | tail -1)
  RESTART_STRING="amr.restart=${LATEST_CHECKPOINT}"
fi

# Do common stuff
cmd "export LD_LIBRARY_PATH=${HOME}/combustion/PeleC/Submodules/PelePhysics/ThirdParty/INSTALL/gcc/lib:${LD_LIBRARY_PATH}"
cmd "module load mpt"
cmd "mpirun -n 144 ./PeleC3d.gnu.MPI.ex inputs.3d ${RESTART_STRING}"
