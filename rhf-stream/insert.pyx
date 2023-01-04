from my_imports import np, rht, ks_cy, time
# inserts new data point in leaf
def insert(float[:,:] data, float[:,:,:] moments, split_info, int H, insertionDS, int i):
    # analyze non leaf node until x is inserted
    # if a non leaf node kurtosis changes, recalculate split
    # start at root node
    cdef int nodeID = 0, a, leaf_index, counter, nd = 0
    cdef float a_val, old_kurtosis_sum, new_kurtosis_sum
    cdef float[:] old_kurtosis_vals
    cdef float[:] new_kurtosis_vals
    cdef float[:,:] moments_res
    # while leaf node isn't reached
    while nodeID < (2**H)-1 and split_info.splits[nodeID] != 0:
        a = split_info.attributes[nodeID]
        a_val = split_info.values[nodeID]
        # calculate new kurtosis
        old_kurtosis_vals = split_info.kurtosis_vals[nodeID]
        old_kurtosis_sum = split_info.kurtosis_sum[nodeID]
        new_kurtosis_sum, new_kurtosis_vals, moments_res = ks_cy.kurtosis_sum_ids(data, moments[nodeID], i) 
        moments[nodeID] = moments_res
        # analyze kurtosis for rebuild
        # TODO
        
        if data[i][a] <= a_val:
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
    
    counter = insertionDS.counters[leaf_index]
    insertionDS.table[leaf_index][counter] = i
    insertionDS.counters[leaf_index] += 1
    

    




'''
def insert(root, x):
    t0 = time.time()
    # analyze non leaf node until x is inserted
    # if a non leaf node kurtosis changes, recalculate split
    x_value = Node.data_complete[x]
    if (x_value.size == 0):
        print("X value is empty and x=", x)
    # moments for tree recalculations
    moments0 = np.zeros([x_value.size,6], dtype=np.float32)
    # tree is not leaf
    t1 = time.time()
    # everything before first if
    Node.insstats[0] += (t1 - t0)
    if root.left != None and root.right != None:
        # ----- check for resplit ------
        # calculate new kurtosis and sum with new data point
        root.data = np.append(root.data, x, axis=0) 
        # everyting until kurtosis call
        t2 = time.time()
        Node.insstats[1] += (t2 - t1)
        new_ks, new_k, root.moments = ks_cy.kurtosis_sum(x_value, root.moments, True)
        t3 = time.time()
        # kurtosis call
        Node.insstats[2] += (t3 - t2)
        # the previously stored probability of splitting on a 
        old_p = np.asarray(root.old_k) / root.old_ks
        # the current probability
        new_p = np.asarray(new_k) / new_ks
        delta_p = new_p - old_p 
        t4 = time.time()
        # everything before for
        Node.insstats[3] += (t4 - t3)
        for a in np.where(abs(delta_p) >= 1 - rht.eps)[0]:
            if ((root.attribute != a and delta_p[a] > 0) or (root.attribute == a and delta_p[a] < 0)):                       
                # node is replaced by a new tree 
                Node.rebuild[root.nd] += 1
                # cost if rebuild occurs
                tree = rht.rht(root.data, root.nd, moments0) 
                t4b = time.time()
                Node.insstats[4] += (t4b - t4)
                return tree
        # ----- insertion ------- 
        t5 = time.time()
        # no rebuiild time
        Node.insstats[5] += (t5 - t4)
        a = root.attribute
        a_val = root.value
        # is child left 
        left = False

        # descend left or right
        if (x_value[0][a] < a_val):
            left = True
            child = root.left
        else:
            child = root.right

        # time before inserting element
        t6 = time.time()
        Node.insstats[6] += (t6 - t5)
    
        # child is leaf  
        if child.left == None:
            # leaf is at max depth
            if child.nd == Node.H:
                child.insertData(x)
                root.replace(child, left)
                t7 = time.time()
                Node.insstats[7] += (t7 - t6)
            else:
                # leaf depth is not max, so new split
                Node.rebuild[5] += 1
                root.replace(rht.rht(np.append(child.data, x, axis=0), child.nd, moments0), left)
                t8 = time.time() 
                Node.insstats[8] += (t8 - t6)
        else:
            # keep searching
            root.replace(insert(child, x), left)

        return root

    elif root.nd != Node.H:
        # tree is leaf and not at max height
        # leaf replaced by rht
        x = np.array([x], np.float32)
        tree = rht.rht(np.append(root.data, x, axis=0), 0)
        root.value = tree.value
        root.attribute = tree.attribute
        root.left = tree.left    
        root.right = tree.right
        root.data = None   
        return root 
    
'''
