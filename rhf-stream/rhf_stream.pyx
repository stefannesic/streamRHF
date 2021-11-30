from my_imports import np, random
import timeit, sys
from libc.math cimport log, fabs
cdef class Split:
    cdef int[:,:] splits
    cdef int[:,:] attributes
    cdef double[:,:] values

    def __init__(self, int t, int h, int d):
        self.splits = np.zeros([t,(2**h)-1], np.intc)
        self.attributes = np.empty([t,(2**h)-1], np.intc)
        self.values = np.empty([t,(2**h)-1], np.float64)


cdef class Leaves:
    cdef int[:,:] counters
    cdef int[:,:,:] table
    def __init__(self, int t, int H, int W_MAX):
        self.counters = np.zeros([t,2**H], dtype=np.intc)
        # 2**H = max number of leaves, W_MAX = max number of elements per leaf
        # all set to -1
        self.table = np.zeros([t,2**H, W_MAX], dtype=np.intc) - 1

# construction of a random histogram forest
cpdef rhf(double[:,::1] data, int t, int h):
    cdef int n = data.shape[0], d = data.shape[1]
    cdef int W_MAX = n
    cdef int[:] temp
    cdef Py_ssize_t i 
    # create an empty forest of t trees each with n x 3 
    # 2 = (index in X, number of elems in leaf)
    cdef int[:,:] indexes = np.empty([t, n], dtype=np.intc)
    # moments = trees * nodes * attributes * card({M1, M2, M3, M4, n})
    cdef double[:,:,:,:] moments = np.zeros([t, (2**h)-1, d, 6], dtype=np.float64)
    cdef Split splits = Split(t, h, d)
    # create secondary data structure for insertion algorithm
    cdef Leaves insertionDS = Leaves(t, h, W_MAX)
    cdef double[:] kurtosis_arr = np.empty([d], np.float64)
    # calculate t trees in global index variable
    for i in range(t):
        # intialize dataset.index
        temp = np.arange(0,n, dtype=np.intc)
        indexes[i] = temp
        rht(data=data, indexes=indexes[i], insertionDS=insertionDS, split_info=splits, moments=moments[i], kurtosis_arr=kurtosis_arr, start=0, end=n-1, nd=0, H=h, d=d, nodeID=0, t_id=i) 
    return anomaly_score_ids(insertionDS, t, n)

cpdef rhf_windowed(double[:,::1] data, int t, int h, int N_init_pts):
    cdef int n = data.shape[0], d = data.shape[1]
    cdef int W_MAX = n
    cdef int[:] index_range, leaf_indexes = np.empty([t], dtype=np.intc)
    cdef Py_ssize_t i, j  
    cdef double[:] scores = np.empty([n], dtype=np.float64)
    # create an empty forest of t trees each with N_init_pts x 3 
    # 2 = (index in X, number of elems in leaf)
    cdef int[:,:] indexes = np.empty([t, N_init_pts], dtype=np.intc)
    # moments = trees * nodes * attributes * card({M1, M2, M3, M4, n})
    cdef double[:,:,:,:] moments = np.zeros([t, (2**h)-1, d, 6], dtype=np.float64)
    cdef Split splits = Split(t, h, d)
    # create secondary data structure for insertion algorithm
    cdef Leaves insertionDS = Leaves(t, h, W_MAX)
    cdef double[:] kurtosis_arr = np.empty([d], np.float64)
    
    # initalize forest
    for i in range(t):
        # intialize dataset.index
        index_range = np.arange(0, N_init_pts, dtype=np.intc)
        indexes[i] = index_range
        rht(data, indexes[i], insertionDS, splits, moments[i], kurtosis_arr, start=0, end=N_init_pts-1, nd=0, H=h, d=d, nodeID=0, t_id=i) 
    
    print("Forest initialized... size="+str(N_init_pts)) 
    # score the intial points
    scores[:N_init_pts] = anomaly_score_ids(insertionDS, t, N_init_pts) 
    print("Initial forest scored.")
   
    # score remaining instances one by one 
    t0 = timeit.default_timer()
    for i in range(N_init_pts, n):
        # score point inserted in forest
        for j in range(t):
             leaf_indexes[j] = find_leaf(data, splits, h, i, t_id=j)
        scores[i] = anomaly_score_ids_incr(leaf_indexes, insertionDS, t, N_init_pts)
        # rebuild model every N_init_pts 
        if (i + 1) % N_init_pts == 0 and i != n - 1:
            insertionDS = Leaves(t, h, W_MAX)
            splits = Split(t, h, d)
            for j in range(t):
                index_range = np.arange(i-N_init_pts+1, i+1, dtype=np.intc)
                indexes[j] = index_range
                rht(data, indexes[j], insertionDS, splits, moments[j], kurtosis_arr, start=0, end=N_init_pts-1, nd=0, H=h, d=d, nodeID=0, t_id=j) 
        
    t1 = timeit.default_timer()

    print("Total time for insertions=", t1 - t0)
          
    return scores
 
