from my_imports import np, rht, ins, time, Node

def rht_stream(data, N, counter):
    # simulating real-time (except trees constructed one by one) 
    # construct initial tree with batch algorithm on the first N points
    tree = rht.rht(np.arange(0, N), 0, np.zeros([data.shape[1], 5], dtype=np.float32))

    t0 = time.time()
    size = N
    # update existing tree
    for i in range(N, data.shape[0]):
        #tbi = time.time()
        # on first iteration, store each new point inserted
        if counter == 0:
            Node.data_complete = np.append(Node.data_complete, np.array([data[i]], np.float32), axis=0)
        tree = ins.insert(tree, np.array([size]))
        size = size + 1
        #tai = time.time()
        #print(f'insertion #{i}')
    t1 = time.time()

    print("Total time for insertions = ", t1-t0)

    return tree

