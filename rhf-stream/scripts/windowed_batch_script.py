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

if len(sys.argv) <3:
     print("Command: python windowed_batch_script.py [dataset] [initalsamplepercent]")
     quit()

fname = str(sys.argv[1])
init = int(sys.argv[2])
data, labels = utils.load_dataset(fname)
N = data.shape[0]

init = int(round(data.shape[0] * (init / 100)))

data = data.copy(order='C')
for i in range(0,10):
    t0 = time.time()
    scores = rhfs.rhf_windowed(data, T, H, init)
    t1 = time.time()
    AP = average_precision_score(labels, scores)
    print("Total time for rhf-cython (train) = ", t1-t0)
    print("AP=", AP)