# anomaly score for insertion data structure)
cdef double[:] anomaly_score_ids(Leaves insertionDS, Py_ssize_t t, int n):
    cdef double score
    cdef Py_ssize_t i, j, k, data_pointer, ids_size, leaf_size
    cdef double[:] scores = np.zeros([n], np.float64)
    
    # get table size, it's the same for all trees
    ids_size = insertionDS.table[0].shape[0] 
        
    for i in range (0, t): 
       for j in range(0, ids_size):
            # get leaf_size and calculate score
            leaf_size = insertionDS.counters[i][j]
            if (leaf_size != 0):
                score = leaf_size / n
                score = log(1/score)
                for k in range(0, leaf_size):
                    data_pointer = insertionDS.table[i][j][k]
                    scores[data_pointer] += score
    return scores
 
# anomaly score for insertion data structure)
cdef double anomaly_score_ids_incr(int[:] leaf_indexes, Leaves insertionDS, Py_ssize_t t, int n):
    cdef double score, res=0
    cdef Py_ssize_t i, j, leaf_size
        
    for i in range (0, t): 
        # get leaf_size and calculate score
        j = leaf_indexes[i]
        leaf_size = insertionDS.counters[i][j]
        if (leaf_size != 0):
            score = leaf_size / n
            score = log(1/score)
            res += score
    return res
 
# construction of a random histogram forest
cpdef rhf_stream(double[:,::1] data, int t, int h, int N_init_pts):
    cdef Py_ssize_t i, j, n = data.shape[0], d = data.shape[1]
    cdef int W_MAX = n
    cdef double t0, t1
    cdef int[:] index_range, leaf_indexes = np.empty([t], dtype=np.intc)
    cdef double[:] scores = np.empty([n], dtype=np.float64)
    # create an empty forest of t trees each with n x 3 
    # 2 = (index in X, number of elems in leaf)
    cdef int[:,:] indexes = np.empty([t, N_init_pts], dtype=np.intc)
    # r-values for each Node and each tree
    cdef double[:,::1] r_values = np.empty([t, (2**h)-1], dtype=np.float64)
    # moments = trees * nodes * attributes * card({M1, M2, M3, M4, n})
    cdef double[:,:,:,:] moments = np.zeros([t, (2**h)-1, d, 6], dtype=np.float64)
    cdef Split splits = Split(t, h, d)
    # create secondary data structure for insertion algorithm
    cdef Leaves insertionDS = Leaves(t, h, W_MAX)
    cdef double[::1] kurtosis_arr = np.empty([d], np.float64)

    cdef int[::1] new_indexes = np.empty([W_MAX], np.intc)
    # intialize t trees and r values
    for i in range(t):
        # initial r-values for i-th tree
        for j in range((2**h) - 1):
            r_values[i][j] = random.uniform(0, 1)     
         
        # intialize dataset.index
        index_range = np.arange(0, N_init_pts, dtype=np.intc)
        indexes[i] = index_range

        rht(data, indexes[i], insertionDS, splits, moments[i], kurtosis_arr, start=0, 
            end=N_init_pts-1, nd=0, H=h, d=d, nodeID=0, t_id=i, r_values=r_values[i]) 
    print("Forest initialized...") 
    # score the intial points
    scores[:N_init_pts] = anomaly_score_ids(insertionDS, t, N_init_pts) 
    print("Initial forest scored.")
    # insert each instance in all of the trees
    t0 = timeit.default_timer()

    # insert and score remaining instances one by one 
    for i in range(N_init_pts, n):
        for j in range(t):
            leaf_indexes[j] = insert(data, moments[j], splits, h, insertionDS, kurtosis_arr, new_indexes, i, j, r_values[j])
        # score point inserted in forest
        scores[i] = anomaly_score_ids_incr(leaf_indexes, insertionDS, t, i)
        
    t1 = timeit.default_timer()

    print("Total time for insertions=", t1 - t0)
          
    return scores

