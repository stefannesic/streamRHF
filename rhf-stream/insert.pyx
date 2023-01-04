from my_imports import Node, np, rht, ks_cy
# inserts new data point in leaf
# returns updated tree if splits in path affected by new data point
def insert(root, x):
    # analyze non leaf node until x is inserted
    # if a non leaf node kurtosis changes, recalculate split

    # moments for tree recalculations
    moments0 = np.zeros([root.data.shape[1],5], dtype=np.float32)
    # tree is not leaf
    if root.left != None and root.right != None:
        # ----- check for resplit ------
        
        # calculate new kurtosis and sum with new data point
        root.data = np.append(root.data, x, axis=0) 
       
        new_ks, new_k, root.moments = ks_cy.kurtosis_sum(x, root.data.shape[1]-1, root.moments)

        # the previously stored probability of splitting on a 
        old_p = np.asarray(root.old_k) / root.old_ks
        # the current probability
        new_p = np.asarray(new_k) / new_ks
        delta_p = new_p - old_p 
       
        for a in np.where(abs(delta_p) >= 1 - rht.eps)[0]:
            #print("in if delta_p")
            if ((root.attribute != a and delta_p[a] > 0) or (root.attribute == a and delta_p[a] < 0)):                       
                # node is replaced by a new tree 
                #print("a=", a)
                #print("old_p=", old_p)
                #print("new_p=", new_p)
                #print("delta_p=", delta_p[a])
                print("nd=", root.nd)
                #print("new subtree, root.data=", root.data)
                return rht.rht(root.data, root.nd, moments0) 
                
        # ----- insertion ------- 

        a = root.attribute
        a_val = root.value
        # is child left 
        left = False

        # descend left or right
        if (x[0][a] < a_val):
            left = True
            child = root.left
        else:
            child = root.right
        
        # child is leaf  
        if child.left == None:
            #print("child is leaf")
            # leaf is at max depth
            if child.nd == Node.H:
                child.insertData(x)
                #print("1)child.data(after ins)=", child.data)
                root.replace(child, left)
            else:
                # leaf depth is not max, so new split
                print("2) child.nd=", child.nd)
                #print("H=", Node.H)
                root.replace(rht.rht(np.append(child.data, x, axis=0), child.nd, moments0), left)
                
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
    

