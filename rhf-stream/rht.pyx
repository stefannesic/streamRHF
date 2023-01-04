from my_imports import np, ks_cy, ga, random

# sort indexes according to split
def sort(float[:,:] data, int[:,:] indexes, int start, int end, int a, float a_val):
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
         
def rht(float[:,:] data, int[:,:] indexes, split_info, float[:,:,:] moments, int start, int end, int nd, int H, int nodeID=0):
    cdef int ls, a, split
    cdef float ks, a_val 
    cdef float[:] kurt
    cdef float[:,:] moments_res
    if (end == start or nd >= H):
        # leaf size
        indexes = fill_leaf(indexes, start, end)
    else:
        # calculate kurtosis
        ks, kurt, moments_res = ks_cy.kurtosis_sum(data, indexes, moments[nodeID], start, end)
        moments[nodeID] = moments_res
        if (ks == 0): # stop if all elems are the same
            for i in range(start, end+1):
                indexes[i][1] = 1

        else: # split
            a, a_val = ga.get_attribute(data, indexes, start, end, ks, kurt)
            # sort indexes
            split = sort(data, indexes, start, end, a, a_val)

            # store split info
            split_info.splits[nodeID] = split
            split_info.attributes[nodeID] = a
            split_info.values[nodeID] = a_val
            rht(data, indexes, split_info, moments, start, split-1, nd+1, H, nodeID=2*nodeID+1)
            rht(data, indexes, split_info, moments, split, end, nd+1, H, nodeID=2*nodeID+2)
           

def fill_leaf(int[:,:] indexes, int start, int end):
    cdef int ls, i
    ls = end - start + 1
    for i in range(start, end+1):
        indexes[i][1] = ls

