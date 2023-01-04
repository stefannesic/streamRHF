from my_imports import np
class Leaves:
    def __init__(self, int H, int W_MAX):
        self.counters = np.zeros([2**H], dtype=np.intc)
        self.table = np.empty([2**H, W_MAX], dtype=np.intc)
