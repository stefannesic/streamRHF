from my_imports import np
# a Node contains a splitting value, splitting attribute as well as left and right trees
class Node:
    def __init__(self, float value, int attribute, left, right):
        self.value = value
        self.attribute = attribute
        self.left = left
        self.right = right

    # prints the data and splitting information in order of left branch, parent node, right branch
    def printNode(self, int level):
        tabs = ""
        for i in range(0, level):
            tabs += "\t"
        # Leaf case
        if (self.left is None and self.right is None):
            arr = np.asarray(self.data)
            str_arr = np.array2string(arr)
            print(tabs + str_arr)
        else:
            # taking into account splits that have all instances on one side
            if self.left is not None:
                Node.printNode(self.left, level+1)
            print(tabs + "a" + str(self.attribute) + " < " + str(self.value))
            if self.right is not None:
                Node.printNode(self.right, level+1)

