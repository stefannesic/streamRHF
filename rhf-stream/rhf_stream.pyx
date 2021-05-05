from my_imports import np, random, time
from libc.math cimport log

cdef class Split:
    cdef int[:,:] splits
    cdef int[:,:] attributes
    cdef float[:,:] values
    cdef float[:,:,:] kurtosis_vals
    cdef float[:,:] kurtosis_sum
    def __init__(self, int t, int h, int d):
        self.splits = np.zeros([t,(2**h)-1], np.intc)
        self.attributes = np.empty([t,(2**h)-1], np.intc)
        self.values = np.empty([t,(2**h)-1], np.float32)
        self.kurtosis_vals = np.empty([t,(2**h)-1, d], np.float32)
        self.kurtosis_sum = np.empty([t,(2**h)-1], np.float32)

cdef class Leaves:
    cdef int[:,:] counters
    cdef int[:,:,:] table
    def __init__(self, int t, int H, int W_MAX):
        self.counters = np.zeros([t,2**H], dtype=np.intc)
        # 2**H = max number of leaves, W_MAX = max number of elements per leaf
        # all set to -1
        self.table = np.zeros([t,2**H, W_MAX], dtype=np.intc) - 1

# anomaly score for insertion data structure)
cpdef anomaly_score_ids(Leaves insertionDS, Py_ssize_t t, int n):
    cdef float score
    cdef int i, j, data_pointer
    cdef Py_ssize_t ids_size, leaf_size
    cdef float[:] scores = np.zeros([n], np.float32)
    
    # get table size, it's the same for all trees
    ids_size = insertionDS.table[0].shape[0] 
        
    for i in range (0, t): 
       for j in range(0, ids_size):
            # get leaf_size and calculate score
            leaf_size = insertionDS.counters[i][j]
            if (leaf_size != 0):
                score = leaf_size / n
                score = log(1/leaf_size)
                for k in range(0, leaf_size):
                    data_pointer = insertionDS.table[i][j][k]
                    scores[data_pointer] += score
    return scores

 
# construction of a random histogram forest
cpdef rhf_stream(float[:,:] data, int t, int h, int N_init_pts):
    cdef int n = data.shape[0], d = data.shape[1]
    cdef int W_MAX = n

    # create an empty forest of t trees each with n x 3 
    # 2 = (index in X, number of elems in leaf)
    indexes = np.empty([t, N_init_pts, 2], dtype=np.intc)
    # moments = trees * nodes * attributes * card({M1, M2, M3, M4, n})
    moments = np.zeros([t, (2**h)-1, d, 6], dtype=np.float32)
    cdef Split splits = Split(t, h, d)
    # create secondary data structure for insertion algorithm
    cdef Leaves insertionDS = Leaves(t, h, W_MAX)
    cdef float[:] kurtosis_arr = np.empty([d], np.float32)
    # calculate t trees in global index variable
    for i in range(t):
        print("i=", i)
        # intialize dataset.index
        indexes[i,:,0] = range(0, N_init_pts)
        #insertionDS[i] = leaves.Leaves(h, W_MAX)
        rht_stream(data=data, indexes=indexes[i], insertionDS=insertionDS, split_info=splits, moments=moments[i], kurtosis_arr=kurtosis_arr, H=h, N_init_pts=N_init_pts, t_id=i) 
           
    return insertionDS


from my_imports import np, ga, random, time, ks_cy, split, leaves

cdef void rht_stream(float[:,:] data, int[:,:] indexes, Leaves insertionDS, Split split_info, float[:,:, :] moments, float[:] kurtosis_arr, int H, int N_init_pts, int t_id):
    cdef int i, N = data.shape[0]
    # simulating real-time (except trees constructed one by one) 
    # construct initial tree with batch algorithm on the first N points
    cdef int d = data.shape[1]
    rht(data, indexes, insertionDS, split_info, moments, kurtosis_arr, start=0, end=N_init_pts-1, nd=0, H=H, nodeID=0, t_id=t_id) 
    print("Initial tree constructed.")   
    t0 = time.time()
    # update existing tree
 
    for i in range(N_init_pts, N):
        insert(data, moments, split_info, H, insertionDS, kurtosis_arr, i, t_id)
    
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
         
cdef void rht(float[:,:] data, int[:,:] indexes, Leaves insertionDS, Split split_info, float[:,:,:] moments, float[:] kurtosis_arr, int start, int end, int nd, int H, int nodeID=0, int t_id=0):
    cdef int ls, a, split
    cdef float ks, a_val 
    cdef float[:,:] moments_res
    if (end == start or nd >= H):
        # leaf size
        fill_leaf(indexes, insertionDS, nodeID, nd, H, start, end, 0, t_id) 
    else:
        # calculate kurtosis
        ks = kurtosis_sum(data, indexes, moments[nodeID], kurtosis_arr, start, end)
        if (ks == 0): # stop if all elems are the same
            fill_leaf(indexes, insertionDS, nodeID, nd, H, start, end, 1, t_id) 

        else: # split
            a, a_val = get_attribute(data, indexes, start, end, ks, kurtosis_arr)
            # sort indexes
            split = sort(data, indexes, start, end, a, a_val)

            # store split info
            split_info.splits[t_id][nodeID] = split
            split_info.attributes[t_id][nodeID] = a
            split_info.values[t_id][nodeID] = a_val
            split_info.kurtosis_vals[t_id][nodeID] = kurtosis_arr
            split_info.kurtosis_sum[t_id][nodeID] = ks
            rht(data, indexes, insertionDS, split_info, moments, kurtosis_arr, start, split-1, nd+1, H, nodeID=2*nodeID+1, t_id=t_id)
            rht(data, indexes, insertionDS, split_info, moments, kurtosis_arr, split, end, nd+1, H, nodeID=2*nodeID+2, t_id=t_id)


