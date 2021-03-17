from my_imports import np, Node, ks_cy, ga, random

# Construction of a random histogram tree
def rht(X, int nd, float[:,:] moments):
    cdef float r, ks, a_val
    cdef int a
    cdef float[:] kurt

    # last condition checks if all instances are the same --> Leaf
    if nd >= Node.H or X.shape[0] == 1:
        # if leaf is at max depth no use in storing moments
        return Node.Node(nd=nd, data=np.asarray(X))
    else:
        # attribute selected according to kurtosis
        X_values = Node.data_complete[X]
    
        ks, kurt, moments_after = ks_cy.kurtosis_sum(X_values, moments)
      
        # if all instances are the same 
        if ks == 0:
            return Node.Node(nd=nd, data=np.asarray(X), moments=moments)

        # only update the moments if not leaf
        moments = moments_after
 
        # ks may not be included depending on rounding
        r = random.uniform(0, ks)
        a, a_col, a_val = ga.get_attribute(X, kurt, r)

        Xl = X[X_values[:, a] < a_val]
        Xr = X[X_values[:, a] >= a_val]
        
        if (Xl.size == 0 or Xr.size == 0):
            print("Xl=", Xl)
            print("Xr=", Xr)
            print("X=", X)
            print("a=", a)
            print("r=", r)
            print("a_val=", a_val)
            print("kurt(a)=", kurt[a])
            print("cumsum", np.cumsum(kurt))
            print("X_values[:, a]", X_values[:, a])

        moments0 = np.zeros([X_values.shape[1], 6], dtype=np.float32)
        
        # moments are stored in Node but not passed in next calls to rht
        # since there is only incr kurtosis, each Node starts kurtosis calculation from scratch
        Xl = rht(Xl, nd + 1, moments0)
        Xr = rht(Xr, nd + 1, moments0)

        return Node.Node(a_val, a, Xl, Xr, nd, X, moments, ks, kurt)

