import sys 
sys.path.insert(1, '../../datasets/forStefan/')
sys.path.insert(2, '../')
import utils
import time
from sklearn.metrics import average_precision_score
import math
import scipy.io as sio
import scipy.stats as sstats
import random
import numpy as np
import rht
import rhf
import anomaly_score as a_s
import Node

if len(sys.argv) < 2:
    print("Command: python h_v_t_script.py [dataset]")
    quit()

fname = str(sys.argv[1])

dataset, labels = utils.load_dataset(fname)

Node.data_complete = dataset
for j in range(1, 11):
    T_h = 100

    H_h = j
    
    total_time = 0
    Node.ktime = np.zeros([10])
    Node.ksstats = np.zeros([5], np.float32)
    for i in range(0, 10):
        t0 = time.time()
        print("H_h", H_h)
        test_rhf = rhf.rhf(X=dataset, t=T_h, h=H_h)
        t1 = time.time()
        total_time += (t1 - t0)
    print("Total time for rhf-cython (train) = ", total_time)
    print("Total kurtosis contribution=", Node.ktime)
    print("Kurtosis sum breakdown totals=", Node.ksstats)

