from my_imports import np
def decr_kurtosis(to_remove, moments):
    mean = moments[0]
    M2 = moments[1]
    M3 = moments[2]
    M4 = moments[3] 
    n = moments[4]
    print("to_remove=", np.asarray(to_remove))
    print("decrkurt before, moments=", moments)
    for x in to_remove:
        n1 = n
        n = n - 1
        delta = x - mean
        delta_n = delta/n
        delta_n2 = delta_n * delta_n
        term1 = delta * delta_n * n1
        mean = mean - delta_n
        M2 = M2 - term1
        M3 = M3 - term1 * delta_n * (n1 - 2) + 3 * delta_n * M2
        M4 = M4 - term1 * delta_n2 * (n1 * n1 - 3 * n1 + 3) - 6 * delta_n2 * M2 + 4 * delta_n * M3
    moments[0] = mean
    moments[1] = M2
    moments[2] = M3
    moments[3] = M4
    moments[4] = n

    print("decrkurt after, moments=", moments)       
    if M4 == 0: 
        return 0, moments
    else:
        kurtosis = (n * M4) / (M2 * M2)
        return kurtosis, moments
