from my_imports import np, rht, split

# construction of a random histogram forest
cpdef rhf(float[:,:] data, int t, int h):
    cdef int n = data.shape[0], d = data.shape[1], leaves = 2**h
    cdef int W_MAX = 100000
    # create an empty forest of t trees each with n x 3 
    # 2 = (index in X, number of elems in leaf)
    indexes = np.empty([t, n, 2], dtype=np.intc)
    # moments = trees * nodes * attributes * card({M1, M2, M3, M4, n})
    moments = np.zeros([t, (2**h)-1, d, 5], dtype=np.float32)
    splits = np.empty([t], dtype=object)
    # create secondary data structure for insertion algorithm
    insertionDS = np.empty([t, 2**h, W_MAX], dtype=np.intc)
    # calculate t trees in global index variable
    for i in range(t):
        # intialize dataset.index
        indexes[i,:,0] = range(0, n)
        splits[i] = split.Split(h)
        rht.rht(data=data, indexes=indexes[i], split_info=splits[i], moments=moments[i], start=0, end=n-1, nd=0, H=h, nodeID=0) 
           
    return indexes, splits
