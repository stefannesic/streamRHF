from my_imports import fi, np
from libc.math cimport log

cpdef anomaly_score(rhf, int n, int x, float[:] x_value):
    cdef float sum = 0.0
    cdef int leaf_size
    cdef float p
    cdef Py_ssize_t tsize = rhf.size 
    
    for i in range(0, tsize):
        #print("as, i=", i)
        # number of distinct instances in the leaf of the given instance
        leaf_size = fi.find_instance(rhf[i], x, x_value)
        p = leaf_size / n
        sum += log(1 / p)
    return sum
