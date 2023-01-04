from my_imports import np, rht, split, leaves

# construction of a random histogram forest
cpdef rhf(float[:,:] data, int t, int h):
    cdef int n = data.shape[0], d = data.shape[1]
    cdef int W_MAX = n
    # create an empty forest of t trees each with n x 3 
    # 2 = (index in X, number of elems in leaf)
    indexes = np.empty([t, n, 2], dtype=np.intc)
    # moments = trees * nodes * attributes * card({M1, M2, M3, M4, n})
    moments = np.zeros([t, (2**h)-1, d, 6], dtype=np.float32)
    splits = np.empty([t], dtype=object)
    # create secondary data structure for insertion algorithm
    insertionDS = np.empty([t], dtype=object)
    # calculate t trees in global index variable
    for i in range(t):
        # intialize dataset.index
        indexes[i,:,0] = range(0, n)
        splits[i] = split.Split(h, d)
        insertionDS[i] = leaves.Leaves(h, W_MAX)
        rht.rht(data=data, indexes=indexes[i], insertionDS=insertionDS[i], split_info=splits[i], moments=moments[i], start=0, end=n-1, nd=0, H=h, nodeID=0) 
           
    return indexes, splits, insertionDS, moments

       
