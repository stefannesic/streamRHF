from my_imports import np
class Split:
    def __init__(self, int h, int d):
        self.splits = np.zeros([(2**h)-1], np.intc)
        self.attributes = np.empty([(2**h)-1], np.intc)
        self.values = np.empty([(2**h)-1], np.float32)
        self.kurtosis_vals = np.empty([(2**h)-1, d], np.float32)
        self.kurtosis_sum = np.empty([(2**h)-1], np.float32)
