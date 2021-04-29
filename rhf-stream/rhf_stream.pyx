from my_imports import np, ga, random, time, ks_cy, split, leaves
from libc.math cimport log

# construction of a random histogram forest
cpdef rhf_stream(float[:,:] data, int t, int h, int N_init_pts):
    cdef int n = data.shape[0], d = data.shape[1]
    cdef int W_MAX = n
    # create an empty forest of t trees each with n x 3 
    # 2 = (index in X, number of elems in leaf)
    indexes = np.empty([t, N_init_pts, 2], dtype=np.intc)
    # moments = trees * nodes * attributes * card({M1, M2, M3, M4, n})
    moments = np.zeros([t, (2**h)-1, d, 5], dtype=np.float32)
    splits = np.empty([t], dtype=object)
    # create secondary data structure for insertion algorithm
    insertionDS = np.empty([t], dtype=object)
    # calculate t trees in global index variable
    for i in range(t):
        print("i=", i)
        # intialize dataset.index
        indexes[i,:,0] = range(0, N_init_pts)
        splits[i] = split.Split(h, d)
        insertionDS[i] = leaves.Leaves(h, W_MAX)
        rht_stream(data=data, indexes=indexes[i], insertionDS=insertionDS[i], split_info=splits[i], moments=moments[i], H=h, N_init_pts=N_init_pts) 
           
    return insertionDS


from my_imports import np, ga, random, time, ks_cy, split, leaves

cdef void rht_stream(float[:,:] data, int[:,:] indexes, insertionDS, split_info, float[:,:, :] moments, int H, int N_init_pts):
    cdef int i, N = data.shape[0]
    # simulating real-time (except trees constructed one by one) 
    # construct initial tree with batch algorithm on the first N points
    cdef int n = data.shape[0]
    rht(data, indexes, insertionDS, split_info, moments, start=0, end=N_init_pts-1, nd=0, H=H, nodeID=0) 
    print("Initial tree constructed.")   
    t0 = time.time()
    # update existing tree
    for i in range(N_init_pts, N):
        insert(data, moments, split_info, H, insertionDS, i)
 
    t1 = time.time() 

    print("Total time for insertions=", t1 - t0)

# sort indexes according to split
cdef int sort(float[:,:] data, int[:,:] indexes, int start, int end, int a, float a_val):
    cdef int i, j, temp
    # quicksort Hoare partition scheme
    i = start
    j = end
    while i < j:
        while data[indexes[i][0]][a] <= a_val and i < j: 
            i = i + 1
        while data[indexes[j][0]][a] > a_val and j > i:
            j = j - 1
        temp = indexes[i][0]
        indexes[i][0] = indexes[j][0]
        indexes[j][0] = temp
    return j
         
cdef void rht(float[:,:] data, int[:,:] indexes, insertionDS, split_info, float[:,:,:] moments, int start, int end, int nd, int H, int nodeID=0):
    cdef int ls, a, split
    cdef float ks, a_val 
    cdef float[:] kurt
    cdef float[:,:] moments_res
    if (end == start or nd >= H):
        # leaf size
        fill_leaf(indexes, insertionDS, nodeID, nd, H, start, end) 
    else:
        # calculate kurtosis
        ks, kurt, moments_res = ks_cy.kurtosis_sum(data, indexes, moments[nodeID], start, end)
        moments[nodeID] = moments_res
        if (ks == 0): # stop if all elems are the same
            fill_leaf(indexes, insertionDS, nodeID, nd, H, start, end, 1) 

        else: # split
            a, a_val = ga.get_attribute(data, indexes, start, end, ks, kurt)
            # sort indexes
            split = sort(data, indexes, start, end, a, a_val)

            # store split info
            split_info.splits[nodeID] = split
            split_info.attributes[nodeID] = a
            split_info.values[nodeID] = a_val
            split_info.kurtosis_vals[nodeID] = kurt
            split_info.kurtosis_sum[nodeID] = ks
            rht(data, indexes, insertionDS, split_info, moments, start, split-1, nd+1, H, nodeID=2*nodeID+1)
            rht(data, indexes, insertionDS, split_info, moments, split, end, nd+1, H, nodeID=2*nodeID+2)
           
cdef void fill_leaf(int[:,:] indexes, insertionDS, int nodeID, int nd, int H, int start, int end, int ls = 0):
    cdef int i, leaf_index
    # leaf size is not set, calculate it.
    if ls == 0:
        ls = end - start + 1

    # calculate index of insertionDS
    if nodeID >= (2**H - 1) : # leaf is at max depth
        leaf_index = nodeID
    else:
        leaf_index = (2**(H - nd))*(nodeID + 1) - 1
    
    # at this point, leaf_index is nodeID and needs to be adjusted for indexing
    leaf_index = leaf_index - ((2**H) - 1)

    for i in range(start, end+1):  
        # store leaf in insertion DS
        # fetch counter
        counter = insertionDS.counters[leaf_index]
        # get the actual pointer to the dataset indexes[k][0]
        insertionDS.table[leaf_index][counter] = indexes[i][0]
        # increment counter
        insertionDS.counters[leaf_index] += 1

        indexes[i][1] = ls

# inserts new data point in leaf
cdef void insert(float[:,:] data, float[:,:,:] moments, split_info, int H, insertionDS, int i):
    
    # analyze non leaf node until x is inserted
    # if a non leaf node kurtosis changes, recalculate split
    # start at root node
    cdef int nodeID = 0, a, split_a, leaf_index, counter, nd = 0, d = data.shape[1], ks = 0
    
    cdef float split_a_val, old_kurtosis_sum, new_kurtosis_sum
    cdef float[:] old_kurtosis_vals
    # THE NP.EMPTY GETS TIME FROM 0.0000001 VS. 0.03
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
              
       
