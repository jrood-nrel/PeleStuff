#!/bin/bash

run_plot() {
  if [ "${EB_STATE}" == "ON" ]; then
    python plot.py --filename ${FILE}-eb-fcompare.txt
  else
    python plot.py --filename ${FILE}-fcompare.txt
  fi
}

for FILE in Init Ref PeleLMeX_Advection.cpp PeleLMeX_DeriveFunc.cpp PeleLMeX_Diffusion.cpp PeleLMeX_DiffusionOp.cpp PeleLMeX_Forces.cpp PeleLMeX_Index.H PeleLMeX_Init.cpp PeleLMeX_K.H PeleLMeX_ODEQty.cpp PeleLMeX_Plot.cpp PeleLMeX_Projection.cpp PeleLMeX_Reactions.cpp PeleLMeX_Soot.cpp PeleLMeX_Timestep.cpp PeleLMeX_UMac.cpp PeleLMeX_Utils.cpp
do
  EB_STATE=OFF
  run_plot

  EB_STATE=ON
  run_plot
done
