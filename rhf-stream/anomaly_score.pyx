from my_imports import np
from libc.math cimport log

cpdef anomaly_score(int[:,:,:] indexes, Py_ssize_t t):
    cdef float p
    cdef int leaf_size, i, j, data_pointer
    cdef Py_ssize_t n = indexes.shape[1]
    cdef float[:] scores = np.zeros([n], np.float32)
    cdef int[:] elem

    for i in range (0, t):
        for j in range(0, n):
            elem = indexes[i][j]
            data_pointer = elem[0]
            leaf_size = elem[1]
            p = leaf_size / n
            scores[data_pointer] += log(1/p)
    return scores

# anomaly score for insertion data structure)
cpdef anomaly_score_ids(insertionDS, Py_ssize_t t, int n):
    cdef float score
    cdef int i, j, data_pointer
    cdef Py_ssize_t ids_size, leaf_size
    cdef float[:] scores = np.zeros([n], np.float32)
    
    # get table size, it's the same for all trees
    ids_size = insertionDS[0].table.shape[0] 
        
    for i in range (0, t): 
       for j in range(0, ids_size):
            # get leaf_size and calculate score
            leaf_size = insertionDS[i].counters[j]
            if (leaf_size != 0):
                score = leaf_size / n
                score = log(1/leaf_size)
                for k in range(0, leaf_size):
                    data_pointer = insertionDS[i].table[j][k]
                    scores[data_pointer] += score
    return scores

   
