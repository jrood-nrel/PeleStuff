#!/usr/local/bin/python3
import pandas as pd
import matplotlib.pyplot as plt

#Plot memory usage with data collected from ps

fname = "memory_plot.txt"
runtime = 338.5391371
title = "PeleC Total Memory Usage - 3 AMR Levels - 2 Steps - 1/4 Second Samples"
num_ranks = 16

data = pd.read_csv(fname, usecols=[0,1], header=None, delim_whitespace=True, names=['pid','mem'])

total_mem = []
elapsed_time = []
mem_sum = 0
samples = len(data)/num_ranks
current_sample = 0
for index, row in data.iterrows():
   if index % num_ranks == 0:
       total_mem.append(mem_sum)
       elapsed_time.append(current_sample*(runtime/samples))
       current_sample += 1
       mem_sum = 0
   mem_sum += row['mem']
total_mem.append(0)
elapsed_time.append(runtime)
plt.plot(elapsed_time, total_mem)
plt.xlabel("Elapsed Run Time (seconds)")
plt.ylabel("Memory Usage (MB)")
plt.title(title)
plt.show()
