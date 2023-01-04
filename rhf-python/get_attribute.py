from my_imports import ks_cy, np, random
# the kurtosis sum to get best attribute for the split
# returns attribute, its column and a random split value
def get_attribute(X):
    # attribute selected according to kurtosis
    ks = ks_cy.kurtosis_sum(X, X.shape[1]-1)
    # ks may not be included depending on rounding
    r = random.uniform(0, ks)
    end = X.shape[1]
    for a in range(0,end):
        if ks_cy.kurtosis_sum(X, a) > r:
            a_col = X[:, a]
            # ensures that the split will be proper (no split on extremes)
            a_min = np.amin(a_col)
            a_max = np.amax(a_col)
            a_val = a_min
           
            while a_val == a_min or a_val == a_max:
                    a_val = random.uniform(a_min, a_max)
                    
            return a, a_col, a_val

