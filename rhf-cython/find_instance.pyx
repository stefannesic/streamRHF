# returns Leaf of instance in a RHT
cpdef find_instance(rht, int[:] x):
    cdef float a_val
    cdef Py_ssize_t a
    if rht.left != None or rht.right != None:
        # not leaf
        a = rht.attribute
        a_val = rht.value

        if (x[a] < a_val):
            return find_instance(rht.left, x)
        else:
            return find_instance(rht.right, x)
    else:
        # leaf
        if x in rht.data:
            return rht

