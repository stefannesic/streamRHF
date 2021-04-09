from my_imports import np, ik
from libc.math cimport log


def kurtosis_sum(float[:,:] data, int[:,:] indexes, int start, int end):
    cdef Py_ssize_t d = data.shape[1]
    cdef int a
    cdef kurt = np.empty([d], np.float32)
    cdef float ks = 0
    for a in range(0, d):
        kurt[a] = ik.incr_kurtosis(data, indexes, start, end, a)
        kurt[a] = log(kurt[a] + 1)
        ks += kurt[a]
    # used to be np.asarray(kurt)
    return ks, kurt