# sort indexes according to split
cdef int sort(double[:,::1] data, int[:] indexes, int start, int end, Py_ssize_t a, double a_val):
    cdef int temp
    cdef Py_ssize_t i, j
    # quicksort Hoare partition scheme
    i = start
    j = end
    while i < j:
        while data[indexes[i]][a] <= a_val and i < j: 
            i = i + 1
        while data[indexes[j]][a] > a_val and j > i:
            j = j - 1
        temp = indexes[i]
        indexes[i] = indexes[j]
        indexes[j] = temp
    return j
         
cdef int rht(double[:,::1] data, int[:] indexes, Leaves insertionDS, Split split_info, double[:,:,:] moments, 
             double[:] kurtosis_arr, int start, int end, int nd, int H, int d, Py_ssize_t nodeID=0, 
             Py_ssize_t t_id=0, double[:] r_values=None, double[::1] insertion_pt = None):
    cdef int ls, a, split, insertion_leaf = -1
    cdef double ks, a_val, r 
    if (end == start or nd >= H):
        # leaf size
        insertion_leaf = fill_leaf(indexes, insertionDS, nodeID, nd, H, start, end, 0, t_id) 
    else:   
        # calculate kurtosis
        ks = kurtosis_sum(data, indexes, moments[nodeID], kurtosis_arr, start, end)
        if (ks == 0): # stop if all elems are the same
            split_info.splits[t_id][nodeID] = 0
            insertion_leaf = fill_leaf(indexes, insertionDS, nodeID, nd, H, start, end, 1, t_id) 
        else: # split
            if r_values != None:
                r = r_values[nodeID]
            else:
                r = -1

            a, a_val, r = get_attribute(data, indexes, start, end, ks, kurtosis_arr, d, r)
            
            # if different r is chosen, update
            # otherwise, nothing will change
            if r_values != None: 
                r_values[nodeID] = r
            
            # sort indexes
            split = sort(data, indexes, start, end, a, a_val)
            # store split info
            split_info.splits[t_id][nodeID] = split
            split_info.attributes[t_id][nodeID] = a
            split_info.values[t_id][nodeID] = a_val
            # check on which side insertion point ended up 
            # return the result of that side 
            if insertion_pt != None: 
                if insertion_pt[a] <= a_val:
                    rht(data, indexes, insertionDS, split_info, moments, kurtosis_arr, split, end, 
                        nd+1, H, d, nodeID=2*nodeID+2, t_id=t_id, r_values=r_values, insertion_pt=insertion_pt)
                    insertion_leaf = rht(data, indexes, insertionDS, split_info, moments, kurtosis_arr, start, split-1, 
                                         nd+1, H, d, nodeID=2*nodeID+1, t_id=t_id, r_values=r_values, insertion_pt=insertion_pt)
                else:
                    rht(data, indexes, insertionDS, split_info, moments, kurtosis_arr, start, split-1, 
                        nd+1, H, d, nodeID=2*nodeID+1, t_id=t_id, r_values=r_values, insertion_pt=insertion_pt)
                    insertion_leaf = rht(data, indexes, insertionDS, split_info, moments, kurtosis_arr, split, end, 
                                         nd+1, H, d, nodeID=2*nodeID+2, t_id=t_id, r_values=r_values, insertion_pt=insertion_pt)
            else:
                rht(data, indexes, insertionDS, split_info, moments, kurtosis_arr, start, split-1, nd+1, H, d, 
                    nodeID=2*nodeID+1, t_id=t_id, r_values=r_values, insertion_pt=insertion_pt)
                rht(data, indexes, insertionDS, split_info, moments, kurtosis_arr, split, end, nd+1, H, d, 
                    nodeID=2*nodeID+2, t_id=t_id, r_values=r_values, insertion_pt=insertion_pt)

              
    return insertion_leaf

