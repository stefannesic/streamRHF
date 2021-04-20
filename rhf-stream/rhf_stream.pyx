from my_imports import np, rht, rhts, split, leaves

# construction of a random histogram forest
cpdef rhf_stream(float[:,:] data, int t, int h, int N_init_pts):
    cdef int n = data.shape[0], d = data.shape[1]
    cdef int W_MAX = n
    # create an empty forest of t trees each with n x 3 
    # 2 = (index in X, number of elems in leaf)
    indexes = np.empty([t, N_init_pts, 2], dtype=np.intc)
    # moments = trees * nodes * attributes * card({M1, M2, M3, M4, n})
    moments = np.zeros([t, (2**h)-1, d, 5], dtype=np.float32)
    splits = np.empty([t], dtype=object)
    # create secondary data structure for insertion algorithm
    insertionDS = np.empty([t], dtype=object)
    # calculate t trees in global index variable
    for i in range(t):
        print("i=", i)
        # intialize dataset.index
        indexes[i,:,0] = range(0, N_init_pts)
        splits[i] = split.Split(h, d)
        insertionDS[i] = leaves.Leaves(h, W_MAX)
        rhts.rht_stream(data=data, indexes=indexes[i], insertionDS=insertionDS[i], split_info=splits[i], moments=moments[i], H=h, N_init_pts=N_init_pts) 
           
    return indexes, splits, insertionDS, moments