cdef (int, float) get_attribute(float[:,:] data, int[:,:] indexes, int start, int end, float ks, float[:] kurt):
    cdef int a, i, data_index
    cdef float a_val, a_min, a_max, temp, r
    
    r = random.uniform(0, ks)
   
    kurt = np.cumsum(kurt)
    
    # the attribute is found in the bins of the cumulative sum of kurtoses 
    a = np.digitize(r, kurt, True)
    # get min and max
    data_index = indexes[start][0]
    a_min = data[data_index][a]
    a_max = a_min

    for i in range(start, end+1):
            temp = data[indexes[i][0]][a]
            if a_min > temp:
                a_min = temp
            elif a_max < temp:
                a_max = temp
    
    a_val = a_min
    
    while a_val == a_min or a_val == a_max:
        a_val = random.uniform(a_min, a_max)
    
    return a, a_val

cdef float kurtosis_sum(float[:,:] data, int[:,:] indexes, float[:,:] moments, float[:] kurtosis_arr, int start, int end):
    cdef Py_ssize_t d = data.shape[1]
    cdef int a
    cdef float ks = 0
    for a in range(0, d): 
        kurtosis_arr[a] = incr_kurtosis(data, indexes, moments[a], start, end, a)
        kurtosis_arr[a] = log(kurtosis_arr[a] + 1)
        ks += kurtosis_arr[a]
    return ks

cdef float incr_kurtosis(float[:,:] data, int[:,:] indexes, float[:] moments, int start, int end, int a):
    cdef float mean, M2, M3, M4, n, delta, delta_n, delta_n2, term1, n1, kurtosis, x
  
    n, mean, M2, M3, M4 = (0, 0, 0, 0, 0)
    #moments = np.empty([6], dtype=np.float32)

    # for loop for when moments are initialized on multiple elements
    for i in range(start, end+1):
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

    moments[0] = mean
    moments[1] = M2
    moments[2] = M3
    moments[3] = M4
    moments[4] = n
    
        
    if M4 == 0: 
        return 0
    else:
        kurtosis = (n * M4) / (M2 * M2)
        return kurtosis

          
cdef void fill_leaf(int[:,:] indexes, Leaves insertionDS, int nodeID, int nd, int H, int start, int end, int ls = 0, int t_id=0):
    cdef int i, leaf_index, counter
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
        counter = insertionDS.counters[t_id][leaf_index]
        # get the actual pointer to the dataset indexes[k][0]
        insertionDS.table[t_id][leaf_index][counter] = indexes[i][0]
        # increment counter
        insertionDS.counters[t_id][leaf_index] += 1

        indexes[i][1] = ls

# inserts new data point in leaf
cdef void insert(float[:,:] data, float[:,:,:] moments, Split split_info, int H, Leaves insertionDS, float[:] new_kurtosis_vals, int i, int t_id):
    # analyze non leaf node until x is inserted
    # if a non leaf node kurtosis changes, recalculate split
    # start at root node
    cdef int nodeID = 0, a, split_a, leaf_index, counter, nd = 0, d = data.shape[1], ks = 0
    cdef float split_a_val, old_kurtosis_sum, new_kurtosis_sum
    cdef float[:] old_kurtosis_vals
    cdef float[:] moments_calc
    #cdef float[:] new_kurtosis_vals
    cdef float M2, M4
    cdef int[:] split_attributes = split_info.attributes[t_id]
    cdef float[:] split_vals = split_info.values[t_id]
    cdef int[:] split_splits = split_info.splits[t_id]
    cdef float[:,:] split_kvals = split_info.kurtosis_vals[t_id]
    cdef float[:] split_ks = split_info.kurtosis_sum[t_id]
    # while leaf node isn't reached
     
    while nodeID < (2**H)-1 and split_splits[nodeID] != 0:      
        split_a = split_attributes[nodeID]
        split_a_val = split_vals[nodeID]
        
        # calculate new kurtosis
         
        old_kurtosis_vals = split_kvals[nodeID]
        old_kurtosis_sum = split_ks[nodeID]
        new_kurtosis_sum = kurtosis_sum_ids(data, moments[nodeID], new_kurtosis_vals, i) 
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
    
    counter = insertionDS.counters[t_id][leaf_index]
    insertionDS.table[t_id][leaf_index][counter] = i
    insertionDS.counters[t_id][leaf_index] += 1
    


cdef float kurtosis_sum_ids(float[:,:] data, float[:,:] moments, float[:] kurtosis_arr, int i):
    cdef Py_ssize_t d = data.shape[1]
    cdef int a
    cdef float mean, M2, M3, M4, n, delta, delta_n, delta_n2, term1, n1, x, kurtosis_sum = 0, kurtosis
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

        if M4 == 0:
            kurtosis = 0
        else:
            kurtosis = (n * M4) / (M2 * M2)
            kurtosis = log(kurtosis + 1)
            kurtosis_sum += kurtosis
         
        
        moments[a][0] = mean
        moments[a][1] = M2
        moments[a][2] = M3
        moments[a][3] = M4
        moments[a][4] = n
        #moments[a][5] = kurtosis
        kurtosis_arr[a] = kurtosis
        return kurtosis_sum
              
       
