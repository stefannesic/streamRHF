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
import Node
import sys
import mat73
# set the number of trees and max height
H = 5
T = 100
if len(sys.argv) < 2:
     print("Command: python d_v_t_script.py [dataset]")
     quit()

fname = str(sys.argv[1])
 
if (fname == "smtp.mat"):
    mat_contents = mat73.loadmat("../datasets/" + fname)
else:
    mat_contents = sio.loadmat("../datasets/" + fname)

dataset = mat_contents['X'] 
labels = mat_contents['y']
dataset = dataset.astype('float32') 

Node.data_complete = dataset

for i in range(0,10):
    t0 = time.time()

    test_rhf = rhf.rhf(X=dataset, t=T, h=H)
    scores = np.empty(labels.size)
    for x in range(dataset.shape[0]):
        x_value = Node.data_complete[x]
        score = a_s.anomaly_score(test_rhf, dataset.size, x, x_value)
        scores[x] = score    
   
    AP = average_precision_score(labels, scores)

    t1 = time.time()

    print("Total time for rhf-cython (train) = ", t1-t0)