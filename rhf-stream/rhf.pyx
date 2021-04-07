from my_imports import np, rht, constants, dataset

# construction of a random histogram forest
cpdef rhf():
    cdef int t = constants.T, n = constants.N 
    # create an empty forest of t trees each with n x 3 
    # 2 = (index in X, number of elems in leaf)
    dataset.index = np.empty([t, n, 2], dtype=np.intc)

    # calculate t trees in global index variable
    for i in range(t):
        # intialize dataset.index
        dataset.index[i,:,0] = range(0, n)
        rht.rht(tree=i, start=0, end=n-1, nd=0)

