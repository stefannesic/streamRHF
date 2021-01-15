from my_imports import np, sstats 

# sum of log(Kurtosis(X[a] + 1)) of attributes 0 to d inclusive
def kurtosis_sum(float[:,:] X, Py_ssize_t d):
    cdef float sum = 0.0
    cdef float[:] kurt = np.empty([d+1], np.float32)
    # loop over the transpose matrix in order to analyze by column
    for a in range(0, d+1):
        if (np.max(X[:,a]) != np.min(X[:,a])):
            kurt[a] = np.log(sstats.stats.kurtosis(X[:,a], fisher=False) + 1)
            sum += kurt[a]
        else:
            kurt[a] = 0
    return sum, kurt
