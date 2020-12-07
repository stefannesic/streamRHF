from my_imports import Node
# a Leaf is a Node that has all parameters set to None except for data which contains its instances
class Leaf(Node.Node):
    def __init__(self, float[:,:] data):
        super().__init__(value=-1, attribute=-1, left=None, right=None)
        self.data = data
