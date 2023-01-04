from my_imports import np, rht, Node, rhts

# construction of a random histogram forest
cpdef rhf_stream(X, int t, int h, int n, float eps):
    # set max tree height
    Node.H = h
    print("rhfs, Node.H=", Node.H)
    rht.eps = eps
    # create an empty forest
    rhf = np.empty([t], dtype=object)

    # append t random histogram trees
    for i in range(t):
        print("i=", i)
        rhf[i] = rhts.rht_stream(X, n)

    return rhf
