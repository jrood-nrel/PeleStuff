#!/bin/bash -l

run_tests() {
  if [ "${EB_STATE}" == "ON" ]; then
    EB_SUFFIX='-eb'
  else
    EB_SUFFIX=''
  fi
  BDIR=${FILE}
  DIR=${BDIR}${EB_SUFFIX}
  SAVED_GOLDS_DIR=${MYPATH}/saved-golds/${DIR}
  REF_GOLDS_DIR=${MYPATH}/ref-golds${EB_SUFFIX}
  mkdir -p ${SAVED_GOLDS_DIR}
  mkdir ${DIR}
  if [ "${FILE}" != "Init" && "${FILE}" != "Ref" ]; then
    (cd ${SOURCE_DIR} && git checkout . && cp ${PR_SOURCE_DIR}/${FILE} ${SOURCE_DIR}/${FILE} && git diff .) &> ${DIR}/git-diff.txt
    if [ "${FILE}" == "PeleLMeX_Forces.cpp" ]; then
      (cd ${SOURCE_DIR} && cp ${PR_SOURCE_DIR}/PeleLMeX.H ${SOURCE_DIR}/)
    fi
  fi
  if [ "${FILE}" == "Init" ]; then
    mkdir -p ${REF_GOLDS_DIR}
  fi
  cmake -B ${DIR} \
        -DCMAKE_INSTALL_PREFIX:PATH=./install \
        -DCMAKE_CXX_COMPILER:STRING=g++ \
        -DCMAKE_C_COMPILER:STRING=gcc \
        -DCMAKE_BUILD_TYPE:STRING=RelWithDebInfo \
        -DPELE_DIM:STRING=3 \
        -DPELE_ENABLE_MPI:BOOL=ON \
        -DPELE_ENABLE_CUDA:BOOL=ON \
        -DPELE_ENABLE_EB:BOOL=${EB_STATE} \
        -DCMAKE_CUDA_ARCHITECTURES:STRING=80 \
        -DPELE_PRECISION:STRING=DOUBLE \
        -DPELE_ENABLE_FCOMPARE_FOR_TESTS:BOOL=ON \
        -DPELE_SAVE_GOLDS:BOOL=ON \
        -DPELE_SAVED_GOLDS_DIRECTORY:PATH=${SAVED_GOLDS_DIR} \
        -DPELE_REFERENCE_GOLDS_DIRECTORY:PATH=${REF_GOLDS_DIR} \
        ${MYPATH}/PeleLMeX &> ${DIR}/cmake-configure.txt
  nice cmake --build ${DIR} --parallel 10 &> ${DIR}/build.txt
  (cd ${DIR} && ctest -VV &> ${FILE}-output.txt) || true
  if [ "${FILE}" == "Init" ]; then
    cp -R ${SAVED_GOLDS_DIR}/* ${REF_GOLDS_DIR}/
  fi
}

module load cmake
module load mpich
module load cuda/12.8.1

set -e
set -x

MYPATH=${PWD}
SOURCE_REPO=https://github.com/AMReX-Combustion/PeleLMeX.git
PR_REPO=https://github.com/ThomasHowarth/PeleLMeX.git
PR_BRANCH=kernel_fusing
REPO_DIR=${MYPATH}/PeleLMeX
PR_REPO_DIR=${MYPATH}/PeleLMeX_PR
SOURCE_DIR=${REPO_DIR}/Source
PR_SOURCE_DIR=${PR_REPO_DIR}/Source

for FILE in Init Ref PeleLMeX_Advection.cpp PeleLMeX_DeriveFunc.cpp PeleLMeX_Diffusion.cpp PeleLMeX_DiffusionOp.cpp PeleLMeX_Forces.cpp PeleLMeX_Index.H PeleLMeX_Init.cpp PeleLMeX_K.H PeleLMeX_ODEQty.cpp PeleLMeX_Plot.cpp PeleLMeX_Projection.cpp PeleLMeX_Reactions.cpp PeleLMeX_Soot.cpp PeleLMeX_Timestep.cpp PeleLMeX_UMac.cpp PeleLMeX_Utils.cpp
do
  if [ "${FILE}" == "Init" ]; then
    git clone --recursive ${SOURCE_REPO} ${REPO_DIR}
    git clone --recursive -b ${PR_BRANCH} ${PR_REPO} ${PR_REPO_DIR}
  fi

  EB_STATE=OFF
  run_tests

  EB_STATE=ON
  run_tests
done