cdef (int, double, double) get_attribute(double[:,::1] data, int[:] indexes, Py_ssize_t start, Py_ssize_t end, double ks, double[:] kurt, int d, double r=-1):
    cdef Py_ssize_t i, a = -1, data_index
    cdef double a_val, a_min, a_max, temp, cumul = 0
   
    # if r is not set immediately choose one 
    if r == -1:
        r = random.uniform(0, ks)
    else:
        r = r * ks

    # keep choosing a different r until a_min != a_max
    # useful if kurt(a0) = 0 and r = 0... stuck in loop!
    while True:
        # cumulative sum
        for i in range(0, d):
            temp = kurt[i]
            kurt[i] += cumul 
            if i == 0:
                if r <= kurt[i]:
                    a = i
            else:
                if r > kurt[i-1] and r <= kurt[i]:
                    a = i 
            cumul += temp

        # get min and max
        data_index = indexes[start]
        a_min = data[data_index][a]
        a_max = a_min

        for i in range(start, end+1):
                temp = data[indexes[i]][a]
                if a_min > temp:
                    a_min = temp
                elif a_max < temp:
                    a_max = temp
        if a_min != a_max: 
            break 
        
        # if you reached this point r is not good, choose another
        r = random.uniform(0, ks)
      
    a_val = random.uniform(a_min, a_max)
    
    while a_val == a_min or a_val == a_max:
        a_val = random.uniform(a_min, a_max)
    
    return a, a_val, r / ks 

cdef double kurtosis_sum(double[:,::1] data, int[:] indexes, double[:,:] moments, double[:] kurtosis_arr, int start, int end):
    cdef Py_ssize_t d = data.shape[1], a
    cdef double ks = 0
    for a in range(0, d): 
        kurtosis_arr[a] = incr_kurtosis(data, indexes, moments[a], start, end, a)
        kurtosis_arr[a] = log(kurtosis_arr[a] + 1)
        ks += kurtosis_arr[a]
    return ks

cdef double incr_kurtosis(double[:,::1] data, int[:] indexes, double[:] moments, int start, int end, Py_ssize_t a):
    cdef double mean, M2, M3, M4, n, delta, delta_n, delta_n2, term1, n1, kurtosis, x
    cdef Py_ssize_t i 
    n, mean, M2, M3, M4 = (0, 0, 0, 0, 0)
    # for loop for when moments are initialized on multiple elements
    for i in range(start, end+1):
        x = data[indexes[i]][a]
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

          
cdef int fill_leaf(int[:] indexes, Leaves insertionDS, int nodeID, int nd, int H, 
                    int start, int end, int ls = 0, Py_ssize_t t_id=0):
    cdef Py_ssize_t i, leaf_index, counter
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
        # get the actual pointer to the dataset indexes[k]
        insertionDS.table[t_id][leaf_index][counter] = indexes[i]
        # increment counter
        insertionDS.counters[t_id][leaf_index] += 1

    return leaf_index

