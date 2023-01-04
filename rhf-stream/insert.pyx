from my_imports import np, rht, ks_cy, time
from libc.math cimport log
# inserts new data point in leaf
cpdef void insert(float[:,:] data, float[:,:,:] moments, split_info, int H, insertionDS, int i):
    # analyze non leaf node until x is inserted
    # if a non leaf node kurtosis changes, recalculate split
    # start at root node
    cdef int nodeID = 0, a, split_a, leaf_index, counter, nd = 0, d = data.shape[1], ks = 0
    cdef float split_a_val, old_kurtosis_sum, new_kurtosis_sum
    cdef float[:] old_kurtosis_vals
    cdef float[:] new_kurtosis_vals = np.empty([d], np.float32)
    cdef float[:,:] moments_calc
    cdef float[:] M2, M3, M4, n
    # while leaf node isn't reached
    while nodeID < (2**H)-1 and split_info.splits[nodeID] != 0:
        split_a = split_info.attributes[nodeID]
        split_a_val = split_info.values[nodeID]
        # calculate new kurtosis
         
        old_kurtosis_vals = split_info.kurtosis_vals[nodeID]
        old_kurtosis_sum = split_info.kurtosis_sum[nodeID]
        kurtosis_sum_ids(data, moments[nodeID], i) 
        moments_calc = moments[nodeID] 
        M2 = moments_calc[:,1]
        M3 = moments_calc[:,2]
        M4 = moments_calc[:,3]
        n = moments_calc[:,4]
        for a in range(0,d):
            if M4[a] == 0:
                new_kurtosis_vals[a] = 0
            else:
                new_kurtosis_vals[a] = (n[a] * M4[a]) / M2[a] * M2[a]
                new_kurtosis_vals[a] = log(new_kurtosis_vals[a] + 1)
            new_kurtosis_sum += new_kurtosis_vals[a]
        
        # analyze kurtosis for rebuild
        # TODO
        
        if data[i][split_a] <= split_a_val:
            nodeID = nodeID*2 + 1
        else:
            nodeID = nodeID*2 + 2

        # increase node depth
        nd += 1

    # insert leaf
        
    # calculate index for insertionDS
    if nodeID >= (2**H - 1) : # leaf is at max depth
        leaf_index = nodeID
    else:
        leaf_index = (2**(H - nd))*(nodeID + 1) - 1
    
    # at this point, leaf_index is a leaf nodeID and needs to be adjusted for indexing in insertionDS
    leaf_index = leaf_index - ((2**H) - 1)
    
    counter = insertionDS.counters[leaf_index]
    insertionDS.table[leaf_index][counter] = i
    insertionDS.counters[leaf_index] += 1
    

cdef void kurtosis_sum_ids(float[:,:] data, float[:,:] moments, int i):
    cdef Py_ssize_t d = data.shape[1]
    cdef int a
    cdef float[:] moments_res
    cdef float ks = 0
    
    cdef float mean, M2, M3, M4, n, delta, delta_n, delta_n2, term1, n1, kurtosis, x
    
    for a in range(0, d): 
        mean = moments[a][0]
        M2 = moments[a][1]
        M3 = moments[a][2]
        M4 = moments[a][3]
        n = moments[a][4]
        
        x = data[i][a]
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
        
        moments[a][0] = mean
        moments[a][1] = M2
        moments[a][2] = M3
        moments[a][3] = M4
        moments[a][4] = n
              
       
