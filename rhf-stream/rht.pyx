from my_imports import np, Node, ks_cy, ga, random

cdef float eps = 0.001

# Construction of a random histogram tree
def rht(X, int nd):
    cdef float r, ks, a_val
    cdef int a
    # last condition checks if all instances are the same --> Leaf
    if nd >= Node.H or np.all(X[0] == X):
        # unique instances
        X_unique = np.unique(np.asarray(X), axis=0)
        # returns instances without duplicates
        return Node.Node(nd=nd, data=X_unique)
    else:
        # attribute selected according to kurtosis
        ks, kurt = ks_cy.kurtosis_sum(X, X.shape[1]-1)

        # ks may not be included depending on rounding
        r = random.uniform(0, ks)
        a, a_col, a_val = ga.get_attribute(X, r)
        
        Xl = X[X[:, a] < a_val]
        Xr = X[X[:, a] >= a_val]
        
        Xl = rht(Xl, nd + 1)
        Xr = rht(Xr, nd + 1)

        return Node.Node(a_val, a, Xl, Xr, nd, X, ks, kurt)

