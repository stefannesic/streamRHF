from my_imports import np, rht

# construction of a random histogram forest
cpdef rhf(float[:,:] data, int t, int h):
    cdef int n = data.shape[0]
    # create an empty forest of t trees each with n x 3 
    # 2 = (index in X, number of elems in leaf)
    indexes = np.empty([t, n, 2], dtype=np.intc)

    # calculate t trees in global index variable
    for i in range(t):
        # intialize dataset.index
        indexes[i,:,0] = range(0, n)
        rht.rht(data=data, indexes=indexes[i], start=0, end=n-1, nd=0, H=h)

    return indexes
