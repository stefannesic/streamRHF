from my_imports import np, ik
from libc.math cimport log


def kurtosis_sum(float[:,:] data, int[:,:] indexes, float[:,:] moments, int start, int end):
    cdef Py_ssize_t d = data.shape[1]
    cdef int a
    cdef kurt = np.empty([d], np.float32)
    cdef float[:] moments_res
    cdef float ks = 0
    for a in range(0, d): 
        kurt[a], moments_res = ik.incr_kurtosis(data, indexes, moments[a], start, end, a)
        moments[a] = moments_res
        kurt[a] = log(kurt[a] + 1)
        ks += kurt[a]
    # used to be np.asarray(kurt)
    return ks, kurt, moments

def kurtosis_sum_ids(float[:,:] data, float[:,:] moments, int i):
    cdef Py_ssize_t d = data.shape[1]
    cdef int a
    cdef kurt = np.empty([d], np.float32)
    cdef float[:] moments_res
    cdef float ks = 0
    
    #kurt, moments = ik.incr_kurtosis_ids2(data, moments, i) 
    #ks = np.sum(moments)
    
    for a in range(0, d): 
        kurt[a], moments_res = ik.incr_kurtosis_ids(data, moments[a], i, a)
        moments[a] = moments_res
        kurt[a] = log(kurt[a] + 1)
        ks += kurt[a]
    
    return ks, kurt, moments
