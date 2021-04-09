from my_imports import np
from libc.math cimport log

cpdef anomaly_score(int[:,:,:] indexes, t):
    cdef float p
    cdef int leaf_size, i, j
    cdef int n = indexes.shape[1]
    cdef float[:] scores = np.zeros([n], np.float32)
    cdef int[:] elem

    for i in range (0, t):
        for j in range(0, n):
            elem = indexes[i][j]
            data_pointer = elem[0]
            leaf_size = elem[1]
            p = leaf_size / n
            scores[j] += log(1/p)
    return scores

