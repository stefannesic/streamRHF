from my_imports import np, Node, ks_cy, ga, random

cdef float eps = 0.001

# Construction of a random histogram tree
def rht(X, int nd, float[:,:] moments):
    cdef float r, ks, a_val
    cdef int a
    cdef float[:] kurt

    # last condition checks if all instances are the same --> Leaf
    if nd >= Node.H or np.all(X[0] == X):
        # unique instances
        X_unique = np.unique(np.asarray(X), axis=0)
        # returns instances without duplicates

        # if leaf is at max depth no use in storing moments
        if nd >= Node.H:
            return Node.Node(nd=nd, data=X_unique)
        else:
            return Node.Node(nd=nd, data=X_unique, moments=moments)
    else:
        # attribute selected according to kurtosis
        ks, kurt, moments = ks_cy.kurtosis_sum(X, X.shape[1]-1, moments)
        
        # ks may not be included depending on rounding
        r = random.uniform(0, ks)
        a, a_col, a_val = ga.get_attribute(X, kurt, r)

        #print("r=", r)
        #print("kurt=", np.asarray(kurt))
        #print("a=", a)
        #print("a_val=", a_val)
        
        
        Xl = X[X[:, a] < a_val]
        Xr = X[X[:, a] >= a_val]

        moments0 = np.zeros([X.shape[1], 5], dtype=np.float32)
        
        # moments are stored in Node but not passed in next calls to rht
        # since there is only incr kurtosis, each Node starts kurtosis calculation from scratch
        Xl = rht(Xl, nd + 1, moments0)
        Xr = rht(Xr, nd + 1, moments0)

        return Node.Node(a_val, a, Xl, Xr, nd, X, moments, ks, kurt)

