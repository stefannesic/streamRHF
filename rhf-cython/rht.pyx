from my_imports import np, ks_cy, random, ga, Node, Leaf

# Construction of a random histogram tree
cpdef rht(X, int nd, int h):
    cdef float r, ks, a_val
    cdef int a
    # unique instances
    X_unique = np.unique(np.asarray(X), axis=0)
    # last condition checks if all instances are the same --> split not possible
    if nd >= h or X_unique.shape[0] == 1:
        # returns instances without duplicates
        return Leaf.Leaf(X_unique)
    else:
        # attribute selected according to kurtosis
        ks = ks_cy.kurtosis_sum(X, X.shape[1]-1)
   
        # ks may not be included depending on rounding
        r = random.uniform(0, ks)
        a, a_col, a_val = ga.get_attribute(X, r)
        
        Xl = X[X[:, a] < a_val]
        Xr = X[X[:, a] >= a_val]
        
        Xl = rht(Xl, nd + 1, h)
        Xr = rht(Xr, nd + 1, h)

        return Node.Node(a_val, a, Xl, Xr)
