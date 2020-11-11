import scipy.io as sio
import random 
import numpy as np

class Node:
	def __init__(self, value, attribute, left, right, data=None):
		self.value = value
		self.attribute = attribute
		self.left = left
		self.right = right
		self.data = data

	def printNode(self):
		# Leaf case
		if (self.left is None and self.right is None):
			print(self.data)
		else:
			if self.left != []:
				Node.printNode(self.left)
			print("a" + str(self.attribute) + " < " + str(self.value))
			if self.right != []:
				Node.printNode(self.right)

class Leaf(Node):
	def __init__(self, data):
		super().__init__(value=None, attribute=None, left=None, right=None, data=data)
	
def rhf(X, nd, h):
	if nd >= h or X.shape[0] == 1:
		print("Leaf(X)=", X)
		return Leaf(np.unique(X, axis=0))
	else:
		# attribute selected according to kurtosis
		# ks = kurtosis_sum(X)
		# r = random.uniform(0, ks)
		a = random.randint(0, X.shape[1] - 1)
		print("a=",a)
		print("X=",X)
		a_col = X[:, a]
		print("a_col=", a_col)
		a_val = random.uniform(np.amin(a_col), np.amax(a_col))
		print("a_val=", a_val)
		Xl = X[X[:, a] < a_val]
		Xr = X[X[:, a] >= a_val]
		if Xl != []:
			rhf(Xl, nd + 1, h)
		if Xr != []:
			rhf(Xr, nd + 1, h)
		
		return Node(a_val, a, Xl, Xr)

mat_contents = sio.loadmat("satellite.mat")

Node.printNode(rhf(X=mat_contents['X'], nd=0, h=5))

