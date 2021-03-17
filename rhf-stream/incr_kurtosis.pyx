from my_imports import np
cpdef incr_kurtosis(float[:] data, float[:] moments):
    cdef float mean, M2, M3, M4, n, delta, delta_n, delta_n2, term1, n1, kurtosis 
    # check if calculating from scratch
    if moments[4] != 0:
        mean = moments[0]
        M2 = moments[1]
        M3 = moments[2]
        M4 = moments[3]
        n = moments[4]
    else:   
        n, mean, M2, M3, M4 = (0, 0, 0, 0, 0)
        moments = np.empty([5], dtype=np.float32)

    # for loop for when moments are initialized on multiple elements
    for x in data:
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

    moments[0] = mean
    moments[1] = M2
    moments[2] = M3
    moments[3] = M4
    moments[4] = n
        
    if M4 == 0: 
        return 0, moments
    else:
        kurtosis = (n * M4) / (M2 * M2)
        return kurtosis, moments
