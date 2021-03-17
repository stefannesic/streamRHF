from my_imports import np, ik
from libc.math cimport log

def same_values(float[:] arr):
    cdef float temp = arr[0]
    cdef Py_ssize_t i
    for i in range(1, arr.size):
        if arr[i] != temp:
            return False
    return True 

# sum of log(Kurtosis(X[a] + 1)) of attributes 0 to d inclusive
# when the function is used for insertions, insert_mode is True
def kurtosis_sum(float[:,:] X, moments, insert_mode=False):
    cdef bint samevals
    cdef int n_elems = X.shape[0]
    cdef float sum = 0.0
    cdef Py_ssize_t d = X.shape[1]
    cdef float[:] kurt = np.empty([d], np.float32)
    if (n_elems == 0):
        print("X is passed as empty")

    # loop over the transpose matrix in order to analyze by column
    for a in range(0, d):
        # if we're not in insertion mode, calculate if all of the values are the same
        if not(insert_mode):
            samevals = not(same_values(X[:,a]))
        else: 
            samevals = False
        
        # samevals is always false in insert_mode so only the second part matters 
        if (samevals or (insert_mode and (moments[a][5] == 0 or moments[a][0] != X))):
            kurt[a], moments[a] = ik.incr_kurtosis(X[:,a], moments[a])
            kurt[a] = log(kurt[a] + 1)
            sum += kurt[a]
        else:
            if not(insert_mode):
                # label the column as having same values for future incr. checking
                moments[a][5] = 1
            kurt[a] = 0
            # increase number of elements
            moments[a][4] += 1
           
    return sum, kurt, moments
