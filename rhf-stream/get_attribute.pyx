from my_imports import np, ks_cy, random, Node

# use kurtosis sum to get best attribute for the split
# returns attribute, its column and a random split value
cpdef get_attribute(float[:,:] X, float[:] kurt, float r):
    cdef int end = X.shape[1]
    cdef float[:] a_col
    cdef float a_val, a_min, a_max
    cdef Py_ssize_t a  
    kurt = np.cumsum(kurt)
   
    # the attribute is found in the bins of the cumulative sum of kurtoses 
    a = np.digitize(r, kurt) 
    a_col = X[:, a]

    # ensures that the split will be proper (no split on extremes)
    a_min = np.amin(a_col)
    a_max = np.amax(a_col)
    a_val = a_min

    if a_val != a_max:
        while a_val == a_min or a_val == a_max:
            a_val = random.uniform(a_min, a_max)
    
        return a, a_col, a_val
