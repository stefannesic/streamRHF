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
    
    cdef float mean, M2, M3, M4, n, delta, delta_n, delta_n2, term1, n1, kurtosis, x
    #kurt, moments = ik.incr_kurtosis_ids2(data, moments, i) 
    #ks = np.sum(moments)
    
    for a in range(0, d): 
        #kurt[a] = 0.5
        #kurt[a], moments_res = ik.incr_kurtosis_ids(data, moments[a], i, a)
        #kurt[a] = ik.incr_kurtosis_ids(data, moments[a], i, a)
        #moments[a] = moments_res    

         
        mean = moments[a][0]
        M2 = moments[a][1]
        M3 = moments[a][2]
        M4 = moments[a][3]
        n = moments[a][4]
        
        x = data[i][a]

        
        n1 = n
        n = n + 1
        delta = x - mean
        delta_n = delta / n
        delta_n2 = delta_n * delta_n 
        term1 = delta * delta_n * n1
        mean = mean + delta_n
        M4 = M4 + term1 * delta_n2 * (n*n - 3*n + 3) + 6 * delta_n2 * M2 - 4 * delta_n * M3
        M3 = M3 + term1 * delta_n * (n - 2) - 3 * delta_n * M2
        M2 = M2 + term1

        moments[a][0] = mean
        moments[a][1] = M2
        moments[a][2] = M3
        moments[a][3] = M4
        moments[a][4] = n
        
        if M4 == 0: 
            kurt[a] = 0
        else:
            kurt[a] = (n * M4) / (M2 * M2)
   
    kurt = np.log(kurt + 1) 
    ks = np.sum(kurt)
    
    return ks, kurt, moments
