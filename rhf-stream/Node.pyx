from my_imports import np
# a Node contains a splitting value, splitting attribute as well as left and right trees
class Node:
    # max height static definition
    H = 0
    def __init__(self, float value = -1, int attribute = -1, left = None, right = None, nd=0, data = None):
        self.value = value
        self.attribute = attribute
        self.left = left
        self.right = right
        self.nd = nd
        self.data = data

    # replace child node with "node"
    # left = True to replace left child
    def replace(self, node, left):
        if (left):
            self.left = node
        else:
            self.right = node

    # insert data in leaf
    def insertData(self, x):
        # if the instance isn't already in the leaf
        if not np.any(np.all(np.isin(x,self.data,True), axis=1)):
            self.data = np.append(self.data, x, axis=0)
        
    # prints the data and splitting information in order of left branch, parent node, right branch
    def printNode(self, int level):
        tabs = ""
        for i in range(0, level):
            tabs += "\t"
        # Leaf case
        if (self.left is None and self.right is None):
            arr = np.asarray(self.data)
            for x in arr:
                str_arr = np.array2string(x)
                print(tabs + str_arr)
        else:
            # taking into account splits that have all instances on one side
            if self.left is not None:
                Node.printNode(self.left, level+1)
            print(tabs + "a" + str(self.attribute) + " < " + str(self.value))
            if self.right is not None:
                Node.printNode(self.right, level+1)

