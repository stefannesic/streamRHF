import sys 
sys.path.insert(1, '../../datasets/forStefan/')
sys.path.insert(2, '../')
from timeit import timeit
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

np.set_printoptions(threshold=sys.maxsize)
# set the number of trees and max height
H = 5
T = 100

if len(sys.argv) < 2:
     print("Command: python d_v_t_script.py [dataset]")
     quit()

fname = str(sys.argv[1])

data, labels = utils.load_dataset(fname)
N = data.shape[0]
data = data.copy(order='C')
for i in range(0,10):
    t0 = time.time()
    insertionDS = rhfs.rhf(data, T, H)
    #scores = a_s.anomaly_score(indexes, T)
    scores = rhfs.anomaly_score_ids(insertionDS, T, N)
    AP = average_precision_score(labels, scores)

    t1 = time.time()
    #print(np.asarray(split_info[i].kurtosis_vals[0]))
    #print(split_info[i].kurtosis_sum[0])
    print("Total time for rhf-cython (train) = ", t1-t0)
    print("AP=", AP)
