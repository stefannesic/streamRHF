from my_imports import np, rht, Node

# construction of a random histogram forest
cpdef rhf(X, int t, int h):
    # set max tree height
    Node.H = h
    # create an empty forest
    rhf = np.empty([t], dtype=object)

    # append t random histogram trees
    for i in range(t):
        rhf[i] = rht.rht(X, 0)

    return rhf
