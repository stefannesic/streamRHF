from my_imports import np, ks_cy, ga, random, constants, dataset

# sort indexes according to split
def sort(int tree, int start, int end, int a, float a_val):
    cdef float temp
    cdef int i, j
    # quicksort Hoare partition scheme
    i = start
    j = end
    while i < j:
        while dataset.data[dataset.index[tree][i][0]][a] <= a_val and i < j: 
            i = i + 1
        while dataset.data[dataset.index[tree][j][0]][a] > a_val and j > i:
            j = j - 1
        temp = dataset.index[tree][i][0]
        dataset.index[tree][i][0] = dataset.index[tree][j][0]
        dataset.index[tree][j][0] = temp
        
    return j
         
def rht(int tree, int start, int end, int nd):
    cdef int ls, a
    cdef float ks, a_val, split 
    cdef float[:] kurt
    if (end == start or nd >= constants.H):
        # leaf size
        fill_leaf(tree, start, end)
    else:
        # calculate kurtosis
        ks, kurt = ks_cy.kurtosis_sum(tree, start, end)
        if (ks == 0): # stop if all elems are the same
            fill_leaf(tree, start, end)
        else: # split
            a, a_val = ga.get_attribute(tree, start, end, ks, kurt)
            # sort indexes
            split = sort(tree, start, end, a, a_val)
            rht(tree, start, split-1, nd+1)
            rht(tree, split, end, nd+1)
           

def fill_leaf(int tree, int start, int end):
    cdef int ls, i
    ls = end - start + 1
    for i in range(start, end+1):
        dataset.index[tree][i][1] = ls

