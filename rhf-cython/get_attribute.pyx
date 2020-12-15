from my_imports import np, ks_cy, random, Node, Leaf

# use kurtosis sum to get best attribute for the split
# returns attribute, its column and a random split value
cpdef get_attribute(float[:,:] X, float r):
    cdef int end = X.shape[1]
    cdef float[:] a_col
    cdef float a_val, a_min, a_max
    for a in range(0,end):
        if ks_cy.kurtosis_sum(X, a) > r:
            a_col = X[:, a]

            # ensures that the split will be proper (no split on extremes)
            a_min = np.amin(a_col)
            a_max = np.amax(a_col)
            a_val = a_min

            if a_val != a_max:
                while a_val == a_min or a_val == a_max:
                    a_val = random.uniform(a_min, a_max)
            
                return a, a_col, a_val
