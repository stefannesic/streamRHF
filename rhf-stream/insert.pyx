from my_imports import Node, np, rht

def insert(root, x):
    # tree is not leaf
    if root.left != None and root.right != None:
        a = root.attribute
        a_val = root.value
        # is child left 
        left = False

        if (x[a] < a_val):
            left = True
            child = root.left
        else:
            child = root.right
        
        # child is leaf  
        if child.left == None:
            x = np.array([x], np.float32)
            # leaf is at max depth
            if child.nd == Node.H:
                child.insertData(x)
                root.replace(child, left)
                Node.Node.printNode(child, 0)
            else:
                # leaf depth is not max, so new split
                root.replace(rht.rht(np.append(child.data, x, axis=0), child.nd), left)
        else:
            # keep searching
            insert(child, x)
 
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
    

