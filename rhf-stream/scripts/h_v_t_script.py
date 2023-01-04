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

if len(sys.argv) < 2:
    print("Command: python h_v_t_script.py [dataset]")
    quit()


mat_contents = sio.loadmat("../../datasets/" + str(sys.argv[1]))
dataset = mat_contents['X']
labels = mat_contents['y']

dataset = dataset.astype('float32')

Node.data_complete = dataset
for j in range(1, 11):
    T_h = 100

    H_h = j

    code = '''
print("H_h", H_h)
test_rhf = rhf.rhf(X=dataset, t=T_h, h=H_h)
scores = np.empty(labels.size)
for x in range(dataset.shape[0]):
    x_value = Node.data_complete[x]
    score = a_s.anomaly_score(test_rhf, dataset.size, x, x_value)
    scores[x] = score    
'''

    print("Total time for rhf-cython (train) = ", timeit(stmt=code, number=10, globals=globals()))

