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
import dataset, constants
# set the number of trees and max height
H = 5
T = 100

if len(sys.argv) < 2:
     print("Command: python d_v_t_script.py [dataset]")
     quit()

fname = str(sys.argv[1])

data, labels = utils.load_dataset(fname)

dataset.data = data
N = data.shape[0]
D = data.shape[1]
constants.D = D
constants.N = N
constants.H = H
constants.T = T
constants.moments = np.zeros([6], np.float32)
constants.moments0 = np.zeros([D, 6], np.float32)

for i in range(0,10):
    t0 = time.time()

    rhf.rhf()
    scores = a_s.anomaly_score()
   
    AP = average_precision_score(labels, scores)

    t1 = time.time()

    print("Total time for rhf-cython (train) = ", t1-t0)
    print("AP=", AP)
