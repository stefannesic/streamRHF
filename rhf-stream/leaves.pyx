from my_imports import np
class Leaves:
    def __init__(self, int H, int W_MAX):
        self.counters = np.zeros([2**H], dtype=np.intc)
        # 2**H = max number of leaves, W_MAX = max number of elements per leaf
        # all set to -1
        self.table = np.zeros([2**H, W_MAX], dtype=np.intc) - 1
