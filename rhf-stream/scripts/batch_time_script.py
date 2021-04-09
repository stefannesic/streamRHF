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
import rht
import rhf
import anomaly_score as a_s
import mat73
import utils
# set the number of trees and max height
H = 5
T = 100

if len(sys.argv) < 2:
     print("Command: python d_v_t_script.py [dataset]")
     quit()

fname = str(sys.argv[1])

data, labels = utils.load_dataset(fname)

for i in range(0,10):
    t0 = time.time()

    indexes = rhf.rhf(data, T, H)
    scores = a_s.anomaly_score(indexes, T)
   
    AP = average_precision_score(labels, scores)

    t1 = time.time()

    print("Total time for rhf-cython (train) = ", t1-t0)
    print("AP=", AP)
