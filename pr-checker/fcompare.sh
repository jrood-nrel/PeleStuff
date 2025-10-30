#!/bin/bash -l

run_fcompare() {
  if [ "${EB_STATE}" == "ON" ]; then
    EB_SUFFIX='-eb'
  else
    EB_SUFFIX=''
  fi
  BDIR=${FILE}
  DIR=${BDIR}${EB_SUFFIX}
  SAVED_GOLDS_DIR=${MYPATH}/saved-golds/${DIR}
  REF_GOLDS_DIR=${MYPATH}/ref-golds${EB_SUFFIX}
  if [ "${EB_STATE}" == "ON" ]; then
    for TEST in EB_ODEQty/eb-odeqty-3d
    do
      /mnt/vdb/home/jrood/combustion/test/Init/Submodules/PelePhysics/Submodules/amrex/Tools/Plotfile/amrex_fcompare ${SAVED_GOLDS_DIR}/Linux/GNU/12.5.0/${TEST}/plt00010 ${REF_GOLDS_DIR}/Linux/GNU/12.5.0/${TEST}/plt00010 | egrep "x_velocity|y_velocity|z_velocity|density" &> ${FILE}-eb-fcompare.txt || true
    done
  else
    for TEST in FlameSheet/flamesheet-drm19-3d
    do
      /mnt/vdb/home/jrood/combustion/test/Init/Submodules/PelePhysics/Submodules/amrex/Tools/Plotfile/amrex_fcompare ${SAVED_GOLDS_DIR}/Linux/GNU/12.5.0/${TEST}/plt00010 ${REF_GOLDS_DIR}/Linux/GNU/12.5.0/${TEST}/plt00010 | egrep "x_velocity|y_velocity|z_velocity|density" &> ${FILE}-fcompare.txt || true
    done
  fi
}

module load cmake
module load mpich
module load cuda/12.8.1

set -e
set -x

MYPATH=${PWD}

for FILE in Init Ref PeleLMeX_Advection.cpp PeleLMeX_DeriveFunc.cpp PeleLMeX_Diffusion.cpp PeleLMeX_DiffusionOp.cpp PeleLMeX_Forces.cpp PeleLMeX_Index.H PeleLMeX_Init.cpp PeleLMeX_K.H PeleLMeX_ODEQty.cpp PeleLMeX_Plot.cpp PeleLMeX_Projection.cpp PeleLMeX_Reactions.cpp PeleLMeX_Soot.cpp PeleLMeX_Timestep.cpp PeleLMeX_UMac.cpp PeleLMeX_Utils.cpp
do
  EB_STATE=OFF
  run_fcompare

  EB_STATE=ON
  run_fcompare
done
