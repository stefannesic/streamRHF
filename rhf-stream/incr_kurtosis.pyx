from my_imports import np
cpdef incr_kurtosis(float[:,:] data, int[:,:] indexes, int start, int end, int a):
    cdef float mean, M2, M3, M4, n, delta, delta_n, delta_n2, term1, n1, kurtosis, x
    # check if calculating from scratch
    n, mean, M2, M3, M4 = (0, 0, 0, 0, 0)
    # for loop for when moments are initialized on multiple elements
    for i in range(start, end):
        x = data[indexes[i][0]][a]
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
        
    if M4 == 0: 
        return 0
    else:
        kurtosis = (n * M4) / (M2 * M2)
        return kurtosis
