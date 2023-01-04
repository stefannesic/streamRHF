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
    print("Command: python insertion_script.py [dataset] [T] [H] [iterations] [EPS] [step] [end]")
    quit()

fname = str(sys.argv[1])

data, labels = utils.load_dataset(fname)
# N is 1% of the dataset 
N_init_pts = int(round(data.shape[0] * 0.01))

T = int(sys.argv[2])
H = int(sys.argv[3])
N = data.shape[0]
print("N_init_pts=", N_init_pts)
iterations = int(sys.argv[4])
step = float(sys.argv[6])
EPS = float(sys.argv[5])
end = int(sys.argv[7])
data = data.copy(order='C')
for m in range(0, iterations):
    print("Iteration=", m)
    epsilon = EPS    
    for j in range(0, end):
        print("EPS=", epsilon)
        # build info reinitialized
        t0 = time.time()
        insertionDS = rhfs.rhf_stream(data, T, H, N_init_pts, epsilon) 
        scores = rhfs.anomaly_score_ids(insertionDS, T, N)
        t1 = time.time()
        print("AP=", average_precision_score(labels, scores))
        print("time (whole)=", t1 - t0)
        epsilon = epsilon + step


