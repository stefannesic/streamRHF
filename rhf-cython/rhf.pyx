from my_imports import np, rht

# construction of a random histogram forest
cpdef rhf(X, int t, int nd, int h):
    # create an empty forest
    rhf = np.empty([t], dtype=object)

    # append t random histogram trees
    for i in range(t):
        rhf[i] = rht.rht(X, nd, h)

    return rhf
