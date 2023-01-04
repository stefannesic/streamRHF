from my_imports import np, sstats
# sum of log(Kurtosis(X[a] + 1)) of attributes 0 to d inclusive
def kurtosis_sum(X, d):
    sum = 0
    
    # loop over the transpose matrix in order to analyze by column
    for a in range(0, d+1):
        # + 4 since the scipy function for kurtosis subtracts 3 so +1 +3 = 4
        sum += np.log(sstats.stats.kurtosis(X[:,a])+4)
        
    return sum
