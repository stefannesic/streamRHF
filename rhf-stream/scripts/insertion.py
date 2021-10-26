import sys 
sys.path.insert(1, '../../datasets/forStefan/')
sys.path.insert(2, '../')
import time 
from sklearn.metrics import average_precision_score
import math
import scipy.io as sio
import scipy.stats as sstats
import random
import numpy as np
import rhf_stream as rhfs
import mat73
import utils

#sys.stdout = open('out.log', 'w')
#sys.stderr = sys.stdout

if len(sys.argv) < 8:
    print("Command: python3 insertion_script.py [dataset] [T] [H] [iterations] [initsamplepercent] [shuffled?] [constant?]")
    quit()

fname = str(sys.argv[1])

# N is 1% of the dataset 
T = int(sys.argv[2])
H = int(sys.argv[3])
iterations = int(sys.argv[4])
init = int(sys.argv[5])
shuff = int(sys.argv[6])
const = int(sys.argv[7])

if shuff == 1:
    data, labels = utils.load_dataset_shuffled(fname)
else:
    data, labels = utils.load_dataset(fname)

N = data.shape[0]
if const == 0:
    N_init_pts = int(round(data.shape[0] * (init / 100)))
else:
    N_init_pts = init
print("N_init_pts=", N_init_pts)

data = np.array(data, dtype='float64')
data = data.copy(order='C')

for m in range(0, iterations):
    print("Iteration=", m)
    # build info reinitialized
    t0 = time.time()
    scores = rhfs.rhf_stream(data, T, H, N_init_pts) 
    t1 = time.time()
    print("AP=", average_precision_score(labels, scores))
    print("time (whole)=", t1 - t0)
    if shuff == 1:
        data, labels = utils.load_dataset_shuffled(fname)
        data = np.array(data, dtype='float64')
        data = data.copy(order='C')


