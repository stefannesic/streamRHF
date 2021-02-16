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
import rhf_stream as rhfs
import sys 

if len(sys.argv) < 9:
    print("Command: python insertion_script.py [dataset] [N] [T] [H] [iterations] [EPS] [step] [end]")
    quit()

mat_contents = sio.loadmat("../datasets/" + str(sys.argv[1]))
data = mat_contents['X']
labels = mat_contents['y']
data = data.astype('float32')

N = int(sys.argv[2])
T = int(sys.argv[3])
H = int(sys.argv[4])

iterations = int(sys.argv[5])
step = int(sys.argv[7])
for m in range(0, iterations):
    print("Iteration=", m)
    EPS = int(sys.argv[6])
    end = int(sys.argv[8])


    for j in range(0, end):
        print("EPS=", EPS)
        t0 = time.time()
        forest = rhfs.rhf_stream(data, t=T, h=H, n=N, eps=EPS)

        scores = np.empty(labels.size)
        for x in range(data.shape[0]):
            x_value = Node.data_complete[x]
            score = a_s.anomaly_score(forest, data.size, x, x_value)
            scores[x] = score

        t1 = time.time()
        print("AP=", average_precision_score(labels, scores))
        print("time (whole)=", t1 - t0)
        EPS = EPS + step


