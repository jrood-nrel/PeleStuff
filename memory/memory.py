#!/usr/local/bin/python3
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

#Plot memory usage with data collected from ps

fname = "memory_plot.txt"
runtime = 1621.239386
title = "PeleC Memory Usage by MPI Rank - 4 AMR Levels - 1 Step - 1/4 Second Samples"
num_mpi_ranks = 16

data = pd.read_csv(fname, usecols=[0,1], header=None, delim_whitespace=True, names=['pid','mem'])
num_samples = int(len(data)/num_mpi_ranks)
time = np.arange(0, num_samples)*(runtime/num_samples)
data['mem'] = data['mem']/1024/1024
grouped = data.groupby(['pid'])
for k, (name, group) in enumerate(grouped):
    plt.figure(0)
    plt.plot(time, group.mem)
plt.xlabel("Elapsed Run Time (seconds)")
plt.ylabel("Memory Usage (GB)")
plt.title(title)
plt.show()
