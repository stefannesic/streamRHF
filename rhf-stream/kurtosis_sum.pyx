from my_imports import np, ik
from libc.math cimport log

def same_values(float[:] arr):
    cdef float temp = arr[0]
    for i in range(1, arr.size):
        if arr[i] != temp:
            return False
    return True 

# sum of log(Kurtosis(X[a] + 1)) of attributes 0 to d inclusive
def kurtosis_sum(float[:,:] X, moments):
    if (np.asarray(X).size == 0):
        print("X is passed as empty")
    cdef float sum = 0.0
    cdef Py_ssize_t d = X.shape[1]
    cdef float[:] kurt = np.empty([d], np.float32)

    cdef int X_shape = X.shape[0]
    # loop over the transpose matrix in order to analyze by column
    for a in range(0, d):
        try:
            if (not(same_values(X[:,a])) or X_shape == 1):
                kurt[a], moments[a] = ik.incr_kurtosis(X[:,a], moments[a])
                kurt[a] = log(kurt[a] + 1)
                sum += kurt[a]
            else:
                kurt[a] = 0
        except:
            print("X=", np.asarray(X))
            print("a=", a)
            print("X(:,a)=", np.asarray(X[:,a]))
            
    return sum, kurt, moments
