from my_imports import np, rht, ins, time

def rht_stream(data, N):

    base = np.empty([N, data.shape[1]], np.float32)

    # simulating real-time 
    # construct initial tree with batch algorithm on the first N points
    for i in range(0, N):
        base[i] = data[i]

    tree = rht.rht(base, 0)

    t0 = time.time()
    # update existing tree
    for i in range(N, data.shape[0]):
        #print("i=", i)
        #print("data(i)=", data[i])
        tree = ins.insert(tree, np.array([data[i]], np.float32))
    t1 = time.time()

    print("Total time for insertions = ", t1-t0)

    return tree

