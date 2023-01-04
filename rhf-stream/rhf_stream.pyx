from my_imports import np, Node, ins, rht

def rhf_stream(data):
    N = 100
    T = 100
    H = 5
    base = np.empty([N])
    rht = None

    // simulating real-time 
    // construct initial tree with batch algorithm on the first N points
    for i in range(0, N):
        base[i] = data[i]

    Node.Node.H = H
    tree = rht.rht(base, t=T)

    // update existing tree
    for i in range(100, data.shape[0]):
        ins.insert(tree, data[i])
