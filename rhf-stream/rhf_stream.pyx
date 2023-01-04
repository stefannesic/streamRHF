from my_imports import np, Node, ins, rht

def rhf_stream(data, n, t, h, eps):
    N = 100
    T = t
    H = h
    
    Node.Node.H = H
    rht.eps = eps
    base = np.empty([N])



    # simulating real-time 
    # construct initial tree with batch algorithm on the first N points
    for i in range(0, N):
        base[i] = data[i]

    tree = rht.rht(base, t=T)

    # update existing tree
    for i in range(N, data.shape[0]):
        tree = ins.insert(tree, np.array([data[i]], np.float32))

    return tree
