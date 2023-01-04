def online_kurtosis(data):
    n, mean, M2, M3, M4 = (0, 0, 0, 0, 0)

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
        # Note, you may also calculate variance using M2, and skewness using M3
        # Caution: If all the inputs are the same, M2 will be 0, resulting in a division by 0.
        kurtosis = (n * M4) / (M2 * M2)
        return kurtosis
