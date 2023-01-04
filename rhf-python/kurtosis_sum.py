from my_imports import np, sstats
# sum of log(Kurtosis(X[a] + 1)) of attributes 0 to d inclusive
def kurtosis_sum(X, d):
    sum = 0
    
    # loop over the transpose matrix in order to analyze by column
    for a in range(0, d+1):
        if (np.min(X[:,a]) != np.max(X[:,a])):
            sum += np.log(sstats.stats.kurtosis(X[:,a], fisher=False)+1)
        
    return sum
