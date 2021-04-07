from my_imports import np, ik, constants
from libc.math cimport log


def kurtosis_sum(int tree, int start, int end):
    cdef Py_ssize_t d = constants.D
    cdef int a
    cdef float[:] moments, kurt = np.empty([d], np.float32)
    cdef float ks = 0
    for a in range(0, d):
        kurt[a], moments = ik.incr_kurtosis(tree, start, end, a, constants.moments)
        kurt[a] = log(kurt[a] + 1)
        ks += kurt[a]
    return ks, np.asarray(kurt) 
