from my_imports import np
class Split:
    def __init__(self, int h):
        self.splits = np.empty([(2**h)-1], np.intc)
        self.attributes = np.empty([(2**h)-1], np.intc)
        self.values = np.empty([(2**h)-1], np.float32)
