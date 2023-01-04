from my_imports import Leaf, np, Node, ga

# construction of a random histogram tree
def rht(X, nd, h):
    # last condition checks if all instances are the same --> split not possible
    if nd >= h or X.shape[0] == 1 or np.unique(X, axis=0).shape[0] == 1:
        # returns instances without duplicates
        return Leaf.Leaf(np.unique(X, axis=0))
    else:
        a, a_col, a_val = ga.get_attribute(X)
             
        Xl = X[X[:, a] < a_val]
        Xr = X[X[:, a] >= a_val]

        Xl = rht(Xl, nd + 1, h)
        Xr = rht(Xr, nd + 1, h)

        return Node.Node(a_val, a, Xl, Xr)
