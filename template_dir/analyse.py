#!/usr/bin/env python

import numpy as np
from matplotlib import pyplot as plt
import argparse
import pathlib

parser = argparse.ArgumentParser(description='Plot timing data. Shows interactive plot by default. Can save to file with -o option.')
parser.add_argument('file', help='file to plot')
parser.add_argument('-o','--output', help='output file name')

args = parser.parse_args()
data = np.genfromtxt(args.file, missing_values="NaN")       # Load data

arr = [1, 2, 4, 8, 16, 32, 64]
Narr = np.unique(np.outer(arr,arr)).flatten()
ncpus = data[:,0]*data[:,1]*data[:,2]

for N in Narr:
  cond = ncpus == N                   # Find where mpi*omp==N
  if not np.any(cond): continue
  # Take subset of data
  d = data[cond,:]

  ratio  = d[:,0]*d[:,1]/d[:,2]       # Ratio of mpi to omp
  timings = d[:,3]

  # Sort by ratio
  sort = np.argsort(ratio)
  ratio = ratio[sort]
  timings = timings[sort]

  plt.plot(ratio,timings,'.-',label=N)

plt.xscale('log', base=2)
plt.xticks(ratio,ratio)               # Full number tick labels
if '%' in args.file:
  plt.ylabel('Time (%)')
elif args.file.endswith('bal.txt'):
  plt.ylabel('MPI work balance (%)')
else:
  plt.ylabel('Time (s)')
plt.xlabel('MPI to OMP ratio')
title = pathlib.Path(args.file).stem  # Construct title from file name
plt.title(title)
plt.legend(loc='best')

if args.output:
  plt.savefig(args.output)
else:
  plt.show()
