from my_imports import np, rht, Node

# construction of a random histogram forest
cpdef rhf(X, int t, int h):
    # set max tree height
    Node.H = h
    
    # create an empty forest
    rhf = np.empty([t], dtype=object)

    cdef float[:,:] moments = np.zeros([X.shape[1], 5], dtype=np.float32)
    # append t random histogram trees
    for i in range(t):
        rhf[i] = rht.rht(np.arange(0, X.shape[0]), 0, moments)

    return rhf