# inserts new data point in leaf
cdef int insert(double[:,::1] data, double[:,:,:] moments, Split split_info, int H, Leaves insertionDS, double[::1] new_kurtosis_vals, 
                 int[::1] new_indexes, Py_ssize_t i, int t_id, double[::1] r_values):
    # analyze non leaf node until x is inserted
    # if a non leaf node kurtosis changes, recalculate split
    # start at root node
    cdef Py_ssize_t nodeID = 0, a = -1, split_a, leaf_index, counter, d = data.shape[1] 
    cdef int nd = 0, ks = 0
    cdef double split_a_val, old_kurtosis_sum, new_kurtosis_sum, r, keep, cumul
    cdef double[:] old_kurtosis_vals
    cdef double[:] moments_calc
    cdef double M2, M4
    cdef int[:] split_attributes = split_info.attributes[t_id]
    cdef double[:] split_vals = split_info.values[t_id]
    cdef int[:] split_splits = split_info.splits[t_id]
    # subtree and rebuilds
    cdef Py_ssize_t j, k, l, start_index, end_index, total_counter  
    cdef int[::1] temp
    cdef int[:]  counters
    cdef int[:,:] table

    # while leaf node isn't reached
    while nodeID < (2**H)-1 and split_splits[nodeID] != 0:      
        split_a = split_attributes[nodeID]
        split_a_val = split_vals[nodeID]
        
        # calculate new kurtosis
        new_kurtosis_sum = kurtosis_sum_ids(data, moments[nodeID], new_kurtosis_vals, i) 
          
        # does the splitting attribute change?
        
        # find a corresponding to r value 
        r = r_values[nodeID] * new_kurtosis_sum
        cumul = 0
        a = -1
        for j in range(0, d):
            keep = new_kurtosis_vals[j]
            new_kurtosis_vals[j] += cumul 
            if j == 0:
                if r <= new_kurtosis_vals[j]:
                    a = j
            else:
                if r > new_kurtosis_vals[j-1] and r <= new_kurtosis_vals[j]:
                    a = j

            cumul += keep
        
        # if the attribute calculate is different from the split attribute => rebuild
        if (split_a != a):   
            # rebuild tree from current nodeID
            # 1) collect leaf values and create new indexes
            start_index = (2**(H - nd) * (nodeID + 1)) - 1 - (2**H - 1)
            end_index = (2**(H - nd)) - 1 + start_index
            total_counter = 0
            counters = insertionDS.counters[t_id]
            table = insertionDS.table[t_id]
            for k in range(start_index, end_index+1):
                counter = counters[k]
                for l in range(0, counter):
                    new_indexes[total_counter + l] = table[k][l] 
                total_counter += counter
                # reset counter to zero
                counters[k] = 0
            # add also point to insert
            new_indexes[total_counter] = i    
            leaf_index = rht(data, new_indexes, insertionDS, split_info, moments, new_kurtosis_vals, 
                        start=0, end=total_counter, nd=nd, H=H, d=d, nodeID=nodeID, t_id=t_id, r_values=r_values, insertion_pt=data[i])
            # tree rebuilt with inserted point => STOP
            return leaf_index
         
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
        # at this point, leaf_index is a leaf nodeID and needs to be adjusted for indexing in insertionDS
        leaf_index = leaf_index - ((2**H) - 1)
         
        # insert the leaf  
        counter = insertionDS.counters[t_id][leaf_index]
        insertionDS.table[t_id][leaf_index][counter] = i
        insertionDS.counters[t_id][leaf_index] += 1
        return leaf_index
    else:
        # not a max depth so extend depth
        leaf_index = (2**(H - nd))*(nodeID + 1) - 1
        # at this point, leaf_index is a leaf nodeID and needs to be adjusted for indexing in insertionDS
        leaf_index = leaf_index - ((2**H) - 1)
       
        # insert the leaf  
        counter = insertionDS.counters[t_id][leaf_index]
        insertionDS.table[t_id][leaf_index][counter] = i
        # store all elements in leaf in a temporary variable
        temp = insertionDS.table[t_id, leaf_index, :counter+1].copy()       
        # reset counter to 0
        insertionDS.counters[t_id][leaf_index] = 0
        # create new indexes with leaf elements
        new_indexes = temp   
        # fill new_indexes with indexes found in the leaf that is being split
        leaf_index = rht(data, new_indexes, insertionDS, split_info, moments, new_kurtosis_vals,
                          start=0, end=counter, nd=nd, H=H, d=d, nodeID=nodeID, t_id=t_id,  r_values=r_values, insertion_pt=data[i])
        
        return leaf_index



# find leaf
cdef int find_leaf(double[:,::1] data, Split split_info, int H, Py_ssize_t i, int t_id):
    # analyze non leaf node until x is inserted
    # if a non leaf node kurtosis changes, recalculate split
    # start at root node
    cdef Py_ssize_t nodeID = 0, split_a, leaf_index
    cdef int a, nd = 0
    cdef double split_a_val
    cdef int[:] split_attributes = split_info.attributes[t_id]
    cdef double[:] split_vals = split_info.values[t_id]
    cdef int[:] split_splits = split_info.splits[t_id]
    
    # while leaf node isn't reached
    
    while nodeID < (2**H)-1 and split_splits[nodeID] != 0:      
        split_a = split_attributes[nodeID]
        split_a_val = split_vals[nodeID]
            
        if data[i][split_a] <= split_a_val:
            nodeID = nodeID*2 + 1
        else:
            nodeID = nodeID*2 + 2

        # increase node depth
        nd += 1
    
    # calculate index for insertionDS
    if nodeID >= (2**H - 1) : # leaf is at max depth
        leaf_index = nodeID
        # at this point, leaf_index is a leaf nodeID and needs to be adjusted for indexing in insertionDS
        leaf_index = leaf_index - ((2**H) - 1)
         
    else:
        # not a max depth so extend depth
        leaf_index = (2**(H - nd))*(nodeID + 1) - 1
        # at this point, leaf_index is a leaf nodeID and needs to be adjusted for indexing in insertionDS
        leaf_index = leaf_index - ((2**H) - 1)
        
    return leaf_index

cdef double kurtosis_sum_ids(double[:,::1] data, double[:,:] moments, double[::1] kurtosis_arr, Py_ssize_t i):
    cdef Py_ssize_t d = data.shape[1], a
    cdef double mean, M2, M3, M4, n, delta, delta_n, delta_n2, term1, n1, x, kurtosis_sum = 0, kurtosis
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
        kurtosis_arr[a] = kurtosis
     
    return kurtosis_sum
              
       
