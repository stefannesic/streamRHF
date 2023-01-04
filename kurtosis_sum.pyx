import scipy.io as sio
import scipy.stats as sstats
import random 
import numpy as np

# sum of log(Kurtosis(X[a] + 1)) of attributes 0 to d inclusive
cdef float kurtosis_sum2(float[:,:] X, Py_ssize_t d):
	cdef float sum = 0.0
	
	# loop over the transpose matrix in order to analyze by column
	for a in range(0, d+1):
		# + 4 since the scipy function for kurtosis subtracts 3 so +1 +3 = 4
		sum += np.log(sstats.stats.kurtosis(X[:,a])+4)

	return sum
