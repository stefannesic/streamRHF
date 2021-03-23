from my_imports import np, ik, time, Node
from libc.math cimport log

def same_values(float[:] arr):
    cdef float temp = arr[0]
    cdef Py_ssize_t i
    for i in range(1, arr.size):
        if arr[i] != temp:
            return False
    return True 

# msum of log(Kurtosis(X[a] + 1)) of attributes 0 to d inclusive
# when the function is used for insertions, insert_mode is True
def kurtosis_sum(float[:,:] X, moments, bint insert_mode=False):
    t0 = time.time()
    cdef bint samevals
    cdef int n_elems = X.shape[0]
    cdef float summ = 0.0
    cdef Py_ssize_t d = X.shape[1]
    cdef int a
    cdef float[:] kurt = np.empty([d], np.float32)
    cdef float[:] simpleX
    if insert_mode:
        X_0 = X[0]
    if (n_elems == 0):
        print("X is passed as empty")
    t1 = time.time()
    Node.ksstats[0] += (t1 - t0)

    t2 = time.time()
    # loop over the transpose matrix in order to analyze by column
    for a in range(0, d):
        t2b = time.time()
        # if we're not in insertion mode, calculate if all of the values are the same
        if not(insert_mode):
            samevals = not(same_values(X[:,a]))
        else: 
            samevals = False
        
        t2c = time.time()
        Node.ksstats[1] += (t2c - t2b)
        
        # samevals is always false in insert_mode so only the second part matters 
        if (samevals or (insert_mode and (moments[a][5] == 0 or moments[a][0] != X_0[a]))):
            t2d = time.time() 
            Node.ksstats[2] += (t2d - t2c)
            kurt[a], moments[a] = ik.incr_kurtosis(X[:,a], moments[a])
            kurt[a] = log(kurt[a] + 1)
            summ += kurt[a]
            t2e = time.time()
            Node.ksstats[3] += (t2e - t2d)            
        else:
            t2d = time.time()
            Node.ksstats[2] += (t2d - t2c)
            if not(insert_mode):
                # label the column as having same values for future incr. checking
                moments[a][5] = 1
            kurt[a] = 0
            # increase number of elements
            moments[a][4] += 1
    t3 = time.time()
    Node.ksstats[4] += (t3 - t2)  
    return summ, kurt, moments
