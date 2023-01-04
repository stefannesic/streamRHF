import scipy.io as sio
import scipy.stats as sstats
import random 
import numpy as np

# a Node has contains a splitting value, splitting attribute as well as left and right trees
class Node:
	def __init__(self, value, attribute, left, right):
		self.value = value
		self.attribute = attribute
		self.left = left
		self.right = right

	# prints the data and splitting information in order of left branch, parent node, right branch
	def printNode(self):
		# Leaf case
		if (self.left is None and self.right is None):
			print(self.data)
		else:
			# taking into account splits that have all instances on one side
			if self.left is not None:
				Node.printNode(self.left)
			print("a" + str(self.attribute) + " < " + str(self.value))
			if self.right is not None:
				Node.printNode(self.right)

# a Leaf is a Node that has all parameters set to None except for data which contains its instances
class Leaf(Node):
	def __init__(self, data):
		super().__init__(value=None, attribute=None, left=None, right=None)
		self.data = data
	
# construction of a random histogram tree
def rht(X, nd, h):
	if nd >= h or X.shape[0] == 1:
		# returns instances without duplicates
		return Leaf(np.unique(X, axis=0))
	else:
		# attribute selected according to kurtosis
		#ks = kurtosis_sum(X, X.shape[1])
		# !!!ks may not be included depending on rounding
		#r = random.uniform(0, ks)
		#a = get_attribute(X, r)
		a = random.randint(0, X.shape[1]-1)
		a_col = X[:, a]
		
		# split is made using a random value betweem the min and max of the splitting attribute
		a_val = random.uniform(np.amin(a_col), np.amax(a_col))
		Xl = X[X[:, a] < a_val]
		Xr = X[X[:, a] >= a_val]

		# check if the data split does not generate an empty set
		if Xl.size != 0:
			Xl = rht(Xl, nd + 1, h)
		else:
			Xl = None

		if Xr.size != 0:
			Xr = rht(Xr, nd + 1, h)
		else:
			Xl = None

		return Node(a_val, a, Xl, Xr)

# construction of a random histogram forest
def rhf(X, t, nd, h):
	# create an empty forest
	rhf = np.empty([t], dtype=object)

	# append t random histogram trees
	for i in range(t):
		rhf[i] = rht(X, nd, h)

	return rhf

# use kurtosis sum to get best attribute for the split
def get_attribute(X, r):
	for a in range(0, X.shape[1]):
		if kurtosis_sum(X, a) > r:
			return a

# sum of log(Kurtosis(X[a] + 1)) of attributes 0 to d
def kurtosis_sum(X, d):
	sum = 0

	# loop over the transpose matrix in order to analyze by column
	for a in range(0, d):
		sum += np.log(sstats.stats.kurtosis(X[:,a])+1)

	return sum

# set the number of trees and max height
H = 5
T = 100

# extract matlab data from dataset in the form of a dictionary of numpy arrays
# X is the data, y are the labels
mat_contents = sio.loadmat("satellite.mat")

dataset = mat_contents['X'] 
#dataset = np.array([[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12]])

# print the first random histogram tree for the above dataset 
Node.printNode(rhf(X=dataset, t=T, nd=0, h=H)[0])
#Node.printNode(rht(X=dataset, nd=0, h=H))
