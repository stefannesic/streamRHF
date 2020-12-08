from my_imports import np
# returns Leaf of instance in a RHT
cpdef find_instance(rht, x):
    cdef float a_val
    cdef Py_ssize_t a
    if rht.left != None and rht.right != None:
        # not leaf
        a = rht.attribute
        a_val = rht.value
        if (x[a] < a_val):
            return find_instance(rht.left, x)
        else:
            return find_instance(rht.right, x)
    else:
        # leaf
        data = np.asarray(rht.data)
        if x in data:
            return rht

