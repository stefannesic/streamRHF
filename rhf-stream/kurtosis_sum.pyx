from my_imports import np, ik

# sum of log(Kurtosis(X[a] + 1)) of attributes 0 to d inclusive
def kurtosis_sum(float[:,:] X, Py_ssize_t d, moments):
    cdef float sum = 0.0
    cdef float[:] kurt = np.empty([d+1], np.float32)
    # loop over the transpose matrix in order to analyze by column
    for a in range(0, d+1):
        if (np.max(X[:,a]) != np.min(X[:,a]) or X.shape[0] == 1):
            kurt[a], moments[a] = ik.incr_kurtosis(X[:,a], moments[a])
            kurt[a] = np.log(kurt[a] + 1)
            sum += kurt[a]
        else:
            kurt[a] = 0
    return sum, kurt, moments
