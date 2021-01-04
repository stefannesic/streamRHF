from my_imports import Node, np, rht, ks_cy
# inserts new data point in leaf
# returns updated tree if splits in path affected by new data point
def insert(root, x):
    # analyze non leaf node until x is inserted
    # if a non leaf node kurtosis changes, recalculate split

    # tree is not leaf
    if root.left != None and root.right != None:
        # ----- check for resplit ------
        
        # calculate new kurtosis and sum with new data point
        root.data = np.append(root.data, x, axis=0) 
        new_ks, new_k = ks_cy.kurtosis_sum(root.data, root.data.shape[1]-1)
        
        for a in range(root.data.shape[1]):
            print("a=", a)
            # the previously stored probability of splitting on a 
            old_p = root.old_k[a] / root.old_ks
            print("old_p=", old_p) 
            # the current probability
            new_p = new_k[a] / new_ks
            print("new_p=", new_p)
            delta_p = new_p - old_p

            if abs(delta_p) >= 1 - rht.eps:
                if ((root.attribute != a and delta_p > 0) or (root.attribute == a and delta_p < 0)):                       
                    # node is replaced by a new tree 
                    return rht(root.data, root.nd) 
                        
            
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
            # leaf is at max depth
            if child.nd == Node.H:
                child.insertData(x)
                root.replace(child, left)
            else:
                # leaf depth is not max, so new split
                root.replace(rht.rht(np.append(child.data, x, axis=0), child.nd), left)
                
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
    
