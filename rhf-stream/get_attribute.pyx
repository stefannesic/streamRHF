from my_imports import np, ks_cy, random

def get_attribute(float[:,:] data, int[:,:] indexes, int start, int end, float ks, float[:] kurt):
    cdef int a, i 
    cdef float a_val, a_min, a_max, temp, r
    
    r = random.uniform(0, ks)
   
    kurt = np.cumsum(kurt)
    
    # the attribute is found in the bins of the cumulative sum of kurtoses 
    a = np.digitize(r, kurt, True)
    # get min and max
    a_min = data[indexes[start][0]][a]
    a_max = data[indexes[start][0]][a]

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
