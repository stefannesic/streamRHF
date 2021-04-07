from my_imports import np, constants, dataset
from libc.math cimport log

cpdef anomaly_score():
    cdef float p
    cdef int leaf_size, i, j
    cdef Py_ssize_t t = constants.T, n = constants.N
    cdef float[:] scores = np.zeros([n], np.float32)
    cdef int[:] elem

    for i in range (0, constants.T):
        for j in range(0, constants.N):
            elem = dataset.index[i][j]
            data_pointer = elem[0]
            leaf_size = elem[1]
            p = leaf_size / n
            scores[j] += log(1 / p)
    return scores

