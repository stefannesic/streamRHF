from my_imports import np, ik

# sum of log(Kurtosis(X[a] + 1)) of attributes 0 to d inclusive
def kurtosis_sum(float[:,:] X, moments):
    cdef float sum = 0.0
    cdef Py_ssize_t d = X.shape[1]
    cdef float[:] kurt = np.empty([d], np.float32)
    # loop over the transpose matrix in order to analyze by column
    for a in range(0, d):
        try:
            if (np.max(X[:,a]) != np.min(X[:,a]) or X.shape[0] == 1):
                kurt[a], moments[a] = ik.incr_kurtosis(X[:,a], moments[a])
                kurt[a] = np.log(kurt[a] + 1)
                sum += kurt[a]
            else:
                kurt[a] = 0
        except:
            print("X=", np.asarray(X))
            print("a=", a)
            print("X(:,a)=", X[:,a])
            
    return sum, kurt, moments
