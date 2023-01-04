from my_imports import ks_cy, np, random
# the kurtosis sum to get best attribute for the split
# returns attribute, its column and a random split value
def get_attribute(X):
    # attribute selected according to kurtosis
    ks = ks_cy.kurtosis_sum(X, X.shape[1]-1)
    # ks may not be included depending on rounding
    r = random.uniform(0, ks)
        
    for a in range(0, X.shape[1]):
        if ks_cy.kurtosis_sum(X, a) > r:
            a_col = X[:, a]
                        
            # ensures that the split will be proper (no split on extremes)
            a_val = np.amin(a_col)

            while a_val == np.amin(a_col) or a_val == np.max(a_col):
                a_val = random.uniform(np.amin(a_col), np.amax(a_col))

            return a, a_col, a_val
