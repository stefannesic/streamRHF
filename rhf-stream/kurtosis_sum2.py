from my_imports import np, ik, time, Node

def same_values(arr):
    temp = arr[0]
    for i in range(1, arr.size):
        if arr[i] != temp:
            return False
    return True 

# sum of log(Kurtosis(X[a] + 1)) of attributes 0 to d inclusive
# when the function is used for insertions, insert_mode is True
def kurtosis_sum(X, moments, insert_mode=False):
    t0 = time.time()
    n_elems = X.shape[0]
    summ = 0.0
    d = X.shape[1]
    kurt = np.empty([d], np.float32)
    if insert_mode:
        X_0 = X[0]
    if (n_elems == 0):
        print("X is passed as empty")
    t1 = time.time()
    Node.ksstats[0] += (t1 - t0)

    t2 = time.time()
    # loop over the transpose matrix in order to analyze by column
    for a in range(0, d):
        t4 = time.time() 
        # if we're not in insertion mode, calculate if all of the values are the same
        if not(insert_mode):
            samevals = not(same_values(X[:,a]))
        else: 
            samevals = False
        
        # samevals is always false in insert_mode so only the second part matters 
        if (samevals or (insert_mode and (moments[a][5] == 0 or moments[a][0] != X_0[a]))):
            t6 = time.time()
            kurt[a], moments[a] = ik.incr_kurtosis(X[:,a], moments[a])
            t7 = time.time()
            # time for incremental function
            Node.ksstats[2] += (t7- t6)        
            kurt[a] = np.log(kurt[a] + 1)
            summ += kurt[a]
        else:
            if not(insert_mode):
                # label the column as having same values for future incr. checking
                moments[a][5] = 1
            kurt[a] = 0
            # increase number of elements
            moments[a][4] += 1
        # measure the time of one iteration of the for loop
        if (a == 0):
            Node.ksstats[1] += (t4-t2)
        # measure the total time of the loop contents         
        t5 = time.time()
        Node.ksstats[3] += (t5-t4)
        t5b= time.time()
        Node.ksstats[5] += (t5b-t5)
    # time entire for loop
    t3 = time.time()
    Node.ksstats[4] += (t3 - t2)  
    return summ, kurt, moments

'''
def kurtosis_sum_vect(float[:,:] X, moments, bint insert_mode=False):
    t0 = time.time()
    cdef bint samevals
    cdef int n_elems = X.shape[0]
    cdef float summ = 0.0
    cdef Py_ssize_t d = X.shape[1]
    cdef int a
    cdef float[:] kurt = np.empty([d], np.float32)
    cdef float[:] X_0
    if insert_mode:
        X_0 = X[0]
    if (n_elems == 0):
        print("X is passed as empty")
    t1 = time.time()
    Node.ksstats[0] += (t1 - t0)

    t2 = time.time()
    # if we're not in insertion mode, calculate if all of the values are the same
    if not(insert_mode):
        samevals = not(same_values(X[:,a]))
    else: 
        samevals = False
    
    # samevals is always false in insert_mode so only the second part matters 
    if (samevals or (insert_mode and (moments[a][5] == 0 or moments[a][0] != X_0[a]))):
        t6 = time.time()
        kurt, moments = ik.incr_kurtosis_vect(X, moments)
        t7 = time.time()
        # time for incremental function
        Node.ksstats[2] += (t7- t6)        
        kurt = np.log(kurt + 1)
        summ = np.sum(kurt)
    else:
        if not(insert_mode):
            # label the column as having same values for future incr. checking
            moments[a][5] = 1
        kurt[a] = 0
        # increase number of elements
        moments[a][4] += 1
    
    # time entire for loop
    t3 = time.time()
    Node.ksstats[4] += (t3 - t2)  
    return summ, kurt, moments
'''
