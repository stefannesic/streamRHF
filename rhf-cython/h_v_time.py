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

mat_contents = sio.loadmat("../datasets/cardio.mat")
dataset = mat_contents['X'] 
labels = mat_contents['y']


for j in range(1, 11):
    T_h = 100
    
    H_h = j
    print("BC, H_h=", H_h)
    
    dataset = dataset.astype('float32') 

    code = '''
print("H_h", H_h)
test_rhf = rhf.rhf(X=dataset, t=T_h, nd=0, h=H_h)

scores = np.empty(labels.size)
for i, x in enumerate(dataset):
    score = a_s.anomaly_score(test_rhf, dataset.size, x)
    np.append(scores, score)    
'''
    
    print("Total time for rhf-cython (train) = ", timeit(stmt=code, number=10, globals=globals()))
