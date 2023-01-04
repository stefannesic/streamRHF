cpdef online_kurtosis(float [:] data):
    cdef int n = 0, n1
    cdef float mean = 0
    cdef float M2 = 0
    cdef float M3 = 0
    cdef float M4 = 0
    cdef float kurtosis, delta, delta_n, delta_n2, term1,  
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

    if M4 == 0: 
        return 0
    else:
        kurtosis = (n * M4) / (M2 * M2)
        return kurtosis
