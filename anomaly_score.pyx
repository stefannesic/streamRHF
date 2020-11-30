def anomaly_score(rhf, int n, int x):
    sum = 0
    
    for i in range(0, rhf.size):
        # number of distinct instances in the leaf of the given instance
        leaf_size = find_instance(rhf[i], x).data.size
        p = leaf_size / n
        sum += np.log(1 / p)
        
    return sum
