from my_imports import np, Node
# returns Leaf of instance in a RHT
cpdef find_instance(rht, int x, x_val):
    cdef float a_val
    cdef Py_ssize_t a
    if rht.left != None and rht.right != None:
        # not leaf
        a = rht.attribute
        a_val = rht.value
        if (x_val[a] < a_val):
            return find_instance(rht.left, x, x_val)
        else:
            return find_instance(rht.right, x, x_val)
    else:
        # leaf
        data = np.asarray(rht.data)
        if x in data:
            return rht.data.size

