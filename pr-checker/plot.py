import matplotlib.pyplot as plt
import pandas as pd
import argparse

parser = argparse.ArgumentParser("simple_example")
parser.add_argument("--filename", type=str)
args = parser.parse_args()
fname = args.filename
data = pd.read_csv(fname, sep=r"\s+", usecols=[0,1,2], header=None)
print(data)
#fig, ax = plt.subplots()
#ax.bar(data['var'], data['abs'], )
#ax = plt.gca()
#ax.set_ylim([0, 1e-12])
#plt.yscale('symlog')
#plt.show()
#plt.savefig(f'{fname}.png')
