from my_imports import np, rht, ins, time

cpdef rht_stream(float[:,:] data, int[:,:] indexes, insertionDS, split_info, float[:,:, :] moments, int H, int N_init_pts):
    # simulating real-time (except trees constructed one by one) 
    # construct initial tree with batch algorithm on the first N points
    cdef int n = data.shape[0]
    rht.rht(data, indexes, insertionDS, split_info, moments, start=0, end=N_init_pts-1, nd=0, H=H, nodeID=0) 
    print("Initial tree constructed.")   
    t0 = time.time()
    # update existing tree
    for i in range(N_init_pts, data.shape[0]):
        ins.insert(data, moments, split_info, H, insertionDS, i)
 
    t1 = time.time() 

    print("Total time for insertions=", t1 - t0)
