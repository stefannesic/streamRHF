import sys 
import time 
from sklearn.metrics import average_precision_score
import numpy as np
import rhf_stream as rhfs
import utils

if len(sys.argv) < 8:
    print("Command: python3 insertion_script.py [dataset] [T] [H] [iterations] [initsamplepercent] [shuffled?] [constant?]")
    quit()

# Get path to datasets
config = utils.read_config()
data_path = config['DATA']['dataset_path']

# dataset file name
fname = str(sys.argv[1])
# number of trees (100 recommended)
T = int(sys.argv[2])
# height of trees (5 recommended)
H = int(sys.argv[3])
# number of iterations 
iterations = int(sys.argv[4])
# initial sample size, percentage or constant (see "const" parameter below)
init = int(sys.argv[5])
# shuff = 1 means dataset will be randomly shuffled
# shuff = 0 means dataset will be read as is 
shuff = int(sys.argv[6])
# const = 1 means initial sample is a constant
# const = 0 means initial sample size is the percentage value of the total dataset size
const = int(sys.argv[7])

# read data and labels
data, labels = utils.load_dataset(fname, data_path, shuffled=shuff)

# get dataset size
N = data.shape[0]

# calculate number of initial values / window size
if not const:
    N_init_pts = int(round(data.shape[0] * (init / 100)))
else:
    N_init_pts = init

print("Number of initial points / window size: ", N_init_pts)

# adjust data array so cython module can use it correctly 
data = np.array(data, dtype='float64')
data = data.copy(order='C')

for m in range(0, iterations):
    print("Iteration #", m)
    # build info reinitialized
    t0 = time.time()
    scores = rhfs.rhf_stream(data, T, H, N_init_pts) 
    t1 = time.time()
    print("AP score:", average_precision_score(labels, scores))
    print("Total time:", t1 - t0)
    # if shuffling data, reload a new sample at each iteration
    if shuff:
        data, labels = utils.load_dataset(fname, data_path, shuffled=True)
        data =  np.array(data, dtype='float64')
        data = data.copy(order='C')
