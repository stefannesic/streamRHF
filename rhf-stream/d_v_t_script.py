from timeit import timeit
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

if len(sys.argv) < 3:
    print("Command: python d_v_t_script.py [dataset] [step]")
    quit()


mat_contents = sio.loadmat("../datasets/" + str(sys.argv[1]))
dataset = mat_contents['X']
labels = mat_contents['y']

dataset = dataset.astype('float32')

step = int(sys.argv[2])
T = 100
H = 5

d = 1
ds = dataset
print("ds.shape=", ds.shape)
while d < ds.shape[1]: 
    dataset = ds[:, :d]

    Node.data_complete = dataset
    print("data set shape=", dataset.shape) 
    code = '''
print("d=", d)
test_rhf = rhf.rhf(X=dataset, t=T, h=H)
scores = np.empty(labels.size)
for x in range(dataset.shape[0]):
    x_value = Node.data_complete[x]
    score = a_s.anomaly_score(test_rhf, dataset.size, x, x_value)
    scores[x] = score    
'''

    print("Total time for rhf-cython (train) = ", timeit(stmt=code, number=10, globals=globals()))
    d = d + step
