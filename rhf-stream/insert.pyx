from my_imports import Node, np, rht, ks_cy, time
# inserts new data point in leaf
# returns updated tree if splits in path affected by new data point
def insert(root, x):
    # analyze non leaf node until x is inserted
    # if a non leaf node kurtosis changes, recalculate split
    t0 = time.time()
    x_value = Node.data_complete[x]
    if (x_value.size == 0):
        print("X value is empty and x=", x)
    # moments for tree recalculations
    moments0 = np.zeros([x_value.size,5], dtype=np.float32)
    t1 = time.time()
    print("before 1st if =", t1 - t0)
    # tree is not leaf
    if root.left != None and root.right != None:
        # ----- check for resplit ------
        # calculate new kurtosis and sum with new data point
        root.data = np.append(root.data, x, axis=0) 
        t2 = time.time()
        print("after append data=", t2 - t1)
        new_ks, new_k, root.moments = ks_cy.kurtosis_sum(x_value, root.moments)
        t3 = time.time()
        print("after ks sum=", t3 - t2)
        # the previously stored probability of splitting on a 
        old_p = np.asarray(root.old_k) / root.old_ks
        # the current probability
        new_p = np.asarray(new_k) / new_ks
        delta_p = new_p - old_p 
        t4 = time.time()
        print("delta_p calc=", t4 - t3)
        for a in np.where(abs(delta_p) >= 1 - rht.eps)[0]:
            if ((root.attribute != a and delta_p[a] > 0) or (root.attribute == a and delta_p[a] < 0)):                       
                # node is replaced by a new tree 
                Node.rebuild[root.nd] += 1
                return rht.rht(root.data, root.nd, moments0) 
        t5 = time.time()
        print("no change > eps time=", t5 - t4)
        # ----- insertion ------- 

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
        t6 = time.time()
        print("find child time=", t6 - t5)
        # child is leaf  
        if child.left == None:
            # leaf is at max depth
            if child.nd == Node.H:
                child.insertData(x)
                root.replace(child, left)
                t7 = time.time()
                print("insertData and replace child time=", t7 - t6)
            else:
                # leaf depth is not max, so new split
                Node.rebuild[5] += 1
                root.replace(rht.rht(np.append(child.data, x, axis=0), child.nd, moments0), left)
                t8 = time.time()
                print("leaf not max depth split time=", t8 - t6)


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
    

